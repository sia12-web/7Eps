-- Migration: Update Daily Edition Generation
-- Description: Drop and recreate function with new return type including interests

-- Drop existing function first
DROP FUNCTION IF EXISTS generate_daily_edition(UUID);

-- Recreate helper function without bio check
CREATE OR REPLACE FUNCTION is_profile_complete(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_profile RECORD;
  v_photo_count INT;
BEGIN
  SELECT * INTO v_profile FROM public.profiles WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_profile.name IS NULL OR v_profile.name = '' THEN
    RETURN FALSE;
  END IF;

  IF v_profile.age < 18 THEN
    RETURN FALSE;
  END IF;

  IF v_profile.city IS NULL OR v_profile.city = '' THEN
    RETURN FALSE;
  END IF;

  IF v_profile.interests IS NULL OR jsonb_array_length(v_profile.interests) < 5 THEN
    RETURN FALSE;
  END IF;

  SELECT COUNT(*) INTO v_photo_count
  FROM public.profile_photos
  WHERE user_id = p_user_id;

  IF v_photo_count = 0 THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create new function with interests and compatibility hints
CREATE OR REPLACE FUNCTION generate_daily_edition(p_user_id UUID)
RETURNS TABLE(
  candidate_user_id UUID,
  candidate_name TEXT,
  candidate_age INT,
  candidate_city TEXT,
  candidate_photo_url TEXT,
  candidate_interests TEXT[],
  candidate_compatibility_hint TEXT
) AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_existing_edition INT;
BEGIN
  -- Check if edition already exists for today
  SELECT COUNT(*) INTO v_existing_edition
  FROM public.daily_editions
  WHERE user_id = p_user_id AND edition_date = v_today;

  IF v_existing_edition > 0 THEN
    -- Return existing candidates with interests
    RETURN QUERY
    SELECT
      unnest(de.candidate_user_ids),
      p.name,
      p.age,
      p.city,
      (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
      ARRAY(
        SELECT TRIM(interest->>'name')
        FROM jsonb_array_elements(p.interests) AS interest
        ORDER BY random()
        LIMIT 2
      ),
      (ARRAY['Shared lifestyle rhythm', 'Similar values', 'Complementary energies', 'Common ground', 'Aligned paths'])[floor(random() * 5)]
    FROM public.daily_editions de
    CROSS JOIN unnest(de.candidate_user_ids) AS candidate_id
    JOIN public.profiles p ON p.user_id = candidate_id
    WHERE de.user_id = p_user_id AND de.edition_date = v_today;
    RETURN;
  END IF;

  -- Generate new daily edition
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
      -- Age requirement
      AND p.age >= 18
      -- Not already matched
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

  -- Return the newly created daily edition
  RETURN QUERY
    SELECT
      unnest(de.candidate_user_ids),
      p.name,
      p.age,
      p.city,
      (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
      ARRAY(
        SELECT TRIM(interest->>'name')
        FROM jsonb_array_elements(p.interests) AS interest
        ORDER BY random() LIMIT 2
      ),
      (ARRAY['Shared lifestyle rhythm', 'Similar values', 'Complementary energies', 'Common ground', 'Aligned paths'])[floor(random() * 5)]
    FROM public.daily_editions de
    CROSS JOIN unnest(de.candidate_user_ids) AS candidate_id
    JOIN public.profiles p ON p.user_id = candidate_id
    WHERE de.user_id = p_user_id AND de.edition_date = v_today;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION generate_daily_edition(UUID) TO authenticated;
