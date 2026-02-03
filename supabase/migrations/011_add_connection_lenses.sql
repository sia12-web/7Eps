-- ============================================================================
-- CONNECTION LENSES FEATURE
-- ============================================================================
-- Lenses: Vibe preferences that adjust matching weights (NOT hard filters)
-- Users select exactly 3 lenses from a fixed set of 8

-- ============================================================================
-- LENSES TABLE (Fixed set of 8 lenses)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.lenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL, -- e.g., 'calm_cozy', 'active_energetic'
  name TEXT NOT NULL, -- e.g., 'Calm & Cozy'
  description TEXT NOT NULL,

  -- Weight profile for scoring (JSONB)
  -- Structure: {
  --   "interest_boosts": {"Reading": 2.0, "Coffee": 1.5, ...},
  --   "interest_penalties": {"Parties": 0.5, "Nightlife": 0.3, ...},
  --   "distance_multiplier": 1.0,
  --   "shared_interest_bonus": 1.5
  -- }
  weight_profile JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- Example signals for UI display (3-5 examples)
  example_signals TEXT[] DEFAULT '{}'::text[],

  sort_order INT NOT NULL, -- For consistent UI ordering

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- USER_LENSES TABLE (Users' selected lenses)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_lenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  lens_id UUID NOT NULL REFERENCES public.lenses(id) ON DELETE CASCADE,

  -- Rank 1-3 (user's priority order)
  rank INT NOT NULL CHECK (rank BETWEEN 1 AND 3),

  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Ensure user can only select each lens once
  UNIQUE(user_id, lens_id),

  -- Ensure user has exactly 3 lenses (enforced at application level)
  CHECK (rank BETWEEN 1 AND 3)
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_user_lenses_user_id ON public.user_lenses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_lenses_rank ON public.user_lenses(user_id, rank);
CREATE INDEX IF NOT EXISTS idx_lenses_key ON public.lenses(key);
CREATE INDEX IF NOT EXISTS idx_lenses_sort_order ON public.lenses(sort_order);

-- ============================================================================
-- UPDATE DAILY_EDITIONS TABLE (Add scoring breakdown)
-- ============================================================================
ALTER TABLE public.daily_editions
  ADD COLUMN IF NOT EXISTS scoring_breakdown JSONB;

COMMENT ON COLUMN public.daily_editions.scoring_breakdown IS 'Debug info: Shows how lenses affected scoring for each candidate';

-- ============================================================================
-- SEED DATA: 8 LENSES
-- ============================================================================
INSERT INTO public.lenses (key, name, description, weight_profile, example_signals, sort_order) VALUES
(
  'calm_cozy',
  'Calm & Cozy',
  'Quiet moments, cozy cafes, slow weekends',
  '{
    "interest_boosts": {
      "Reading": 2.5, "Coffee": 2.0, "Meditation": 2.0, "Yoga": 1.8,
      "Writing": 1.8, "Art": 1.5, "Museums": 1.5, "Quiet Nights": 2.0,
      "Books": 2.0, "Board Games": 1.5, "Baking": 1.5, "Mindfulness": 2.0
    },
    "interest_penalties": {
      "Parties": 0.3, "Nightlife": 0.3, "Gaming": 0.7
    },
    "distance_multiplier": 1.2,
    "shared_interest_bonus": 1.8,
    "energy_preference": "low"
  }'::jsonb,
  ARRAY['Reading', 'Coffee shops', 'Slow weekends', 'Cozy nights', 'Quiet time'],
  1
),
(
  'active_energetic',
  'Active & Energetic',
  'Gym, outdoor adventures, early mornings, high energy',
  '{
    "interest_boosts": {
      "Gym": 2.5, "Running": 2.5, "Hiking": 2.3, "Cycling": 2.0,
      "Rock Climbing": 2.3, "Swimming": 2.0, "Tennis": 2.0, "Soccer": 2.0,
      "Basketball": 2.0, "Adventure": 2.0, "Fitness": 2.3, "Sports": 2.0
    },
    "interest_penalties": {
      "Quiet Nights": 0.5, "Netflix": 0.7
    },
    "distance_multiplier": 0.8,
    "shared_interest_bonus": 2.0,
    "energy_preference": "high"
  }'::jsonb,
  ARRAY['Gym', 'Outdoor adventures', 'Early mornings', 'Active lifestyle', 'Sports'],
  2
),
(
  'values_roots',
  'Values & Roots',
  'Faith, family, tradition, long-term mindset',
  '{
    "interest_boosts": {
      "Volunteering": 2.0, "Sustainability": 1.8, "Politics": 1.5,
      "Philosophy": 1.8, "Religion": 2.5, "History": 1.5, "Family": 2.5,
      "Community": 2.0, "Tradition": 2.0
    },
    "interest_penalties": {},
    "distance_multiplier": 1.5,
    "shared_interest_bonus": 2.2,
    "values_preference": "traditional"
  }'::jsonb,
  ARRAY['Faith important', 'Family-oriented', 'Long-term mindset', 'Community', 'Tradition'],
  3
),
(
  'creative_curious',
  'Creative & Curious',
  'Arts, music, exploring, deep conversations',
  '{
    "interest_boosts": {
      "Art": 2.5, "Music": 2.5, "Photography": 2.3, "Writing": 2.0,
      "Design": 2.0, "Fashion": 1.8, "Music Production": 2.3, "Museums": 2.0,
      "Theater": 2.0, "Dance": 2.0, "Podcasts": 1.8, "Learning": 2.0,
      "Creativity": 2.5, "Curiosity": 2.0
    },
    "interest_penalties": {},
    "distance_multiplier": 1.0,
    "shared_interest_bonus": 2.0,
    "creativity_preference": "high"
  }'::jsonb,
  ARRAY['Arts & culture', 'Music', 'Exploring new things', 'Deep talks', 'Creating'],
  4
),
(
  'social_spontaneous',
  'Social & Spontaneous',
  'Events, extroversion, last-minute plans',
  '{
    "interest_boosts": {
      "Parties": 2.5, "Festivals": 2.3, "Concerts": 2.3, "Dining Out": 2.0,
      "Networking": 2.0, "Hosting": 2.0, "Brunch": 1.8, "Travel": 1.8,
      "Socializing": 2.5, "Events": 2.3
    },
    "interest_penalties": {
      "Quiet Nights": 0.4, "Reading": 0.8
    },
    "distance_multiplier": 0.7,
    "shared_interest_bonus": 1.8,
    "social_preference": "high"
  }'::jsonb,
  ARRAY['Social events', 'Spontaneous plans', 'Extroverted energy', 'Nightlife', 'Meeting people'],
  5
),
(
  'healthy_grounded',
  'Healthy & Grounded',
  'Balanced habits, low drama, routines, wellness',
  '{
    "interest_boosts": {
      "Yoga": 2.3, "Meditation": 2.3, "Mindfulness": 2.5, "Nature": 2.0,
      "Sustainability": 2.0, "Volunteering": 1.8, "Cooking": 1.8,
      "Wellness": 2.5, "Balance": 2.0, "Self-care": 2.0, "Health": 2.0
    },
    "interest_penalties": {
      "Parties": 0.6, "Drama": 0.3
    },
    "distance_multiplier": 1.1,
    "shared_interest_bonus": 1.9,
    "lifestyle_preference": "balanced"
  }'::jsonb,
  ARRAY['Wellness routines', 'Low drama', 'Mindfulness', 'Balance', 'Healthy habits'],
  6
),
(
  'ambitious_driven',
  'Ambitious & Driven',
  'Career focus, growth mindset, building things',
  '{
    "interest_boosts": {
      "Technology": 2.3, "Science": 2.0, "Business": 2.3, "Networking": 2.0,
      "Learning": 2.0, "Languages": 1.8, "Leadership": 2.3, "Entrepreneurship": 2.5,
      "Career": 2.5, "Ambition": 2.3, "Growth": 2.0
    },
    "interest_penalties": {},
    "distance_multiplier": 0.9,
    "shared_interest_bonus": 2.0,
    "ambition_preference": "high"
  }'::jsonb,
  ARRAY['Career-focused', 'Growth mindset', 'Building projects', 'Ambitious goals', 'Entrepreneurship'],
  7
),
(
  'humorous_playful',
  'Humorous & Playful',
  'Memes, banter, lightheartedness, fun',
  '{
    "interest_boosts": {
      "Comedy": 2.5, "Gaming": 2.0, "Board Games": 2.0, "Concerts": 1.8,
      "Festivals": 1.8, "Netflix": 1.5, "Movies": 1.5, "Travel": 1.5,
      "Humor": 2.5, "Fun": 2.0, "Playfulness": 2.0
    },
    "interest_penalties": {},
    "distance_multiplier": 1.0,
    "shared_interest_bonus": 1.8,
    "humor_preference": "high"
  }'::jsonb,
  ARRAY['Love memes', 'Banter & jokes', 'Lighthearted', 'Fun & playful', 'Comedy'],
  8
)
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- FUNCTION: GET USER LENSES
-- ============================================================================
CREATE OR REPLACE FUNCTION get_user_lenses(p_user_id UUID)
RETURNS TABLE(
  lens_id UUID,
  lens_key TEXT,
  lens_name TEXT,
  lens_description TEXT,
  weight_profile JSONB,
  example_signals TEXT[],
  rank INT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    l.id,
    l.key,
    l.name,
    l.description,
    l.weight_profile,
    l.example_signals,
    ul.rank
  FROM public.user_lenses ul
  JOIN public.lenses l ON ul.lens_id = l.id
  WHERE ul.user_id = p_user_id
  ORDER BY ul.rank ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_user_lenses(UUID) TO authenticated;

-- ============================================================================
-- FUNCTION: SAVE USER LENSES
-- ============================================================================
CREATE OR REPLACE FUNCTION save_user_lenses(
  p_lens_ids UUID[],
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS JSONB AS $$
DECLARE
  v_count INT;
BEGIN
  -- Validate exactly 3 lenses
  v_count := array_length(p_lens_ids, 1);
  IF v_count != 3 THEN
    RAISE EXCEPTION 'Must select exactly 3 lenses, got %', v_count;
  END IF;

  -- Delete existing lenses for user
  DELETE FROM public.user_lenses WHERE user_id = p_user_id;

  -- Insert new lenses with rank
  INSERT INTO public.user_lenses (user_id, lens_id, rank)
  SELECT p_user_id, unnest(p_lens_ids), generate_series(1, 3);

  -- Return success
  RETURN jsonb_build_object(
    'success', true,
    'lens_count', v_count
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION save_user_lenses(UUID[], UUID) TO authenticated;

-- ============================================================================
-- RLS POLICIES FOR NEW TABLES
-- ============================================================================
ALTER TABLE public.lenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_lenses ENABLE ROW LEVEL SECURITY;

-- Lenses: Everyone can read, no one can modify (fixed set)
CREATE POLICY "Public read access to lenses"
  ON public.lenses FOR SELECT
  USING (true);

CREATE POLICY "No insert on lenses"
  ON public.lenses FOR INSERT
  WITH CHECK (false);

CREATE POLICY "No update on lenses"
  ON public.lenses FOR UPDATE
  WITH CHECK (false);

CREATE POLICY "No delete on lenses"
  ON public.lenses FOR DELETE
  USING (false);

-- User lenses: Users can read their own, insert/update/delete their own
CREATE POLICY "Users can read own lenses"
  ON public.user_lenses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lenses"
  ON public.user_lenses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lenses"
  ON public.user_lenses FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lenses"
  ON public.user_lenses FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON TABLE public.lenses IS 'Fixed set of 8 vibe preference lenses with weight profiles';
COMMENT ON TABLE public.user_lenses IS 'Users'' selected 3 lenses (ranked 1-3)';
COMMENT ON COLUMN public.lenses.weight_profile IS 'JSONB config for scoring: interest boosts/penalties, multipliers';
COMMENT ON COLUMN public.user_lenses.rank IS 'Priority rank (1=highest priority)';
