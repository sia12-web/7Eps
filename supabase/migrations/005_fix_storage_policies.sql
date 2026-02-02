-- Fix storage policies to prevent infinite recursion

-- Drop all existing storage policies
DROP POLICY IF EXISTS "Public read access to profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Match participants can read artifacts" ON storage.objects;
DROP POLICY IF EXISTS "Match participants can upload artifacts" ON storage.objects;
DROP POLICY IF EXISTS "Match participants can delete artifacts" ON storage.objects;

-- ============================================================================
-- PROFILE PHOTOS BUCKET POLICIES (Fixed)
-- ============================================================================

-- Public read access for profile photos
CREATE POLICY "Public read access to profile photos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'profile-photos');

-- Authenticated users can upload profile photos (no folder check to avoid recursion)
CREATE POLICY "Authenticated upload profile photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'profile-photos');

-- Users can delete their own photos
CREATE POLICY "Users delete own profile photos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update their own photos
CREATE POLICY "Users update own profile photos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'profile-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================================
-- ARTIFACTS BUCKET POLICIES (Fixed - with TO clause)
-- ============================================================================

-- Match participants can read artifacts
CREATE POLICY "Match participants read artifacts"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
    )
  );

-- Match participants can upload artifacts
CREATE POLICY "Match participants upload artifacts"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
      LIMIT 1
    )
  );

-- Match participants can delete artifacts
CREATE POLICY "Match participants delete artifacts"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'artifacts' AND
    auth.uid() IN (
      SELECT user_id FROM public.match_participants
      WHERE match_id = (storage.foldername(name))[1]::uuid
      LIMIT 1
    )
  );
