-- Migration: Server-Side Business Logic
-- Description: Functions for artifact submission and episode progression

-- ============================================================================
-- SUBMIT ARTIFACT FUNCTION
-- ============================================================================
-- This is the core function that handles episode submissions and progression
-- It enforces all business rules on the server side

CREATE OR REPLACE FUNCTION submit_artifact(
  p_match_id UUID,
  p_type TEXT,
  p_payload JSONB,
  p_prompt_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_current_episode INT;
  v_match_status TEXT;
  v_user_id UUID;
  v_artifacts_count INT;
  v_is_valid_type BOOLEAN;
  v_artifact_id UUID;
  v_assigned_prompt_id UUID;
BEGIN
  -- Get current user from auth
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Validate user is a participant
  IF NOT EXISTS (
    SELECT 1 FROM public.match_participants
    WHERE match_id = p_match_id AND user_id = v_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this match';
  END IF;

  -- Get match state
  SELECT current_episode, status INTO v_current_episode, v_match_status
  FROM public.matches
  WHERE id = p_match_id
  FOR UPDATE; -- Lock the row

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Match not found';
  END IF;

  -- Validate match is active
  IF v_match_status != 'active' THEN
    RAISE EXCEPTION 'Match is not active. Current status: %', v_match_status;
  END IF;

  -- Validate match is not completed
  IF v_current_episode > 7 THEN
    RAISE EXCEPTION 'This journey is already completed';
  END IF;

  -- Validate artifact type matches current episode
  SELECT validate_artifact_type_for_episode(v_current_episode, p_type)
  INTO v_is_valid_type;

  IF NOT v_is_valid_type THEN
    RAISE EXCEPTION 'Invalid artifact type "%" for episode %', p_type, v_current_episode;
  END IF;

  -- Check if user already submitted for this episode
  IF EXISTS (
    SELECT 1 FROM public.artifacts
    WHERE match_id = p_match_id
      AND user_id = v_user_id
      AND episode = v_current_episode
  ) THEN
    RAISE EXCEPTION 'You have already submitted for episode %', v_current_episode;
  END IF;

  -- Episode 1: Assign random prompt if not provided
  IF v_current_episode = 1 AND p_prompt_id IS NULL THEN
    SELECT id INTO v_assigned_prompt_id
    FROM public.episode_prompts
    WHERE episode = 1 AND is_active = true
    ORDER BY RANDOM()
    LIMIT 1;

    IF v_assigned_prompt_id IS NULL THEN
      RAISE EXCEPTION 'No active prompts available for Episode 1';
    END IF;

    -- Update prompt usage count
    UPDATE public.episode_prompts
    SET used_count = used_count + 1
    WHERE id = v_assigned_prompt_id;
  ELSE
    v_assigned_prompt_id := p_prompt_id;
  END IF;

  -- Insert artifact with prompt_id for Episode 1
  INSERT INTO public.artifacts (match_id, user_id, episode, type, payload, prompt_id)
  VALUES (
    p_match_id,
    v_user_id,
    v_current_episode,
    p_type,
    p_payload,
    CASE WHEN v_current_episode = 1 THEN v_assigned_prompt_id ELSE NULL END
  )
  RETURNING id INTO v_artifact_id;

  -- Check if both participants have submitted for this episode
  SELECT COUNT(*) INTO v_artifacts_count
  FROM public.artifacts
  WHERE match_id = p_match_id AND episode = v_current_episode;

  -- If both submitted, advance to next episode
  IF v_artifacts_count >= 2 THEN
    UPDATE public.matches
    SET current_episode = current_episode + 1,
        completed_at = CASE
          WHEN current_episode + 1 > 7 THEN NOW()
          ELSE NULL
        END,
        status = CASE
          WHEN current_episode + 1 > 7 THEN 'completed'
          ELSE 'active'
        END
    WHERE id = p_match_id;
  END IF;

  -- Return success with enhanced episode info
  RETURN jsonb_build_object(
    'success', true,
    'artifact_id', v_artifact_id,
    'episode', v_current_episode,
    'episode_completed', v_artifacts_count >= 2,
    'episode_advanced', v_artifacts_count >= 2,
    'new_episode', CASE
      WHEN v_artifacts_count >= 2 THEN v_current_episode + 1
      ELSE v_current_episode
    END,
    'journey_completed', v_artifacts_count >= 2 AND v_current_episode + 1 > 7,
    'partner_submitted', EXISTS(
      SELECT 1 FROM public.artifacts
      WHERE match_id = p_match_id
        AND episode = v_current_episode
        AND user_id != v_user_id
    ),
    'prompt_id', v_assigned_prompt_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION submit_artifact(UUID, TEXT, JSONB) TO authenticated;

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get user profile
CREATE OR REPLACE FUNCTION get_profile(p_user_id UUID)
RETURNS JSONB AS $$
BEGIN
  RETURN row_to_json(
    (SELECT p FROM public.profiles p WHERE p.user_id = get_profile.p_user_id)
  )::jsonb;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_profile(UUID) TO authenticated;

-- Get user's active matches
CREATE OR REPLACE FUNCTION get_active_matches(p_user_id UUID DEFAULT auth.uid())
RETURNS SETOF public.matches AS $$
BEGIN
  RETURN QUERY
  SELECT m.*
  FROM public.matches m
  JOIN public.match_participants mp ON m.id = mp.match_id
  WHERE mp.user_id = p_user_id
    AND m.status = 'active'
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_active_matches(UUID) TO authenticated;

-- Get artifacts for a match
CREATE OR REPLACE FUNCTION get_match_artifacts(p_match_id UUID)
RETURNS SETOF public.artifacts AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();

  -- Verify user is a participant
  IF NOT EXISTS (
    SELECT 1 FROM public.match_participants
    WHERE match_id = p_match_id AND user_id = v_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this match';
  END IF;

  RETURN QUERY
  SELECT a.*
  FROM public.artifacts a
  WHERE a.match_id = p_match_id
  ORDER BY a.episode ASC, a.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_match_artifacts(UUID) TO authenticated;

-- Get current episode info for a match
CREATE OR REPLACE FUNCTION get_current_episode_info(p_match_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_current_episode INT;
  v_my_artifact_id UUID;
  v_partner_artifact_id UUID;
  v_user_id UUID;
  v_both_submitted BOOLEAN;
BEGIN
  v_user_id := auth.uid();

  -- Verify user is a participant
  IF NOT EXISTS (
    SELECT 1 FROM public.match_participants
    WHERE match_id = p_match_id AND user_id = v_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this match';
  END IF;

  -- Get current episode
  SELECT current_episode INTO v_current_episode
  FROM public.matches
  WHERE id = p_match_id;

  -- Get user's artifact for this episode
  SELECT id INTO v_my_artifact_id
  FROM public.artifacts
  WHERE match_id = p_match_id
    AND episode = v_current_episode
    AND user_id = v_user_id;

  -- Get partner's artifact
  SELECT id INTO v_partner_artifact_id
  FROM public.artifacts
  WHERE match_id = p_match_id
    AND episode = v_current_episode
    AND user_id != v_user_id;

  -- Check if both submitted
  v_both_submitted := (v_my_artifact_id IS NOT NULL AND v_partner_artifact_id IS NOT NULL);

  RETURN jsonb_build_object(
    'current_episode', v_current_episode,
    'i_submitted', v_my_artifact_id IS NOT NULL,
    'partner_submitted', v_partner_artifact_id IS NOT NULL,
    'both_submitted', v_both_submitted,
    'my_artifact_id', v_my_artifact_id,
    'partner_artifact_id', v_partner_artifact_id,
    'can_view_partner_artifact', v_both_submitted OR v_current_episode > (
      SELECT COALESCE(MAX(episode), 0) FROM public.artifacts
      WHERE match_id = p_match_id AND user_id = v_user_id
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_current_episode_info(UUID) TO authenticated;

-- ============================================================================
-- CREATE PROFILE TRIGGER
-- ============================================================================
-- Automatically create profile when user signs up

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (user_id, name, age, bio)
  VALUES (
    NEW.id,
    split_part(NEW.email, '@', 1), -- Default name from email
    18, -- Default age (will be updated in onboarding)
    NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for matches with participant info
CREATE OR REPLACE VIEW match_details AS
SELECT
  m.id,
  m.created_at,
  m.status,
  m.current_episode,
  m.completed_at,
  ARRAY(
    SELECT p.user_id
    FROM public.match_participants mp
    JOIN public.profiles p ON p.user_id = mp.user_id
    WHERE mp.match_id = m.id
    ORDER BY p.user_id
  ) AS participant_ids
FROM public.matches m;

-- Grant access
GRANT SELECT ON match_details TO authenticated;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Composite index for artifact lookups
CREATE INDEX IF NOT EXISTS idx_artifacts_match_user_episode
  ON public.artifacts(match_id, user_id, episode);

-- Index for profile lookups by city/age
CREATE INDEX IF NOT EXISTS idx_profiles_city_age
  ON public.profiles(city, age);

-- ============================================================================
-- FUNCTION VALIDATION
-- ============================================================================
-- This validates episode completion before allowing progression

CREATE OR REPLACE FUNCTION validate_episode_completion(
  p_match_id UUID,
  p_episode INT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_artifact_count INT;
BEGIN
  SELECT COUNT(*) INTO v_artifact_count
  FROM public.artifacts
  WHERE match_id = p_match_id AND episode = p_episode;

  RETURN v_artifact_count >= 2;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- CLEANUP FUNCTION FOR OLD MATCHES
-- ============================================================================
-- Archive matches that have been completed for more than 30 days

CREATE OR REPLACE FUNCTION archive_old_matches()
RETURNS INT AS $$
DECLARE
  v_archived_count INT;
BEGIN
  -- Archive completed matches older than 30 days
  UPDATE public.matches
  SET status = 'archived'
  WHERE status = 'completed'
    AND completed_at < NOW() - INTERVAL '30 days';

  GET DIAGNOSTICS v_archived_count = ROW_COUNT;

  RETURN v_archived_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only admins can run this (or via scheduled job)
-- GRANT EXECUTE ON FUNCTION archive_old_matches() TO postgres;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON FUNCTION submit_artifact IS 'Core function for submitting episode artifacts with server-side validation and episode progression';
COMMENT ON FUNCTION get_active_matches IS 'Get all active matches for the current user';
COMMENT ON FUNCTION get_match_artifacts IS 'Get all artifacts for a specific match';
COMMENT ON FUNCTION get_current_episode_info IS 'Get current episode progress including submission status';
COMMENT ON FUNCTION handle_new_user IS 'Automatically create a profile when a user signs up via Supabase Auth';
