import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/models/artifact.dart' show episodeDefinitions;

/// Tutorial step (Step 11)
/// Explains the 7-episode journey concept
class TutorialStep extends ConsumerWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const TutorialStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if (onBack != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'How 7Eps Works',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Your journey to a real date unfolds through 7 episodes. Each episode reveals more about you and your match.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Episode timeline
                    _buildEpisodeTimeline(context),

                    const SizedBox(height: 32),

                    // Key points
                    _buildKeyPoint(
                      context,
                      Icons.lock_clock,
                      'Both Complete to Unlock',
                      'You and your match must complete each episode to unlock the next one.',
                    ),

                    const SizedBox(height: 16),

                    _buildKeyPoint(
                      context,
                      Icons.visibility,
                      'Progressive Revelation',
                      'Photos unblur gradually as you progress through the journey.',
                    ),

                    const SizedBox(height: 16),

                    _buildKeyPoint(
                      context,
                      Icons.favorite,
                      'Meaningful Connections',
                      'Quality over quantity - only 3 active journeys at a time.',
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Got It, Let\'s Start!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeTimeline(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.sageGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.charcoal.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final episodeNum = index + 1;
            final episodeDef = episodeDefinitions[episodeNum] ?? {};
            final isAccessible = episodeNum <= 4;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEpisodeCard(
                context,
                episodeNum,
                episodeDef['title'] ?? 'Episode $episodeNum',
                episodeDef['artifactType'] ?? 'text',
                isAccessible,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(
    BuildContext context,
    int episodeNum,
    String title,
    String artifactType,
    bool isAccessible,
  ) {
    IconData icon;
    switch (artifactType) {
      case 'prompt_answer':
        icon = Icons.text_fields;
        break;
      case 'voice':
        icon = Icons.mic;
        break;
      case 'tags':
        icon = Icons.tag;
        break;
      case 'photo':
        icon = Icons.photo_camera;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isAccessible
                ? AppTheme.sageGreen
                : AppTheme.charcoal.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isAccessible
                ? Text(
                    '$episodeNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.lock,
                    size: 20,
                    color: AppTheme.charcoal.withOpacity(0.5),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: AppTheme.charcoal.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getArtifactLabel(artifactType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.5),
                        ),
                  ),
                  if (!isAccessible)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '• Episode ${episodeNum - 1}+',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.terracotta,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getArtifactLabel(String type) {
    switch (type) {
      case 'prompt_answer':
        return 'Share your story';
      case 'voice':
        return 'Voice note';
      case 'tags':
        return 'Select interests';
      case 'photo':
        return 'Upload photo';
      default:
        return 'Artifact';
    }
  }

  Widget _buildKeyPoint(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.sageGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.sageGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
