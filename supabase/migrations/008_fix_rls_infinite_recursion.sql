-- Migration: Fix RLS infinite recursion
-- Description: Fix infinite recursion in match_participants and matches RLS policies

-- The issue: SELECT policies that query the same table cause infinite recursion
-- Solution: Use a SECURITY DEFINER helper function to bypass RLS

-- ============================================================================
-- HELPER FUNCTION: Get user's match IDs (bypasses RLS)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_match_ids(p_user_id UUID)
RETURNS SETOF UUID AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT match_id
  FROM public.match_participants
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION get_user_match_ids(UUID) TO authenticated;

-- ============================================================================
-- FIX MATCH PARTICIPANTS RLS
-- ============================================================================

-- Drop the problematic SELECT policy
DROP POLICY IF EXISTS "Users can read match participants" ON public.match_participants;

-- Create new policy using the helper function (no recursion)
CREATE POLICY "Users can read match participants"
  ON public.match_participants FOR SELECT
  USING (
    match_id IN (
      SELECT get_user_match_ids(auth.uid())
    )
  );

-- Drop the restrictive INSERT policy
DROP POLICY IF EXISTS "No direct insert on match_participants" ON public.match_participants;

-- Allow INSERT (trigger will enforce max 3)
DROP POLICY IF EXISTS "Users can insert match participants" ON public.match_participants;
CREATE POLICY "Users can insert match participants"
  ON public.match_participants FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FIX MATCHES RLS
-- ============================================================================

-- Drop the problematic SELECT policy
DROP POLICY IF EXISTS "Users can read own matches" ON public.matches;

-- Create new policy using the helper function (no recursion)
CREATE POLICY "Users can read own matches"
  ON public.matches FOR SELECT
  USING (
    id IN (
      SELECT get_user_match_ids(auth.uid())
    )
  );

-- Drop the restrictive INSERT policy
DROP POLICY IF EXISTS "No direct insert on matches" ON public.matches;
DROP POLICY IF EXISTS "Authenticated users can create matches" ON public.matches;

-- Allow INSERT for authenticated users
CREATE POLICY "Authenticated users can create matches"
  ON public.matches FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- FIX ARTIFACTS RLS (if it has the same issue)
-- ============================================================================

-- Drop the problematic SELECT policy
DROP POLICY IF EXISTS "Users can read match artifacts" ON public.artifacts;

-- Create new policy using the helper function (no recursion)
CREATE POLICY "Users can read match artifacts"
  ON public.artifacts FOR SELECT
  USING (
    match_id IN (
      SELECT get_user_match_ids(auth.uid())
    )
  );
