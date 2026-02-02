-- Add onboarding tracking fields to profiles table
-- Migration 009: Multi-step onboarding support

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_step INT DEFAULT 1 CHECK (onboarding_step BETWEEN 0 AND 11),
  ADD COLUMN IF NOT EXISTS dob DATE,
  ADD COLUMN IF NOT EXISTS pronouns TEXT,
  ADD COLUMN IF NOT EXISTS headline TEXT,
  ADD COLUMN IF NOT EXISTS gender_interest TEXT DEFAULT 'everyone' CHECK (gender_interest IN ('men', 'women', 'everyone')),
  ADD COLUMN IF NOT EXISTS age_min INT DEFAULT 18 CHECK (age_min >= 18),
  ADD COLUMN IF NOT EXISTS age_max INT DEFAULT 100 CHECK (age_max >= age_min),
  ADD COLUMN IF NOT EXISTS distance_radius INT DEFAULT 50 CHECK (distance_radius BETWEEN 10 AND 200),
  ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS safety_agreement_accepted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;

-- Add index for onboarding queries
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding_step ON public.profiles(onboarding_step);

-- Add comments for documentation
COMMENT ON COLUMN public.profiles.onboarding_step IS 'Current step in onboarding flow (0=not started, 1-10=active steps, 11=completed)';
COMMENT ON COLUMN public.profiles.dob IS 'Date of birth for age verification';
COMMENT ON COLUMN public.profiles.pronouns IS 'User pronouns (he/him, she/her, they/them, custom)';
COMMENT ON COLUMN public.profiles.headline IS 'One-line personality headline (max 100 chars)';
COMMENT ON COLUMN public.profiles.gender_interest IS 'Dating preference: men, women, or everyone';
COMMENT ON COLUMN public.profiles.age_min IS 'Minimum preferred age for matches (18+)';
COMMENT ON COLUMN public.profiles.age_max IS 'Maximum preferred age for matches';
COMMENT ON COLUMN public.profiles.distance_radius IS 'Maximum distance in km for matches (10-200)';
COMMENT ON COLUMN public.profiles.terms_accepted_at IS 'Timestamp when user accepted terms of service';
COMMENT ON COLUMN public.profiles.safety_agreement_accepted_at IS 'Timestamp when user accepted community guidelines';
COMMENT ON COLUMN public.profiles.onboarding_completed_at IS 'Timestamp when onboarding was completed';
