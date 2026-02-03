-- ============================================================================
-- AUTOMATIC LENS DETECTION SYSTEM
-- ============================================================================
-- This system automatically detects which lenses fit each user based on:
-- 1. Their interests
-- 2. Their bio/text responses
-- 3. Optional: job, field of study
-- Then automatically assigns the top 3 lenses

-- ============================================================================
-- FUNCTION: Detect user's lenses based on profile data
-- ============================================================================
CREATE OR REPLACE FUNCTION detect_user_lenses(p_user_id UUID)
RETURNS TABLE(
  lens_id UUID,
  lens_name TEXT,
  lens_key TEXT,
  confidence_score NUMERIC
) AS $$
DECLARE
  v_user_record RECORD;
  v_all_interests TEXT[];
  v_user_bio TEXT;
  v_lens_scores RECORD;
BEGIN
  -- Get user's profile data
  SELECT * INTO v_user_record
  FROM public.profiles
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  -- Extract interests as text array
  SELECT ARRAY_AGG(TRIM(interest->>'name'))
  INTO v_all_interests
  FROM jsonb_array_elements(v_user_record.interests) AS interest;

  -- Get bio (lowercase for matching)
  v_user_bio := COALESCE(v_user_record.bio, '');

  -- Return the top 3 lenses
  RETURN QUERY
  SELECT
    l.id,
    l.name,
    l.key,
    -- Calculate score for this lens
    (
      -- Sum of matching interests * weights
      COALESCE(
        (
          SELECT SUM(weight_val)
          FROM (
            SELECT
              CASE
                WHEN l.key = 'calm_cozy' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Reading', 'Coffee', 'Meditation', 'Yoga', 'Writing', 'Mindfulness', 'Books') THEN 2.0
                    WHEN TRIM(interest->>'name') IN ('Art', 'Museums', 'Board Games', 'Baking') THEN 1.5
                    WHEN TRIM(interest->>'name') IN ('Parties', 'Nightlife') THEN -1.0
                    ELSE 0
                  END
                WHEN l.key = 'active_energetic' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Gym', 'Running', 'Hiking', 'Cycling', 'Rock Climbing', 'Swimming', 'Tennis', 'Fitness', 'Adventure', 'Sports') THEN 2.5
                    WHEN TRIM(interest->>'name') IN ('Quiet Nights', 'Netflix') THEN -0.5
                    ELSE 0
                  END
                WHEN l.key = 'values_roots' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Volunteering', 'Religion', 'Family', 'History', 'Community', 'Tradition', 'Faith') THEN 2.5
                    WHEN TRIM(interest->>'name') IN ('Sustainability', 'Politics') THEN 1.8
                    ELSE 0
                  END
                WHEN l.key = 'creative_curious' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Art', 'Music', 'Photography', 'Writing', 'Design', 'Fashion', 'Museums', 'Creativity') THEN 2.5
                    WHEN TRIM(interest->>'name') IN ('Theater', 'Dance', 'Podcasts', 'Learning') THEN 1.8
                    ELSE 0
                  END
                WHEN l.key = 'social_spontaneous' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Parties', 'Festivals', 'Concerts', 'Dining Out', 'Networking', 'Hosting', 'Events', 'Brunch', 'Socializing') THEN 2.5
                    WHEN TRIM(interest->>'name') IN ('Quiet Nights', 'Reading') THEN -0.6
                    ELSE 0
                  END
                WHEN l.key = 'healthy_grounded' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Yoga', 'Meditation', 'Mindfulness', 'Wellness', 'Nature', 'Sustainability', 'Health') THEN 2.3
                    WHEN TRIM(interest->>'name') IN ('Cooking', 'Balance') THEN 1.8
                    WHEN TRIM(interest->>'name') IN ('Parties', 'Drama') THEN -0.6
                    ELSE 0
                  END
                WHEN l.key = 'ambitious_driven' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Technology', 'Business', 'Entrepreneurship', 'Career', 'Leadership', 'Ambition', 'Growth') THEN 2.3
                    WHEN TRIM(interest->>'name') IN ('Networking', 'Learning') THEN 2.0
                    ELSE 0
                  END
                WHEN l.key = 'humorous_playful' THEN
                  CASE
                    WHEN TRIM(interest->>'name') IN ('Comedy', 'Gaming', 'Board Games', 'Movies', 'Netflix', 'Fun', 'Humor', 'Playfulness') THEN 2.5
                    WHEN TRIM(interest->>'name') IN ('Concerts', 'Festivals', 'Travel') THEN 1.5
                    ELSE 0
                  END
                ELSE 0
              END AS weight_val
            FROM jsonb_array_elements(v_user_record.interests) AS interest
          ) AS weighted_interests
        ), 0
      )
      +
      -- Bonus for bio keyword matches
      (
        CASE
          WHEN l.key = 'calm_cozy' AND (v_user_bio ~* 'quiet|peaceful|relaxed|introvert|cozy|calm|serene') THEN 2.0
          WHEN l.key = 'active_energetic' AND (v_user_bio ~* 'energetic|active|workout|fitness|training|gym|sport') THEN 2.0
          WHEN l.key = 'values_roots' AND (v_user_bio ~* 'faith|family|traditional|grounded|values|religion') THEN 2.0
          WHEN l.key = 'creative_curious' AND (v_user_bio ~* 'creative|artist|curious|explore|imagine|design|artistic') THEN 2.0
          WHEN l.key = 'social_spontaneous' AND (v_user_bio ~* 'extrovert|social|outgoing|spontaneous|adventurous|party') THEN 2.0
          WHEN l.key = 'healthy_grounded' AND (v_user_bio ~* 'mindful|balanced|healthy|grounded|wellness') THEN 2.0
          WHEN l.key = 'ambitious_driven' AND (v_user_bio ~* 'ambitious|driven|career|entrepreneur|goal|success') THEN 2.0
          WHEN l.key = 'humorous_playful' AND (v_user_bio ~* 'funny|humor|playful|joke|lightheart|fun') THEN 2.0
          ELSE 0.0
        END
      )
    ) AS total_score
  FROM public.lenses l
  WHERE (
    -- Only return lenses with a positive affinity
    EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_user_record.interests) AS i
      WHERE CASE
        WHEN l.key = 'calm_cozy' THEN TRIM(i->>'name') IN ('Reading', 'Coffee', 'Meditation', 'Yoga', 'Writing', 'Mindfulness', 'Books')
        WHEN l.key = 'active_energetic' THEN TRIM(i->>'name') IN ('Gym', 'Running', 'Hiking', 'Cycling', 'Rock Climbing', 'Swimming', 'Tennis', 'Fitness', 'Adventure', 'Sports')
        WHEN l.key = 'values_roots' THEN TRIM(i->>'name') IN ('Volunteering', 'Religion', 'Family', 'History', 'Community', 'Tradition', 'Faith')
        WHEN l.key = 'creative_curious' THEN TRIM(i->>'name') IN ('Art', 'Music', 'Photography', 'Writing', 'Design', 'Fashion', 'Museums', 'Creativity')
        WHEN l.key = 'social_spontaneous' THEN TRIM(i->>'name') IN ('Parties', 'Festivals', 'Concerts', 'Dining Out', 'Networking', 'Hosting', 'Events', 'Brunch', 'Socializing')
        WHEN l.key = 'healthy_grounded' THEN TRIM(i->>'name') IN ('Yoga', 'Meditation', 'Mindfulness', 'Wellness', 'Nature', 'Sustainability', 'Health')
        WHEN l.key = 'ambitious_driven' THEN TRIM(i->>'name') IN ('Technology', 'Business', 'Entrepreneurship', 'Career', 'Leadership', 'Ambition', 'Growth')
        WHEN l.key = 'humorous_playful' THEN TRIM(i->>'name') IN ('Comedy', 'Gaming', 'Board Games', 'Movies', 'Netflix', 'Fun', 'Humor', 'Playfulness')
        ELSE false
      END
    )
    OR v_user_bio ~* 'quiet|peaceful|active|workout|faith|family|creative|social|wellness|ambitious|funny'
  )
  ORDER BY 4 DESC
  LIMIT 3;
