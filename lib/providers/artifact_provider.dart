import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/match.dart';

class ArtifactState extends StateNotifier<AsyncValue<void>> {
  ArtifactState() : super(const AsyncValue.data(null));

  Future<void> submitArtifact({
    required String matchId,
    required String artifactType,
    required Map<String, dynamic> payload,
  }) async {
    debugPrint('🎨 ===== SUBMIT ARTIFACT =====');
    debugPrint('🎨 Match ID: $matchId');
    debugPrint('🎨 Artifact Type: $artifactType');
    debugPrint('🎨 Payload: $payload');

    state = const AsyncValue.loading();
    try {
      debugPrint('📤 Calling submit_artifact RPC...');
      final response = await Supabase.instance.client.rpc(
        'submit_artifact',
        params: {
          'p_match_id': matchId,
          'p_type': artifactType,
          'p_payload': payload,
        },
      );

      debugPrint('📦 Response received: $response');
      debugPrint('✅ Artifact submitted successfully');
      state = const AsyncValue.data(null);
      debugPrint('✅ ===== ARTIFACT SUBMISSION COMPLETE =====');
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
