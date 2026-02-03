import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/artifact.dart';

/// Timeline artifact model for the "Book" UI
class TimelineArtifact {
  final String id;
  final int episode;
  final ArtifactType type;
  final Map<String, dynamic> payload;
  final bool isMine;
  final DateTime createdAt;
  final String? promptText;

  TimelineArtifact({
    required this.id,
    required this.episode,
    required this.type,
    required this.payload,
    required this.isMine,
    required this.createdAt,
    this.promptText,
  });

  /// Create TimelineArtifact from JSON response
  factory TimelineArtifact.fromJson(Map<String, dynamic> json) {
    // Parse artifact type from string
    final typeStr = json['type'] as String;
    final ArtifactType type;
    if (typeStr == 'prompt_answer') {
      type = ArtifactType.promptAnswer;
    } else {
      type = ArtifactType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ArtifactType.promptAnswer,
      );
    }

    return TimelineArtifact(
      id: json['id'] as String,
      episode: json['episode'] as int,
      type: type,
      payload: json['payload'] as Map<String, dynamic>,
      isMine: json['is_mine'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      promptText: json['prompt_text'] as String?,
    );
  }

  @override
  String toString() {
    return 'TimelineArtifact(episode: $episode, type: $type, isMine: $isMine)';
  }
}

/// State notifier for artifact timeline
class ArtifactTimelineState extends StateNotifier<AsyncValue<List<TimelineArtifact>>> {
  RealtimeChannel? _channel;

  ArtifactTimelineState() : super(const AsyncValue.loading());

  /// Load timeline artifacts for a match
  Future<void> loadTimeline(String matchId) async {
    debugPrint('📜 ===== LOAD TIMELINE =====');
    debugPrint('📜 Match ID: $matchId');
    state = const AsyncValue.loading();

    try {
      final response = await Supabase.instance.client.rpc(
        'get_episode_timeline',
        params: {'p_match_id': matchId},
      );

      final artifacts = (response as List<dynamic>)
          .map((e) => TimelineArtifact.fromJson(e as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(artifacts);
      debugPrint('✅ Loaded ${artifacts.length} timeline entries');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading timeline: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Subscribe to realtime updates for artifacts
  /// This will automatically refresh the timeline when a new artifact is inserted
  void subscribeToTimeline(String matchId) {
    debugPrint('🔔 ===== SUBSCRIBE TO TIMELINE =====');
    debugPrint('🔔 Match ID: $matchId');

    // Close existing channel if any
    if (_channel != null) {
      debugPrint('🔔 Closing existing channel');
      _channel!.unsubscribe();
    }

    // Create new channel for this match
    _channel = Supabase.instance.client.channel('artifacts:$matchId');

    // Subscribe to postgres changes
    _channel!.subscribe((status, error) {
      debugPrint('🔔 Channel status: $status');
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('🔔 Successfully subscribed to artifacts for match $matchId');
      } else if (error != null) {
        debugPrint('❌ Realtime subscription error: $error');
      }
    });

    // Note: For now, we're not setting up postgres change filters
    // The user can manually refresh to see new artifacts
    // TODO: Implement proper Realtime postgres changes after API is finalized
    debugPrint('🔔 Realtime subscription initialized (manual refresh for now)');
  }

  /// Unsubscribe from realtime updates
  void unsubscribe() {
    if (_channel != null) {
      _channel!.unsubscribe();
      _channel = null;
      debugPrint('🔔 Unsubscribed from timeline');
    }
  }

  /// Refresh the timeline
  Future<void> refresh(String matchId) => loadTimeline(matchId);

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

/// Provider for artifact timeline
/// Usage: ref.watch(artifactTimelineProvider(matchId))
///
/// This provider:
/// 1. Loads the initial timeline when first accessed
/// 2. Subscribes to realtime INSERT events on the artifacts table
/// 3. Automatically refreshes when new artifacts are added
/// 4. Cleans up the subscription when disposed
final artifactTimelineProvider = StateNotifierProvider.family<
    ArtifactTimelineState, AsyncValue<List<TimelineArtifact>>, String>((ref, matchId) {
  debugPrint('📜 Creating artifact timeline provider for match $matchId');
  final state = ArtifactTimelineState();

  // Load initial data
  state.loadTimeline(matchId);

  // Subscribe to realtime updates
  state.subscribeToTimeline(matchId);

  // Note: The provider will be automatically disposed when no longer used
  // We need to ensure cleanup happens

  ref.onDispose(() {
    debugPrint('📜 Disposing artifact timeline provider for match $matchId');
    state.unsubscribe();
  });

  return state;
});