END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION detect_user_lenses(UUID) TO authenticated;

-- ============================================================================
-- FUNCTION: Auto-assign top 3 lenses to user
-- ============================================================================
CREATE OR REPLACE FUNCTION auto_assign_user_lenses(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_assigned_count INT;
  v_top_lenses RECORD;
BEGIN
  -- Delete existing lens assignments for this user
  DELETE FROM public.user_lenses WHERE user_id = p_user_id;

  -- Get detected lenses and insert them
  INSERT INTO public.user_lenses (user_id, lens_id, rank)
  SELECT p_user_id, lens_id, generate_series(1, 3)
  FROM detect_user_lenses(p_user_id);

  GET DIAGNOSTICS v_assigned_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'user_id', p_user_id,
    'lenses_assigned', v_assigned_count,
    'message', CASE
      WHEN v_assigned_count = 3 THEN 'We detected your vibe and set 3 lenses for you!'
      WHEN v_assigned_count = 2 THEN 'We detected 2 lenses for you. Please select 1 more!'
      WHEN v_assigned_count = 1 THEN 'We detected 1 lens for you. Please select 2 more!'
      WHEN v_assigned_count = 0 THEN 'We couldn''t detect your lenses yet. Please pick 3 manually!'
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION auto_assign_user_lenses(UUID) TO authenticated;

-- ============================================================================
-- FUNCTION: Update user's bio to detect lenses (called after profile updates)
-- ============================================================================
CREATE OR REPLACE FUNCTION trigger_detect_lenses_after_profile()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-assign lenses when profile is completed
  -- This will be called when is_profile_complete becomes TRUE
  PERFORM auto_assign_user_lenses(NEW.user_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CREATE TRIGGER to auto-detect lenses after profile completion
-- ============================================================================
DROP TRIGGER IF EXISTS trigger_auto_detect_lenses ON public.profiles;

CREATE TRIGGER trigger_auto_detect_lenses
  AFTER UPDATE OF interests ON public.profiles
  FOR EACH ROW
  WHEN (NEW.interests IS NOT NULL AND jsonb_array_length(NEW.interests) >= 5)
  EXECUTE FUNCTION trigger_detect_lenses_after_profile();
