-- Migration: Daily Edition Generation
-- Description: Functions to generate daily curated candidates and update RLS policies

-- ============================================================================
-- HELPER FUNCTION: Check if profile is complete
-- ============================================================================

CREATE OR REPLACE FUNCTION is_profile_complete(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_profile RECORD;
  v_photo_count INT;
BEGIN
  -- Get profile data
  SELECT * INTO v_profile FROM public.profiles WHERE user_id = p_user_id;

  -- Check if profile exists and meets criteria
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_profile.name IS NULL OR v_profile.name = '' THEN
    RETURN FALSE;
  END IF;

  IF v_profile.age < 18 THEN
    RETURN FALSE;
  END IF;

  IF v_profile.bio IS NULL OR v_profile.bio = '' THEN
    RETURN FALSE;
  END IF;

  IF v_profile.interests IS NULL OR jsonb_array_length(v_profile.interests) = 0 THEN
    RETURN FALSE;
  END IF;

  IF v_profile.city IS NULL OR v_profile.city = '' THEN
    RETURN FALSE;
  END IF;

  -- Check for at least one photo
  SELECT COUNT(*) INTO v_photo_count
  FROM public.profile_photos
  WHERE user_id = p_user_id;

  IF v_photo_count = 0 THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- MAIN FUNCTION: Generate Daily Edition
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_daily_edition(p_user_id UUID)
RETURNS TABLE(
  candidate_user_id UUID,
  candidate_name TEXT,
  candidate_age INT,
  candidate_city TEXT,
  candidate_photo_url TEXT,
  candidate_tagline TEXT
) AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_existing_edition INT;
  v_user_city TEXT;
  v_user_university TEXT;
BEGIN
  -- Check if edition already exists for today
  SELECT COUNT(*) INTO v_existing_edition
  FROM public.daily_editions
  WHERE user_id = p_user_id AND edition_date = v_today;

  IF v_existing_edition > 0 THEN
    -- Return existing candidates
    RETURN QUERY
    SELECT
      unnest(de.candidate_user_ids),
      p.name,
      p.age,
      p.city,
      (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
      CONCAT('Exploring ', p.city)
    FROM public.daily_editions de
    CROSS JOIN unnest(de.candidate_user_ids) AS candidate_id
    JOIN public.profiles p ON p.user_id = candidate_id
    WHERE de.user_id = p_user_id AND de.edition_date = v_today;
    RETURN;
  END IF;

  -- Get current user's location info
  SELECT city, university INTO v_user_city, v_user_university
  FROM public.profiles
  WHERE user_id = p_user_id;

  -- Generate and insert candidates, then return them
  INSERT INTO public.daily_editions (user_id, edition_date, candidate_user_ids)
  SELECT p_user_id, v_today, ARRAY_AGG(user_id)
  FROM (
    SELECT p.user_id
    FROM public.profiles p
    WHERE
      -- Exclude current user
      p.user_id != p_user_id
      -- Only complete profiles
      AND is_profile_complete(p.user_id) = TRUE
      -- Same city OR same university
      AND (p.city = v_user_city OR p.university = v_user_university)
      -- Not already matched (any status)
      AND p.user_id NOT IN (
        SELECT mp2.user_id
        FROM public.match_participants mp1
        JOIN public.match_participants mp2 ON mp1.match_id = mp2.match_id
        WHERE mp1.user_id = p_user_id
      )
      -- Random order
      ORDER BY RANDOM()
      LIMIT 5
  ) candidates;

  -- Now return the newly created daily edition with full candidate data
  RETURN QUERY
  SELECT
    unnest(de.candidate_user_ids),
    p.name,
    p.age,
    p.city,
    (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
    CASE
      WHEN jsonb_array_length(p.interests) > 0 THEN
        CONCAT(UPPER(SUBSTRING(p.interests->0->>'name', 1, 1)),
               SUBSTRING(p.interests->0->>'name', 2), ' enthusiast')
      ELSE CONCAT('Exploring ', p.city)
    END
  FROM public.daily_editions de
  CROSS JOIN unnest(de.candidate_user_ids) AS candidate_id
  JOIN public.profiles p ON p.user_id = candidate_id
  WHERE de.user_id = p_user_id AND de.edition_date = v_today;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION generate_daily_edition(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_profile_complete(UUID) TO authenticated;

-- ============================================================================
-- UPDATE RLS POLICIES FOR MATCH CREATION
-- ============================================================================

-- Allow inserts through the trigger (trigger will enforce max 3)
DROP POLICY IF EXISTS "Users can insert match participants" ON public.match_participants;

CREATE POLICY "Users can insert match participants"
  ON public.match_participants FOR INSERT
  WITH CHECK (
    -- Must be authenticated as one of the users being added
    auth.uid() = user_id
  );

-- Allow direct insert for matches
DROP POLICY IF EXISTS "Authenticated users can create matches" ON public.matches;

CREATE POLICY "Authenticated users can create matches"
  ON public.matches FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- DAILY EDITIONS RLS POLICIES
-- ============================================================================

-- Allow users to read their own daily editions
DROP POLICY IF EXISTS "Users can read own daily editions" ON public.daily_editions;

CREATE POLICY "Users can read own daily editions"
  ON public.daily_editions FOR SELECT
  USING (auth.uid() = user_id);

-- Allow users to insert their own daily editions
DROP POLICY IF EXISTS "Users can insert own daily editions" ON public.daily_editions;

CREATE POLICY "Users can insert own daily editions"
  ON public.daily_editions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION is_profile_complete(UUID) IS 'Checks if a user has a complete profile (name, age, bio, interests, city, photos)';
COMMENT ON FUNCTION generate_daily_edition(UUID) IS 'Generates 3-5 daily curated candidates for a user, filtering by city/university and excluding existing matches';
