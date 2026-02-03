-- ============================================================================
-- EPISODE STATUS AND TIMELINE RPC FUNCTIONS
-- ============================================================================
-- These functions provide the Flutter app with real-time episode status
-- and artifact timeline data for the "Book" UI

-- ============================================================================
-- FUNCTION: Get Episode Status
-- ============================================================================
-- Returns the current episode status for a match, including:
-- - Current episode number
-- - Whether the current user has submitted
-- - Whether the partner has submitted
-- - Whether both have submitted (episode complete)
-- - The assigned prompt text (for Episode 1)
-- This is used by Episode 1 screen to determine which UI state to show

CREATE OR REPLACE FUNCTION get_episode_status(p_match_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_current_episode INT;
  v_my_submission BOOLEAN;
  v_partner_submission BOOLEAN;
  v_prompt_id UUID;
  v_prompt_text TEXT;
BEGIN
  -- Get current user from auth
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Match not found';
  END IF;

  -- Check if user has submitted for this episode
  SELECT EXISTS(
    SELECT 1 FROM public.artifacts
    WHERE match_id = p_match_id
      AND user_id = v_user_id
      AND episode = v_current_episode
  ) INTO v_my_submission;

  -- Check if partner has submitted for this episode
  SELECT EXISTS(
    SELECT 1 FROM public.artifacts
    WHERE match_id = p_match_id
      AND user_id != v_user_id
      AND episode = v_current_episode
  ) INTO v_partner_submission;

  -- Get prompt for Episode 1 (if user has submitted)
  IF v_current_episode = 1 AND v_my_submission THEN
    SELECT a.prompt_id, ep.prompt_text INTO v_prompt_id, v_prompt_text
    FROM public.artifacts a
    JOIN public.episode_prompts ep ON a.prompt_id = ep.id
    WHERE a.match_id = p_match_id
      AND a.user_id = v_user_id
      AND a.episode = 1;
  END IF;

  -- Return comprehensive episode status
  RETURN jsonb_build_object(
    'current_episode', v_current_episode,
    'i_submitted', v_my_submission,
    'partner_submitted', v_partner_submission,
    'both_submitted', v_my_submission AND v_partner_submission,
    'can_view_partner_artifact', v_my_submission AND v_partner_submission,
    'prompt_id', v_prompt_id,
    'prompt_text', v_prompt_text,
    'next_episode', CASE
      WHEN v_my_submission AND v_partner_submission THEN v_current_episode + 1
      ELSE v_current_episode
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_episode_status(UUID) TO authenticated;

-- ============================================================================
-- FUNCTION: Get Episode Timeline
-- ============================================================================
-- Returns all artifacts for a match as a timeline for the "Book" UI
-- Each artifact includes:
-- - Basic artifact info (id, episode, type, payload)
-- - Whether it belongs to the current user (is_mine)
-- - The prompt text (for Episode 1 artifacts)
-- Sorted by episode, then creation time

CREATE OR REPLACE FUNCTION get_episode_timeline(p_match_id UUID)
RETURNS SETOF JSONB AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get current user from auth
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Verify user is a participant
  IF NOT EXISTS (
    SELECT 1 FROM public.match_participants
    WHERE match_id = p_match_id AND user_id = v_user_id
  ) THEN
    RAISE EXCEPTION 'User is not a participant of this match';
  END IF;

  -- Return timeline with all artifacts
  RETURN QUERY
  SELECT jsonb_build_object(
    'id', a.id,
    'episode', a.episode,
    'type', a.type,
    'payload', a.payload,
    'user_id', a.user_id,
    'is_mine', a.user_id = v_user_id,
    'created_at', a.created_at,
    'prompt_id', a.prompt_id,
    'prompt_text', (
      SELECT ep.prompt_text
      FROM public.episode_prompts ep
      WHERE ep.id = a.prompt_id
    )
  )
  FROM public.artifacts a
  WHERE a.match_id = p_match_id
  ORDER BY a.episode ASC, a.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_episode_timeline(UUID) TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test get_episode_status (replace with actual match_id)
-- SELECT * FROM get_episode_status('<match_id>'::uuid);

-- Test get_episode_timeline (replace with actual match_id)
-- SELECT * FROM get_episode_timeline('<match_id>'::uuid);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION get_episode_status IS 'Get current episode status including submission state and assigned prompt';
COMMENT ON FUNCTION get_episode_timeline IS 'Get all artifacts for a match as a timeline with metadata for the "Book" UI';
