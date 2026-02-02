import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/match_provider.dart';
import 'package:sevent_eps/providers/profile_provider.dart';
import 'package:sevent_eps/models/match.dart';

class JourneysListScreen extends ConsumerWidget {
  const JourneysListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMatches = ref.watch(matchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Journeys'),
      ),
      body: asyncMatches.when(
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
                  'Unable to load journeys',
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
                  onPressed: () => ref.read(matchProvider.notifier).refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (matches) => matches.isEmpty
            ? _buildEmptyState(context)
            : _buildJourneysList(context, matches),
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
              Icons.favorite_border,
              size: 80,
              color: AppTheme.sageGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Journeys',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Daily Edition to start your first journey!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneysList(BuildContext context, List<Match> matches) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final match = matches[index];
        return _JourneyCard(match: match);
      },
    );
  }
}

class _JourneyCard extends ConsumerWidget {
  final Match match;

  const _JourneyCard({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch partner profile data
    // For now, we'll show match ID and progress

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          // Navigate to journey detail
          context.go('/journey/${match.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Journey #${match.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.charcoal,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Started ${_formatDate(match.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.charcoal.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.sageGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ep ${match.currentEpisode}/7',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.sageGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: match.currentEpisode / 7,
                  backgroundColor: AppTheme.charcoal.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sageGreen),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/journey/${match.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.terracotta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Continue Journey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
