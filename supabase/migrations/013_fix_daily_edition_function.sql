-- ============================================================================
-- FIX: Update generate_daily_edition to properly handle lenses
-- ============================================================================

-- Drop and recreate the function with correct structure
DROP FUNCTION IF EXISTS generate_daily_edition(UUID);

CREATE OR REPLACE FUNCTION generate_daily_edition(p_user_id UUID)
RETURNS TABLE(
  candidate_user_id UUID,
  candidate_name TEXT,
  candidate_age INT,
  candidate_city TEXT,
  candidate_photo_url TEXT,
  candidate_interests TEXT[],
  candidate_compatibility_hint TEXT,
  match_score NUMERIC,
  score_breakdown JSONB
) AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_existing_edition INT;
  v_user_interests JSONB;
  v_user_city TEXT;
  v_all_lenses JSONB := '[]'::jsonb;
  v_lens_count INT := 0;
  v_user_lenses RECORD;
BEGIN
  -- Check if edition already exists for today
  SELECT COUNT(*) INTO v_existing_edition
  FROM public.daily_editions
  WHERE user_id = p_user_id AND edition_date = v_today;

  -- Get user's interests and city
  SELECT interests, city INTO v_user_interests, v_user_city
  FROM public.profiles
  WHERE user_id = p_user_id;

  -- Get user's selected lenses (ordered by rank)
  FOR v_user_lenses IN
    SELECT l.weight_profile
    FROM public.user_lenses ul
    JOIN public.lenses l ON ul.lens_id = l.id
    WHERE ul.user_id = p_user_id
    ORDER BY ul.rank ASC
  LOOP
    v_all_lenses := v_all_lenses || v_user_lenses.weight_profile;
    v_lens_count := v_lens_count + 1;
  END LOOP;

  -- If no lenses selected, use default weight profile
  IF v_lens_count = 0 THEN
    v_all_lenses := ARRAY[
      '{"shared_interest_bonus": 1.0}'::jsonb
    ]::jsonb;
  END IF;

  -- If existing edition exists, return it
  IF v_existing_edition > 0 THEN
    RETURN QUERY
    WITH existing_data AS (
      SELECT
        de.candidate_user_ids[i] AS candidate_id,
        de.scoring_breakdown->i AS score_info
      FROM public.daily_editions de
      CROSS JOIN generate_subscripts(de.candidate_user_ids, 1) AS i
      WHERE de.user_id = p_user_id AND de.edition_date = v_today
    )
    SELECT
      ed.candidate_id,
      p.name,
      p.age,
      p.city,
      (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
      ARRAY(
        SELECT TRIM(interest->>'name')
        FROM jsonb_array_elements(p.interests) AS interest
        ORDER BY random() LIMIT 2
      ),
      COALESCE(ed.score_info->>'hint', 'Compatible connection'),
      (ed.score_info->>'score')::numeric,
      ed.score_info
    FROM existing_data ed
    JOIN public.profiles p ON p.user_id = ed.candidate_id;
    RETURN;
  END IF;

  -- Generate NEW daily edition with lens-weighted scoring
  WITH scored_candidates AS (
    SELECT
      p.user_id,
      p.name,
      p.age,
      p.city,
      p.interests,
      (SELECT url FROM public.profile_photos ph WHERE ph.user_id = p.user_id ORDER BY sort_order ASC LIMIT 1) as photo_url,

      -- Calculate shared interests count
      (
        SELECT COUNT(*)
        FROM jsonb_array_elements(p.interests) AS candidate_interest
        WHERE EXISTS (
          SELECT 1
          FROM jsonb_array_elements(v_user_interests) AS user_interest
          WHERE LOWER(user_interest->>'name') = LOWER(candidate_interest->>'name')
        )
      ) AS shared_interests_count,

      -- Calculate lens-weighted score
      (
        -- Base score from shared interests
        COALESCE(
          (
            SELECT COUNT(*)::numeric * 10.0
            FROM jsonb_array_elements(p.interests) AS candidate_interest
            WHERE EXISTS (
              SELECT 1
              FROM jsonb_array_elements(v_user_interests) AS user_interest
              WHERE LOWER(user_interest->>'name') = LOWER(candidate_interest->>'name')
            )
          ), 0
        ) *
        -- Apply lens bonus for shared interests
        COALESCE(
          (SELECT COALESCE(MAX((l->>'shared_interest_bonus')::numeric), 1.0)
           FROM jsonb_array_elements(v_all_lenses) AS l),
          1.0
        )
        +
        -- Distance/city bonus (same city = 15 points)
        CASE WHEN p.city = v_user_city AND p.city IS NOT NULL THEN 15 ELSE 0 END
        +
        -- Lens-based interest boosts
        COALESCE(
          (
            SELECT SUM(
              (l->'interest_boosts'->>(TRIM(interest->>'name')))::numeric
            )
            FROM jsonb_array_elements(p.interests) AS interest
            CROSS JOIN jsonb_array_elements(v_all_lenses) AS l
            WHERE (l->'interest_boosts' ? TRIM(interest->>'name'))
          ), 0
        )
        -
        -- Lens-based interest penalties
        COALESCE(
          (
            SELECT SUM(
              5.0 * (1.0 - (l->'interest_penalties'->>(TRIM(interest->>'name')))::numeric)
            )
            FROM jsonb_array_elements(p.interests) AS interest
            CROSS JOIN jsonb_array_elements(v_all_lenses) AS l
            WHERE (l->'interest_penalties' ? TRIM(interest->>'name'))
          ), 0
        )
        +
        -- Random factor for diversity (0-20 points)
        (random() * 20.0)
      ) AS total_score

    FROM public.profiles p
    WHERE
      p.user_id != p_user_id
      AND is_profile_complete(p.user_id) = TRUE
      AND p.age >= 18
      AND p.user_id NOT IN (
        SELECT mp2.user_id
        FROM public.match_participants mp1
        JOIN public.match_participants mp2 ON mp1.match_id = mp2.match_id
        WHERE mp1.user_id = p_user_id
      )
  )
  -- Insert top 5 scored candidates into daily_editions
  INSERT INTO public.daily_editions (user_id, edition_date, candidate_user_ids, scoring_breakdown)
  SELECT
    p_user_id,
    v_today,
    ARRAY_AGG(user_id ORDER BY total_score DESC),
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'candidate_id', user_id,
          'score', total_score,
          'shared_interests_count', shared_interests_count,
          'same_city', CASE WHEN city = v_user_city THEN true ELSE false END,
          'hint', (
            CASE
              WHEN shared_interests_count >= 3 THEN 'Strong shared interests'
              WHEN city = v_user_city THEN 'Same city connection'
              ELSE 'Complementary energies'
            END
          )
        )
        ORDER BY total_score DESC
      )
      FROM (
        SELECT * FROM scored_candidates ORDER BY total_score DESC LIMIT 5
      ) top_candidates
    )
  FROM (
    SELECT user_id, total_score, shared_interests_count, city
    FROM scored_candidates
    ORDER BY total_score DESC
    LIMIT 5
  ) top5;

  -- Return the newly created daily edition
  RETURN QUERY
  WITH new_data AS (
    SELECT
      de.candidate_user_ids[i] AS candidate_id,
      de.scoring_breakdown->i AS score_info
    FROM public.daily_editions de
    CROSS JOIN generate_subscripts(de.candidate_user_ids, 1) AS i
    WHERE de.user_id = p_user_id AND de.edition_date = v_today
  )
  SELECT
    nd.candidate_id,
    p.name,
    p.age,
    p.city,
    (SELECT url FROM public.profile_photos WHERE user_id = p.user_id ORDER BY sort_order ASC LIMIT 1),
    ARRAY(
      SELECT TRIM(interest->>'name')
      FROM jsonb_array_elements(p.interests) AS interest
      ORDER BY random() LIMIT 2
    ),
    (nd.score_info->>'hint'),
    (nd.score_info->>'score')::numeric,
    nd.score_info
  FROM new_data nd
  JOIN public.profiles p ON p.user_id = nd.candidate_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment
COMMENT ON FUNCTION generate_daily_edition IS 'Generates daily edition with lens-weighted scoring. Returns candidates with scores and breakdowns.';
