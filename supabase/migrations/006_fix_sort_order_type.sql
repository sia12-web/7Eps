-- Fix sort_order column type from INT to BIGINT to support millisecond timestamps

-- First, we need to recreate the table with the correct column type
-- Drop the existing table
DROP TABLE IF EXISTS public.profile_photos CASCADE;

-- Recreate with BIGINT for sort_order
CREATE TABLE IF NOT EXISTS public.profile_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  sort_order BIGINT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS profile_photos_user_id_idx ON public.profile_photos(user_id);

-- Enable RLS
ALTER TABLE public.profile_photos ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profile_photos
DROP POLICY IF EXISTS "Public read access to profile photos" ON public.profile_photos;
DROP POLICY IF EXISTS "Users can insert own photos" ON public.profile_photos;
DROP POLICY IF EXISTS "Users can update own photos" ON public.profile_photos;
DROP POLICY IF EXISTS "Users can delete own photos" ON public.profile_photos;

CREATE POLICY "Public read access to profile photos"
  ON public.profile_photos FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own photos"
  ON public.profile_photos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own photos"
  ON public.profile_photos FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own photos"
  ON public.profile_photos FOR DELETE
  USING (auth.uid() = user_id);
