import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/daily_edition_provider.dart';
import 'package:sevent_eps/providers/match_provider.dart';
import 'package:sevent_eps/providers/lens_provider.dart';
import 'package:sevent_eps/models/candidate.dart';

class DailyEditionScreen extends ConsumerStatefulWidget {
  const DailyEditionScreen({super.key});

  @override
  ConsumerState<DailyEditionScreen> createState() => _DailyEditionScreenState();
}

class _DailyEditionScreenState extends ConsumerState<DailyEditionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _microcopyController;
  late Animation<double> _microcopyAnimation;
  int _currentMicrocopyIndex = 0;

  final List<String> _microcopyList = [
    'Take your time',
    'Quality over quantity',
    'Meaningful connections',
    'Today\'s curated picks',
    'Thoughtful matching',
  ];

  @override
  void initState() {
    super.initState();
    _microcopyController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _microcopyAnimation = CurvedAnimation(
      parent: _microcopyController,
      curve: Curves.easeInOut,
    );

    _microcopyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentMicrocopyIndex = (_currentMicrocopyIndex + 1) % _microcopyList.length;
        });
        _microcopyController.reset();
        _microcopyController.forward();
      }
    });

    _microcopyController.forward();
  }

  @override
  void dispose() {
    _microcopyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCandidates = ref.watch(dailyEditionProvider);
    final activeJourneyCount = ref.watch(activeJourneyCountProvider);
    final canStartJourney = activeJourneyCount < 3;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: asyncCandidates.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.sageGreen),
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(error),
          data: (candidates) {
            if (candidates.isEmpty) {
              return _buildEmptyState();
            }

            return _buildDailyEdition(candidates, canStartJourney, activeJourneyCount);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.terracotta.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load Daily Edition',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.charcoal,
                  ),
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
              onPressed: () => ref.read(dailyEditionProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sageGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sageGreen.withOpacity(0.1),
              ),
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 64,
                color: AppTheme.sageGreen,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Edition is Complete',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Return tomorrow for a new one',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Good connections take time',
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

  Widget _buildDailyEdition(List<Candidate> candidates, bool canStartJourney, int activeJourneyCount) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(candidates.length, activeJourneyCount),
        ),

        // Candidate cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _CandidateCard(
                    candidate: candidates[index],
                    canStartJourney: canStartJourney,
                    activeJourneyCount: activeJourneyCount,
                    onStartJourney: () => _handleStartJourney(candidates[index]),
                    onSaveForLater: () => _handleSaveForLater(candidates[index]),
                  ),
                );
              },
              childCount: candidates.length,
            ),
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildHeader(int candidateCount, int activeJourneyCount) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Edition',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$candidateCount connection${candidateCount == 1 ? '' : 's'} selected for you — refreshed daily',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              // Active journeys indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: activeJourneyCount >= 3
                      ? AppTheme.terracotta.withOpacity(0.1)
                      : AppTheme.sageGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeJourneyCount >= 3
                        ? AppTheme.terracotta
                        : AppTheme.sageGreen,
                    width: 1.5,
                  ),
                ),
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
            ],
          ),

          const SizedBox(height: 16),

          // Lens chips/nudge (NEW)
          _buildLensSection(),

          const SizedBox(height: 16),

          // Rotating microcopy
          FadeTransition(
            opacity: _microcopyAnimation,
            child: Text(
              _microcopyList[_currentMicrocopyIndex],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.terracotta,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLensSection() {
    final asyncUserLenses = ref.watch(userLensesProvider);

    return asyncUserLenses.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (userLenses) {
        // No lenses selected - show nudge
        if (userLenses.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/lens-picker'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.terracotta.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.terracotta.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppTheme.terracotta,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pick 3 lenses to improve your editions (30 seconds)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.terracotta,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.terracotta,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }

        // Show lens chips
        final lenses = userLenses.map((ul) => ul.lens).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your lenses:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.6),
                      ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/lens-picker'),
                  child: Text(
                    'Edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.sageGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lenses.map((lens) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sageGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.sageGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    lens.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.sageGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleStartJourney(Candidate candidate) async {
    final activeJourneyCount = ref.read(matchProvider).value?.length ?? 0;

    if (activeJourneyCount >= 3) {
      if (mounted) {
        _showJourneyLimitDialog();
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Open Journey with ${candidate.name}?'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Journey'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(matchProvider.notifier).startJourney(candidate.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journey started with ${candidate.name}!'),
            backgroundColor: AppTheme.sageGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Could Not Start Journey', e.toString());
      }
    }
  }

  void _showJourneyLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Maximum Active Journeys'),
        content: const Text(
          'You can have up to 3 active journeys. Archive one to begin a new journey.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.terracotta,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleSaveForLater(Candidate candidate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate.name} saved for later'),
        backgroundColor: AppTheme.sageGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
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

class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool canStartJourney;
  final int activeJourneyCount;
  final VoidCallback onStartJourney;
  final VoidCallback onSaveForLater;

  const _CandidateCard({
    required this.candidate,
    required this.canStartJourney,
    required this.activeJourneyCount,
    required this.onStartJourney,
    required this.onSaveForLater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo section with blur
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred photo
                  candidate.photo != null
                      ? _BlurredImage(imageUrl: candidate.photo!.url)
                      : Container(
                          color: AppTheme.sageGreen.withOpacity(0.15),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 80,
                              color: AppTheme.sageGreen,
                            ),
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.charcoal.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and age
                Row(
                  children: [
                    Text(
                      candidate.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${candidate.age}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),

                // City
                if (candidate.city != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.charcoal.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        candidate.city!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.charcoal.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Interests tags
                if (candidate.interests.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.interests.take(2).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.sageGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          interest,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.sageGreen,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Compatibility hint
                Text(
                  candidate.compatibilityHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.terracotta,
                        fontStyle: FontStyle.italic,
                      ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // Primary: Open Journey
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canStartJourney ? onStartJourney : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canStartJourney
                              ? AppTheme.terracotta
                              : AppTheme.charcoal.withOpacity(0.3),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.charcoal.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          canStartJourney ? 'Open Journey' : 'Slot Full',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Secondary: Save for Later
                    IconButton(
                      onPressed: onSaveForLater,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.sageGreen.withOpacity(0.1),
                        foregroundColor: AppTheme.sageGreen,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bookmark_border),
                      tooltip: 'Save for later',
                    ),
                  ],
                ),

                // Helper text when at journey limit
                if (!canStartJourney)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.terracotta.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'You have $activeJourneyCount active journeys. Archive one to start a new journey.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.charcoal.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
      fit: StackFit.expand,
      children: [
        // Original image
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.sageGreen.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.sageGreen),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.sageGreen.withOpacity(0.15),
            child: const Center(
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: AppTheme.sageGreen,
              ),
            ),
          ),
        ),
        // Heavy blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
