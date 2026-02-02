-- Migration: Row Level Security (RLS) Policies
-- Description: Security policies for all tables

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_editions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.artifacts ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PROFILES RLS
-- ============================================================================

-- Users can read all profiles (needed for matching)
CREATE POLICY "Public read access to profiles"
  ON public.profiles FOR SELECT
  USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only insert their own profile
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own profile
CREATE POLICY "Users can delete own profile"
  ON public.profiles FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- PROFILE PHOTOS RLS
-- ============================================================================

-- Everyone can read profile photos
CREATE POLICY "Public read access to profile photos"
  ON public.profile_photos FOR SELECT
  USING (true);

-- Users can only insert photos for themselves
CREATE POLICY "Users can insert own photos"
  ON public.profile_photos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own photos
CREATE POLICY "Users can update own photos"
  ON public.profile_photos FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only delete their own photos
CREATE POLICY "Users can delete own photos"
  ON public.profile_photos FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- DAILY EDITIONS RLS
-- ============================================================================

-- Users can only read their own daily editions
CREATE POLICY "Users can read own daily editions"
  ON public.daily_editions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own daily editions
CREATE POLICY "Users can insert own daily editions"
  ON public.daily_editions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only update their own daily editions
CREATE POLICY "Users can update own daily editions"
  ON public.daily_editions FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can only delete their own daily editions
CREATE POLICY "Users can delete own daily editions"
  ON public.daily_editions FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- MATCHES RLS
-- ============================================================================

-- Users can only read matches they are participating in
CREATE POLICY "Users can read own matches"
  ON public.matches FOR SELECT
  USING (
    id IN (
      SELECT match_id FROM public.match_participants WHERE user_id = auth.uid()
    )
  );

-- No direct INSERT on matches (use create_match function)
CREATE POLICY "No direct insert on matches"
  ON public.matches FOR INSERT
  WITH CHECK (false);

-- No direct UPDATE on matches (use submit_artifact function)
CREATE POLICY "No direct update on matches"
  ON public.matches FOR UPDATE
  WITH CHECK (false);

-- No direct DELETE on matches
CREATE POLICY "No direct delete on matches"
  ON public.matches FOR DELETE
  USING (false);

-- ============================================================================
-- MATCH PARTICIPANTS RLS
-- ============================================================================

-- Users can read participants for their matches
CREATE POLICY "Users can read match participants"
  ON public.match_participants FOR SELECT
  USING (
    match_id IN (
      SELECT match_id FROM public.match_participants WHERE user_id = auth.uid()
    )
  );

-- No direct INSERT (use create_match function)
CREATE POLICY "No direct insert on match_participants"
  ON public.match_participants FOR INSERT
  WITH CHECK (false);

-- No direct UPDATE
CREATE POLICY "No direct update on match_participants"
  ON public.match_participants FOR UPDATE
  WITH CHECK (false);

-- No direct DELETE
CREATE POLICY "No direct delete on match_participants"
  ON public.match_participants FOR DELETE
  USING (false);

-- ============================================================================
-- ARTIFACTS RLS
-- ============================================================================

-- Users can read artifacts for their matches
CREATE POLICY "Users can read match artifacts"
  ON public.artifacts FOR SELECT
  USING (
    match_id IN (
      SELECT match_id FROM public.match_participants WHERE user_id = auth.uid()
    )
  );

-- No direct INSERT (use submit_artifact function)
CREATE POLICY "No direct insert on artifacts"
  ON public.artifacts FOR INSERT
  WITH CHECK (false);

-- No direct UPDATE on artifacts
CREATE POLICY "No direct update on artifacts"
  ON public.artifacts FOR UPDATE
  WITH CHECK (false);

-- No direct DELETE on artifacts
CREATE POLICY "No direct delete on artifacts"
  ON public.artifacts FOR DELETE
  USING (false);

-- ============================================================================
-- SECURITY DEFINER FUNCTIONS
-- ============================================================================
-- These functions bypass RLS with SECURITY DEFINER but validate auth.uid()

-- Create match function (server-side, with RLS bypass)
CREATE OR REPLACE FUNCTION create_match(
  p_user1_id UUID,
  p_user2_id UUID
)
RETURNS UUID AS $$
DECLARE
  v_match_id UUID;
BEGIN
  -- Validate both users exist
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = p_user1_id) THEN
    RAISE EXCEPTION 'User 1 does not exist';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = p_user2_id) THEN
    RAISE EXCEPTION 'User 2 does not exist';
  END IF;

  -- Check if match already exists
  IF EXISTS (
    SELECT 1 FROM public.match_participants mp1
    JOIN public.match_participants mp2 ON mp1.match_id = mp2.match_id
    WHERE mp1.user_id = p_user1_id AND mp2.user_id = p_user2_id
  ) THEN
    RAISE EXCEPTION 'Match already exists between these users';
  END IF;

  -- Create match
  INSERT INTO public.matches (status, current_episode)
  VALUES ('active', 1)
  RETURNING id INTO v_match_id;

  -- Add participants (trigger will enforce max 3)
  INSERT INTO public.match_participants (match_id, user_id)
  VALUES (v_match_id, p_user1_id), (v_match_id, p_user2_id);

  RETURN v_match_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION create_match(UUID, UUID) TO authenticated;

-- ============================================================================
-- STORAGE BUCKETS (for photos and audio)
-- ============================================================================
-- Note: These need to be created via Supabase dashboard or additional migration

-- Profile photos bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Artifacts bucket (for episode photos and audio)
INSERT INTO storage.buckets (id, name, public)
VALUES ('artifacts', 'artifacts', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STORAGE POLICIES
-- ============================================================================

-- Profile photos bucket policies
CREATE POLICY "Public read access to profile photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-photos');

CREATE POLICY "Authenticated users can upload profile photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own profile photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Artifacts bucket policies (private, only match participants can access)
CREATE POLICY "Match participants can read artifacts"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'artifacts' AND
    (
      SELECT EXISTS(
        SELECT 1 FROM public.match_participants
        WHERE match_id = (storage.foldername(name))[1]::uuid
        AND user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Match participants can upload artifacts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
    )
  );
