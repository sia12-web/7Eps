import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/models/profile.dart';
import 'package:sevent_eps/providers/journey_provider.dart';
import 'package:sevent_eps/providers/match_provider.dart';
import 'package:sevent_eps/providers/artifact_timeline_provider.dart';
import 'package:sevent_eps/models/match.dart' as match_model;

class JourneyScreen extends ConsumerStatefulWidget {
  final String matchId;

  const JourneyScreen({super.key, required this.matchId});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  @override
  void initState() {
    super.initState();
    // Load journey data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journeyProvider.notifier).loadJourney(widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncJourney = ref.watch(journeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: asyncJourney.when(
          data: (data) {
            final partner = data!['partner'] as Profile;
            return Text(partner.name);
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Journey'),
        ),
      ),
      body: asyncJourney.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.terracotta,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load journey',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(journeyProvider.notifier).refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final matchData = data!['match'] as Map<String, dynamic>;
          final match = match_model.Match.fromJson(matchData);
          final partner = data!['partner'] as Profile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Partner header with blurred photo
                _buildPartnerHeader(context, partner, match),

                const SizedBox(height: 24),

                // Episode progress
                _buildEpisodeProgress(context, match),

                const SizedBox(height: 24),

                // Timeline header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Your Story So Far',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                // Artifact timeline
                Consumer(
                  builder: (context, ref, child) {
                    final timeline = ref.watch(artifactTimelineProvider(widget.matchId));

                    return timeline.when(
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppTheme.terracotta,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Unable to load timeline',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.charcoal.withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      data: (artifacts) {
                        if (artifacts.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_outlined,
                                    size: 64,
                                    color: AppTheme.charcoal.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your story begins with Episode 1',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppTheme.charcoal.withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildArtifactCard(
                                context,
                                artifacts[index],
                                partner,
                              );
                            },
                            childCount: artifacts.length,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // What's Revealed section
                _buildWhatsRevealed(context, partner, match),

                const SizedBox(height: 24),

                // Current Task card
                _buildCurrentTaskCard(context, match),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartnerHeader(
    BuildContext context,
    Profile partner,
    match_model.Match match,
  ) {
    final photoUrl = partner.photos.isNotEmpty
        ? partner.photos.first.url
        : null;

    return Column(
      children: [
        // Blurred photo
        AspectRatio(
          aspectRatio: 1,
          child: photoUrl != null
              ? _BlurredProfilePhoto(
                  imageUrl: photoUrl,
                  blurAmount: match.blurAmount,
                )
              : Container(
                  decoration: BoxDecoration(
                    color: AppTheme.sageGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: AppTheme.sageGreen,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // Partner name
        Text(
          partner.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.charcoal,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEpisodeProgress(BuildContext context, match_model.Match match) {
    final currentEpisode = match.currentEpisode;
    final totalEpisodes = 7;
    final progress = currentEpisode / totalEpisodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.charcoal.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.charcoal.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sageGreen),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Episode $currentEpisode of $totalEpisodes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.sageGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildWhatsRevealed(
    BuildContext context,
    Profile partner,
    match_model.Match match,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's Revealed",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.charcoal.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.charcoal.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (match.currentEpisode >= 1)
                _buildRevealedItem(
                  context,
                  'Episode 1',
                  '25% Unblur',
                  Icons.remove_red_eye,
                ),
              if (match.currentEpisode >= 2) ...[
                _buildRevealedItem(
                  context,
                  'Episode 2',
                  'Bio & Interests',
                  Icons.info,
                ),
                const SizedBox(height: 8),
              ],
              if (match.currentEpisode >= 3) ...[
                _buildRevealedItem(
                  context,
                  'Episode 3',
                  'Compatibility Score',
                  Icons.favorite,
                ),
                const SizedBox(height: 8),
              ],
              if (match.currentEpisode >= 4)
                _buildRevealedItem(
                  context,
                  'Episode 4',
                  '100% Unblur',
                  Icons.visibility,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedItem(
    BuildContext context,
    String episode,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.sageGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.sageGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                episode,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTaskCard(BuildContext context, match_model.Match match) {
    final episodeNum = match.currentEpisode;
    final episodeDef = episodeDefinitions[episodeNum] ?? {};
    final episodeType = getArtifactTypeForEpisode(episodeNum);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.sageGreen,
            AppTheme.sageGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Episode $episodeNum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  episodeDef['title'] ?? 'Episode $episodeNum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            episodeDef['prompt'] ?? 'Continue your journey...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(
                '/journey/${widget.matchId}/episode/$episodeNum',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.sageGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Start Episode $episodeNum'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(
    BuildContext context,
    dynamic artifact,
    Profile partner,
  ) {
    final isMine = artifact.isMine as bool;
    final episode = artifact.episode as int;
    final payload = artifact.payload as Map<String, dynamic>;
    final promptText = artifact.promptText as String?;
    final createdAt = DateTime.parse(artifact.createdAt as String);

    // Parse artifact type
    final typeStr = artifact.type is String ? artifact.type as String : (artifact.type as ArtifactType).name;
    final ArtifactType type;
    if (typeStr == 'prompt_answer') {
      type = ArtifactType.promptAnswer;
    } else {
      type = ArtifactType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ArtifactType.promptAnswer,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMine
              ? AppTheme.sageGreen.withOpacity(0.2)
              : AppTheme.terracotta.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isMine
                      ? AppTheme.sageGreen.withOpacity(0.1)
                      : AppTheme.terracotta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Chapter $episode',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isMine
                            ? AppTheme.sageGreen
                            : AppTheme.terracotta,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isMine ? 'You' : partner.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.6),
                    ),
              ),
              const Spacer(),
              Text(
                _formatTime(createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.4),
                    ),
              ),
            ],
          ),

          if (promptText != null) ...[
            const SizedBox(height: 12),
            // Prompt display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.charcoal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: AppTheme.charcoal.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      promptText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Artifact content based on type
          _buildArtifactContent(context, type, payload),

          const SizedBox(height: 8),

          // Artifact type badge
          Row(
            children: [
              Icon(
                _getArtifactIcon(type),
                size: 14,
                color: AppTheme.charcoal.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                _getArtifactTypeLabel(type),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactContent(
    BuildContext context,
    ArtifactType type,
    Map<String, dynamic> payload,
  ) {
    switch (type) {
      case ArtifactType.promptAnswer:
        return Text(
          payload['text']?.toString() ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        );
      case ArtifactType.voice:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.sageGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.mic, color: AppTheme.sageGreen, size: 20),
              const SizedBox(width: 8),
              Text('Voice message'),
            ],
          ),
        );
      case ArtifactType.photo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: payload['url']?.toString() ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case ArtifactType.tags:
        final tags = payload['tags'] as List<dynamic>?;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (tags ?? [])
              .map<Widget>((tag) => Chip(
                    label: Text(tag.toString()),
                    backgroundColor: AppTheme.sageGreen.withOpacity(0.1),
                  ))
              .toList(),
        );
      default:
        return Text(
          'Unsupported artifact type',
          style: Theme.of(context).textTheme.bodyMedium,
        );
    }
  }

  IconData _getArtifactIcon(ArtifactType type) {
    switch (type) {
      case ArtifactType.promptAnswer:
        return Icons.chat_bubble_outline;
      case ArtifactType.voice:
        return Icons.mic;
      case ArtifactType.photo:
        return Icons.photo;
      case ArtifactType.tags:
        return Icons.local_offer;
      case ArtifactType.dealbreakers:
        return Icons.block;
      case ArtifactType.scenario:
        return Icons.explore;
      case ArtifactType.dateChoice:
        return Icons.event;
    }
  }

  String _getArtifactTypeLabel(ArtifactType type) {
    switch (type) {
      case ArtifactType.promptAnswer:
        return 'Text Answer';
      case ArtifactType.voice:
        return 'Voice Note';
      case ArtifactType.photo:
        return 'Photo';
      case ArtifactType.tags:
        return 'Tags';
      case ArtifactType.dealbreakers:
        return 'Dealbreakers';
      case ArtifactType.scenario:
        return 'Scenario';
      case ArtifactType.dateChoice:
        return 'Date Choice';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _BlurredProfilePhoto extends StatelessWidget {
  final String imageUrl;
  final double blurAmount;

  const _BlurredProfilePhoto({
    required this.imageUrl,
    required this.blurAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.sageGreen.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.sageGreen.withOpacity(0.2),
            child: const Center(
              child: Icon(Icons.person, size: 60),
            ),
          ),
        ),
        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
