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
import 'package:sevent_eps/models/match.dart';

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
          final match = Match.fromJson(matchData);
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
    Match match,
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

  Widget _buildEpisodeProgress(BuildContext context, Match match) {
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
    Match match,
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

  Widget _buildCurrentTaskCard(BuildContext context, Match match) {
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
