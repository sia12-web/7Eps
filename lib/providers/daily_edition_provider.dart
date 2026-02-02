import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/candidate.dart';

class DailyEditionState extends StateNotifier<AsyncValue<List<Candidate>>> {
  DailyEditionState() : super(const AsyncValue.loading()) {
    loadDailyEdition();
  }

  Future<void> loadDailyEdition() async {
    debugPrint('📰 ===== LOAD DAILY EDITION =====');
    final userId = Supabase.instance.client.auth.currentUser?.id;
    debugPrint('📰 User ID: $userId');

    if (userId == null) {
      debugPrint('⚠️ No user ID, setting candidates to empty');
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Call Postgres function to generate/fetch daily edition
      debugPrint('🔍 Calling generate_daily_edition function...');
      debugPrint('🔍 Params: {p_user_id: $userId}');

      final response = await Supabase.instance.client.rpc(
        'generate_daily_edition',
        params: {'p_user_id': userId},
      );

      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Response received: ${response != null}');

      if (response != null) {
        debugPrint('📦 Response toString: $response');
      }

      if (response == null) {
        debugPrint('⚠️ No candidates available (response is null)');
        state = const AsyncValue.data([]);
        return;
      }

      // Check response type before parsing
      if (response is! List) {
        debugPrint('❌ ERROR: Expected List but got ${response.runtimeType}');
        debugPrint('❌ Response data: $response');
        state = AsyncValue.data([]);
        return;
      }

      // Parse response as list of candidates
      final List<dynamic> dataList = response as List<dynamic>;
      debugPrint('📦 Candidates count: ${dataList.length}');

      if (dataList.isEmpty) {
        debugPrint('⚠️ No candidates available (empty list)');
        state = const AsyncValue.data([]);
        return;
      }

      final candidates = <Candidate>[];
      for (var i = 0; i < dataList.length; i++) {
        try {
          final item = dataList[i];
          debugPrint('📦 Parsing candidate $i: $item');
          final candidate = Candidate.fromJson(item as Map<String, dynamic>);
          candidates.add(candidate);
          debugPrint('   ✅ Parsed: ${candidate.name}');
        } catch (e) {
          debugPrint('   ❌ Error parsing candidate $i: $e');
          debugPrint('   ❌ Item data: ${dataList[i]}');
        }
      }

      debugPrint('✅ Daily Edition loaded: ${candidates.length} candidates');
      for (var i = 0; i < candidates.length; i++) {
        debugPrint('   ${i + 1}. ${candidates[i].name} (${candidates[i].age}) - ${candidates[i].tagline}');
      }

      state = AsyncValue.data(candidates);
      debugPrint('✅ ===== DAILY EDITION LOAD COMPLETE =====');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading daily edition: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() => loadDailyEdition();
}

final dailyEditionProvider =
    StateNotifierProvider<DailyEditionState, AsyncValue<List<Candidate>>>((ref) {
  return DailyEditionState();
});

/// Convenience provider to get the current candidates list
final currentCandidatesProvider = Provider<List<Candidate>>((ref) {
  final asyncCandidates = ref.watch(dailyEditionProvider);
  return asyncCandidates.value ?? [];
});
