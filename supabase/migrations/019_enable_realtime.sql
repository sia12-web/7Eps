-- ============================================================================
-- ENABLE REALTIME ON ARTIFACTS TABLE
-- ============================================================================
-- This migration enables Supabase Realtime for the artifacts table
-- Realtime allows the Flutter app to receive live updates when new artifacts are submitted
-- This is essential for the "Book" timeline to show updates without manual refresh

-- ============================================================================
-- ENABLE REALTIME FOR ARTIFACTS TABLE
-- ============================================================================

-- Add artifacts table to the supabase_realtime publication
-- This allows authenticated clients to subscribe to INSERT events on this table
ALTER PUBLICATION supabase_realtime ADD TABLE public.artifacts;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check if artifacts table is in the publication
SELECT
  schemaname,
  tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename = 'artifacts';

-- Expected result: schemaname=public, tablename=artifacts

-- ============================================================================
-- NOTES FOR FLUTTER INTEGRATION
-- ============================================================================
--
-- In Flutter, you can now subscribe to artifact changes like this:
--
-- final channel = Supabase.instance.client
--     .channel('artifacts:$matchId')
--     .on(
--       RealtimeChannelEventType.postgresChanges,
--       ChannelFilter(
--         event: 'INSERT',
--         schema: 'public',
--         table: 'artifacts',
--         filter: 'match_id=eq.$matchId',
--       ),
--       (payload, [ref]) {
--         // Handle new artifact insertion
--         // Refresh timeline or update UI
--       },
--     )
--     .subscribe();
--
-- This will fire whenever a new artifact is inserted for the specified match.
-- The Flutter app can then refresh the timeline to show the new entry.
