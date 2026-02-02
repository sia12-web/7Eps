import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/daily_edition_provider.dart';
import 'package:sevent_eps/providers/match_provider.dart';
import 'package:sevent_eps/models/candidate.dart';

class DailyEditionScreen extends ConsumerStatefulWidget {
  const DailyEditionScreen({super.key});

  @override
  ConsumerState<DailyEditionScreen> createState() => _DailyEditionScreenState();
}

class _DailyEditionScreenState extends ConsumerState<DailyEditionScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncCandidates = ref.watch(dailyEditionProvider);
    final activeJourneyCount = ref.watch(activeJourneyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Edition'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '$activeJourneyCount/3 Active',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: activeJourneyCount >= 3
                          ? AppTheme.terracotta
                          : AppTheme.sageGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: asyncCandidates.when(
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
                  'Unable to load Daily Edition',
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
                      ref.read(dailyEditionProvider.notifier).refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (candidates) =>
            candidates.isEmpty ? _buildEmptyState(context) : _buildCandidateShelf(context, candidates),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 80,
              color: AppTheme.sageGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No candidates today',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back tomorrow for new matches',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Complete your profile to improve matching',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.terracotta,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateShelf(BuildContext context, List<Candidate> candidates) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Picks",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.sageGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${candidates.length} candidate${candidates.length == 1 ? '' : 's'} curated just for you',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),

          // Horizontal card shelf
          SizedBox(
            height: 420,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: candidates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _CandidateCard(
                  candidate: candidates[index],
                  onStartJourney: () => _handleStartJourney(candidates[index]),
                );
              },
            ),
          ),

          // Bottom spacer
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleStartJourney(Candidate candidate) async {
    debugPrint('💝 Start Journey tapped for: ${candidate.name}');

    // Check if user has reached max active journeys
    final activeJourneyCount = ref.read(matchProvider).value?.length ?? 0;
    if (activeJourneyCount >= 3) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Maximum Active Journeys'),
            content: const Text(
              'You have 3 active journeys. Complete or end one to start a new journey.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Journey with ${candidate.name}?'),
        content: const Text(
          'Begin your 7-episode journey together. This will use one of your 3 active journey slots.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Start Journey'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Start the journey
    try {
      await ref.read(matchProvider.notifier).startJourney(candidate.userId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journey started with ${candidate.name}!'),
            backgroundColor: AppTheme.sageGreen,
            duration: const Duration(seconds: 2),
          ),
        );

        // TODO: Navigate to journey screen when implemented in Phase 4
        // context.go('/journey/$matchId');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Could Not Start Journey'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onStartJourney;

  const _CandidateCard({
    required this.candidate,
    required this.onStartJourney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blurred photo
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Photo with blur
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: candidate.photo != null
                      ? _BlurredImage(imageUrl: candidate.photo!.url)
                      : Container(
                          color: AppTheme.sageGreen.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: AppTheme.sageGreen,
                            ),
                          ),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.charcoal.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        candidate.name,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.charcoal,
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Tagline
                      Text(
                        candidate.tagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.charcoal.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Start Journey button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartJourney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Start Journey'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredImage extends StatelessWidget {
  final String imageUrl;

  const _BlurredImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original image
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
              child: Icon(
                Icons.person,
                size: 80,
                color: AppTheme.sageGreen,
              ),
            ),
          ),
        ),
        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
