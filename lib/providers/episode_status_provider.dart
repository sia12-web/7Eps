import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Episode status model for tracking submission state
class EpisodeStatus {
  final int currentEpisode;
  final bool iSubmitted;
  final bool partnerSubmitted;
  final bool bothSubmitted;
  final bool canViewPartnerArtifact;
  final String? promptId;
  final String? promptText;
  final int nextEpisode;

  EpisodeStatus({
    required this.currentEpisode,
    required this.iSubmitted,
    required this.partnerSubmitted,
    required this.bothSubmitted,
    required this.canViewPartnerArtifact,
    required this.nextEpisode,
    this.promptId,
    this.promptText,
  });

  /// Create EpisodeStatus from JSON response
  factory EpisodeStatus.fromJson(Map<String, dynamic> json) {
    return EpisodeStatus(
      currentEpisode: json['current_episode'] as int,
      iSubmitted: json['i_submitted'] as bool,
      partnerSubmitted: json['partner_submitted'] as bool,
      bothSubmitted: json['both_submitted'] as bool,
      canViewPartnerArtifact: json['can_view_partner_artifact'] as bool,
      promptId: json['prompt_id'] as String?,
      promptText: json['prompt_text'] as String?,
      nextEpisode: json['next_episode'] as int,
    );
  }

  @override
  String toString() {
    return 'EpisodeStatus(episode: $currentEpisode, i_submitted: $iSubmitted, partner_submitted: $partnerSubmitted, both_submitted: $bothSubmitted)';
  }
}

/// State notifier for episode status
class EpisodeStatusState extends StateNotifier<AsyncValue<EpisodeStatus>> {
  EpisodeStatusState() : super(const AsyncValue.loading());

  /// Load episode status for a match
  Future<void> loadStatus(String matchId) async {
    debugPrint('📊 ===== LOAD EPISODE STATUS =====');
    debugPrint('📊 Match ID: $matchId');
    state = const AsyncValue.loading();

    try {
      final response = await Supabase.instance.client.rpc(
        'get_episode_status',
        params: {'p_match_id': matchId},
      );

      final status = EpisodeStatus.fromJson(response as Map<String, dynamic>);
      state = AsyncValue.data(status);
      debugPrint('✅ Episode ${status.currentEpisode} status loaded');
      debugPrint('   - I submitted: ${status.iSubmitted}');
      debugPrint('   - Partner submitted: ${status.partnerSubmitted}');
      debugPrint('   - Both submitted: ${status.bothSubmitted}');
      if (status.promptText != null) {
        debugPrint('   - Prompt: ${status.promptText}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading episode status: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh the status for a match
  Future<void> refresh(String matchId) => loadStatus(matchId);
}

/// Provider for episode status
/// Usage: ref.watch(episodeStatusProvider(matchId))
final episodeStatusProvider = StateNotifierProvider.family<
    EpisodeStatusState, AsyncValue<EpisodeStatus>, String>((ref, matchId) {
  debugPrint('📊 Creating episode status provider for match $matchId');
  final state = EpisodeStatusState();

  // Load initial status
  state.loadStatus(matchId);

  return state;
});
