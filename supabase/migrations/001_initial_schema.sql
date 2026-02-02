-- Migration: Initial Schema
-- Description: Creates all core tables for Love Journey dating app

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  age INT NOT NULL CHECK (age >= 18),
  bio TEXT,
  interests JSONB DEFAULT '[]'::jsonb,
  city TEXT,
  university TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index on city for matching
CREATE INDEX IF NOT EXISTS idx_profiles_city ON public.profiles(city);
CREATE INDEX IF NOT EXISTS idx_profiles_university ON public.profiles(university);

-- ============================================================================
-- PROFILE PHOTOS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profile_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  sort_order INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index for fetching user photos
CREATE INDEX IF NOT EXISTS idx_profile_photos_user_id ON public.profile_photos(user_id);

-- ============================================================================
-- DAILY EDITIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.daily_editions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  edition_date DATE NOT NULL,
  candidate_user_ids UUID[] DEFAULT '{}'::uuid[],
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, edition_date)
);

-- Create index for fetching daily edition
CREATE INDEX IF NOT EXISTS idx_daily_editions_user_date ON public.daily_editions(user_id, edition_date DESC);

-- ============================================================================
-- MATCHES (JOURNEYS) TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  status TEXT DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'archived', 'completed')),
  current_episode INT DEFAULT 1 NOT NULL CHECK (current_episode BETWEEN 1 AND 8),
  completed_at TIMESTAMPTZ
);

-- Create index for fetching active matches
CREATE INDEX IF NOT EXISTS idx_matches_status ON public.matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_created ON public.matches(created_at DESC);

-- ============================================================================
-- MATCH PARTICIPANTS TABLE (Many-to-Many)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.match_participants (
  match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(match_id, user_id)
);

-- Create index for fetching user's matches
CREATE INDEX IF NOT EXISTS idx_match_participants_user_id ON public.match_participants(user_id);

-- ============================================================================
-- ARTIFACTS TABLE (Episode Submissions)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.artifacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  episode INT NOT NULL CHECK (episode BETWEEN 1 AND 7),
  type TEXT NOT NULL CHECK (type IN ('prompt_answer', 'voice', 'photo', 'tags', 'dealbreakers', 'scenario', 'date_choice')),
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index for fetching artifacts by match and episode
CREATE INDEX IF NOT EXISTS idx_artifacts_match_episode ON public.artifacts(match_id, episode);
CREATE INDEX IF NOT EXISTS idx_artifacts_created ON public.artifacts(created_at DESC);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Helper function to validate artifact type for current episode
CREATE OR REPLACE FUNCTION validate_artifact_type_for_episode(
  current_episode INT,
  artifact_type TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  CASE current_episode
    WHEN 1 THEN RETURN artifact_type = 'prompt_answer';
    WHEN 2 THEN RETURN artifact_type = 'voice';
    WHEN 3 THEN RETURN artifact_type = 'tags';
    WHEN 4 THEN RETURN artifact_type = 'photo';
    WHEN 5 THEN RETURN artifact_type = 'dealbreakers';
    WHEN 6 THEN RETURN artifact_type = 'scenario';
    WHEN 7 THEN RETURN artifact_type = 'date_choice';
    ELSE RETURN FALSE;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Updated at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger to enforce max 3 active journeys
CREATE OR REPLACE FUNCTION enforce_max_active_journeys()
RETURNS TRIGGER AS $$
DECLARE
  v_active_count INT;
BEGIN
  -- Count active journeys for user attempting to join a new match
  IF TG_OP = 'INSERT' THEN
    SELECT COUNT(*) INTO v_active_count
    FROM public.match_participants mp
    JOIN public.matches m ON m.id = mp.match_id
    WHERE mp.user_id = NEW.user_id
      AND m.status = 'active'
      AND m.current_episode <= 7;

    IF v_active_count >= 3 THEN
      RAISE EXCEPTION 'Maximum 3 active journeys allowed. You currently have active journeys.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger on match_participants
DROP TRIGGER IF EXISTS check_max_active_journeys ON public.match_participants;
CREATE TRIGGER check_max_active_journeys
  BEFORE INSERT ON public.match_participants
  FOR EACH ROW
  EXECUTE FUNCTION enforce_max_active_journeys();

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON TABLE public.profiles IS 'User profiles with demographic information';
COMMENT ON TABLE public.profile_photos IS 'User profile photos with sorting';
COMMENT ON TABLE public.daily_editions IS 'Daily curated matches (3-5 candidates per day)';
COMMENT ON TABLE public.matches IS 'Matches/Journeys between two users';
COMMENT ON TABLE public.match_participants IS 'Many-to-many relationship between matches and users';
COMMENT ON TABLE public.artifacts IS 'Episode submissions (artifacts) from users';

COMMENT ON COLUMN public.matches.status IS 'active: currently progressing, archived: user ended it, completed: all 7 episodes done';
COMMENT ON COLUMN public.matches.current_episode IS 'Current episode number (1-7), 8 means completed';
COMMENT ON COLUMN public.artifacts.payload IS 'Flexible JSONB payload containing artifact content based on type';
