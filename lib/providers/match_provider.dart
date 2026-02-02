import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/match.dart';

class MatchState extends StateNotifier<AsyncValue<List<Match>>> {
  MatchState() : super(const AsyncValue.data([])) {
    _loadActiveJourneys();
  }

  Future<void> _loadActiveJourneys() async {
    debugPrint('🔄 ===== LOAD ACTIVE JOURNEYS =====');
    final userId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('🔄 User ID: $userId');

    if (userId == null) {
      debugPrint('⚠️ No user ID, setting journeys to empty');
      state = const AsyncValue.data([]);
      return;
    }

    try {
      debugPrint('🔍 Querying active journeys...');
      final response = await Supabase.instance.client
          .from('matches')
          .select('*, match_participants(user_id)')
          .eq('match_participants.user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      debugPrint('📦 Active journeys count: ${response.length}');
      final matches = (response as List<dynamic>)
          .map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Loaded ${matches.length} active journeys');
      state = AsyncValue.data(matches);
      debugPrint('✅ ===== ACTIVE JOURNEYS LOAD COMPLETE =====');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading journeys: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String?> startJourney(String candidateUserId) async {
    debugPrint('🚀 ===== START JOURNEY =====');
    final userId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('🚀 Current User ID: $userId');
    debugPrint('🚀 Candidate User ID: $candidateUserId');

    if (userId == null) {
      debugPrint('❌ ERROR: Not authenticated');
      throw Exception('Not authenticated');
    }

    if (userId == candidateUserId) {
      debugPrint('❌ ERROR: Cannot match with yourself');
      throw Exception('Cannot start a journey with yourself');
    }

    try {
      // Start a transaction to create match and participants
      // The enforce_max_active_journeys trigger will fire on participant insert
      debugPrint('➕ Creating match row...');

      final matchResponse = await Supabase.instance.client
          .from('matches')
          .insert({
            'status': 'active',
            'current_episode': 1,
          })
          .select('id')
          .single();

      final matchId = matchResponse['id'] as String;
      debugPrint('✅ Match created with ID: $matchId');

      debugPrint('➕ Adding participants...');
      try {
        await Supabase.instance.client.from('match_participants').insert([
          {'match_id': matchId, 'user_id': userId},
          {'match_id': matchId, 'user_id': candidateUserId},
        ]);
        debugPrint('✅ Participants added');
      } catch (e) {
        // If trigger fails (max 3 reached), clean up the match
        debugPrint('⚠️ Trigger raised exception, cleaning up match: $e');
        await Supabase.instance.client.from('matches').delete().eq('id', matchId);
        rethrow; // Re-throw so UI can handle it
      }

      // Refresh the active journeys list
      await _loadActiveJourneys();

      debugPrint('✅ ===== JOURNEY STARTED SUCCESSFULLY =====');
      return matchId;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR starting journey: $e');
      debugPrint('❌ StackTrace: $stackTrace');

      // Parse Postgres trigger error
      final errorString = e.toString();
      if (errorString.contains('Maximum 3 active journeys allowed')) {
        throw Exception(
            'You have 3 active journeys. Complete or end one to start a new journey.');
      }
      if (errorString.contains('duplicate key')) {
        throw Exception('You already have a journey with this person.');
      }

      rethrow;
    }
  }

  int get activeJourneyCount {
    return state.value?.length ?? 0;
  }

  Future<void> refresh() => _loadActiveJourneys();
}

final matchProvider =
    StateNotifierProvider<MatchState, AsyncValue<List<Match>>>((ref) {
  return MatchState();
});

/// Convenience provider to get active journey count
final activeJourneyCountProvider = Provider<int>((ref) {
  final matchState = ref.watch(matchProvider);
  return matchState.value?.length ?? 0;
});
