import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/match.dart';

class ArtifactState extends StateNotifier<AsyncValue<void>> {
  ArtifactState() : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> submitArtifact({
    required String matchId,
    required String artifactType,
    required Map<String, dynamic> payload,
    String? promptId,
  }) async {
    debugPrint('🎨 ===== SUBMIT ARTIFACT =====');
    debugPrint('🎨 Match ID: $matchId');
    debugPrint('🎨 Artifact Type: $artifactType');
    debugPrint('🎨 Prompt ID: $promptId');
    debugPrint('🎨 Payload: $payload');

    state = const AsyncValue.loading();
    try {
      debugPrint('📤 Calling submit_artifact RPC...');

      final params = <String, dynamic>{
        'p_match_id': matchId,
        'p_type': artifactType,
        'p_payload': payload,
      };

      if (promptId != null) {
        params['p_prompt_id'] = promptId;
      }

      final response = await Supabase.instance.client.rpc(
        'submit_artifact',
        params: params,
      );

      debugPrint('📦 Response received: $response');

      final result = response as Map<String, dynamic>;
      state = const AsyncValue.data(null);

      debugPrint('✅ Artifact submitted successfully');
      debugPrint('   - Episode: ${result['episode']}');
      debugPrint('   - Episode completed: ${result['episode_completed']}');
      debugPrint('   - New episode: ${result['new_episode']}');
      debugPrint('   - Partner submitted: ${result['partner_submitted']}');
      debugPrint('   - Prompt ID: ${result['prompt_id']}');
      debugPrint('✅ ===== ARTIFACT SUBMISSION COMPLETE =====');

      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR submitting artifact: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final artifactProvider =
    StateNotifierProvider<ArtifactState, AsyncValue<void>>((ref) {
  return ArtifactState();
});
