-- Migration: Storage Buckets and Policies
-- Description: Sets up Supabase Storage for profile photos and artifacts

-- Create storage buckets if they don't exist
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('artifacts', 'artifacts', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- PROFILE PHOTOS BUCKET POLICIES
-- ============================================================================

-- Public read access (anyone can view profile photos)
CREATE POLICY "Public read access to profile photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-photos');

-- Authenticated users can upload (to their own folder)
CREATE POLICY "Authenticated users can upload profile photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can delete their own photos
CREATE POLICY "Users can delete own profile photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update their own photos
CREATE POLICY "Users can update own profile photos"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================================
-- ARTIFACTS BUCKET POLICIES (Private, only match participants can access)
-- ============================================================================

-- Match participants can read artifacts
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

-- Match participants can upload artifacts
CREATE POLICY "Match participants can upload artifacts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
    )
  );

-- Match participants can delete artifacts
CREATE POLICY "Match participants can delete artifacts"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
    )
  );
