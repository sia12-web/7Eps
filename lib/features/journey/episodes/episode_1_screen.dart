import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/providers/artifact_provider.dart';
import 'package:sevent_eps/providers/artifact_timeline_provider.dart';
import 'package:sevent_eps/providers/episode_status_provider.dart';

enum Episode1State {
  loading,
  promptInput,
  waitingForPartner,
  bothSubmitted,
}

class Episode1Screen extends ConsumerStatefulWidget {
  final String matchId;

  const Episode1Screen({super.key, required this.matchId});

  @override
  ConsumerState<Episode1Screen> createState() => _Episode1ScreenState();
}

class _Episode1ScreenState extends ConsumerState<Episode1Screen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _pageTurnAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageTurnAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final episodeStatus = ref.watch(episodeStatusProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode 1 — The Icebreaker'),
      ),
      body: episodeStatus.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
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
                  'Unable to load episode status',
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
        data: (status) {
          // Determine state based on submission status
          if (!status.iSubmitted && !status.partnerSubmitted) {
            return _buildPromptInput(status);
          } else if (status.iSubmitted && !status.partnerSubmitted) {
            return _buildWaitingState(status);
          } else if (status.bothSubmitted) {
            return _buildBothSubmittedView(status);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPromptInput(status) {
    final promptText = status.promptText ??
        'What\'s a harmless habit or quirk of yours that always makes people laugh?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.sageGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Episode 1 of 7',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.sageGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Episode 1 — The Icebreaker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Subtext
          Text(
            'Start light. Start human.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.charcoal.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 32),

          // Prompt card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppTheme.terracotta.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.terracotta.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.terracotta,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Prompt',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.terracotta,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  promptText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Text input
          TextField(
            controller: _textController,
            maxLines: 6,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Share your answer...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Character counter
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_textController.text.length}/300',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _textController.text.length >= 300
                        ? AppTheme.terracotta
                        : AppTheme.charcoal.withOpacity(0.5),
                  ),
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting || _textController.text.trim().isEmpty
                  ? null
                  : () => _handleSubmit(status.promptId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit my answer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState(status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.sageGreen.withOpacity(0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sageGreen),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Waiting for their answer…',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ll see both answers side-by-side when they\'re ready',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.charcoal.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBothSubmittedView(status) {
    // Trigger animation on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Celebration header with animation
          AnimatedBuilder(
            animation: _pageTurnAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pageTurnAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - _pageTurnAnimation.value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.sageGreen,
                    AppTheme.sageGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlocked: 25% Photo Reveal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your partner\'s photo is now slightly less blurred',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Side-by-side answers
          Row(
            children: [
              Expanded(
                child: _buildAnswerCard(
                  'Your Answer',
                  _textController.text,
                  isMine: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPartnerAnswerCard(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go('/journey/${widget.matchId}/episode/2');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sageGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue to Episode 2',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(String title, String text, {required bool isMine}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isMine
            ? AppTheme.sageGreen.withOpacity(0.1)
            : AppTheme.terracotta.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMine
              ? AppTheme.sageGreen.withOpacity(0.3)
              : AppTheme.terracotta.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMine ? Icons.person : Icons.person_outline,
                size: 16,
                color: isMine ? AppTheme.sageGreen : AppTheme.terracotta,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isMine ? AppTheme.sageGreen : AppTheme.terracotta,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerAnswerCard() {
    final timeline = ref.watch(artifactTimelineProvider(widget.matchId));

    return timeline.when(
      loading: () => Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.terracotta.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Error loading answer'),
        ),
      ),
      data: (artifacts) {
        // Find partner's Episode 1 artifact
        final partnerArtifact = artifacts.firstWhere(
          (a) => a.episode == 1 && !a.isMine,
          orElse: () => null as dynamic,
        );

        if (partnerArtifact == null) {
          return const SizedBox.shrink();
        }

        return _buildAnswerCard(
          'Their Answer',
          partnerArtifact.payload['text']?.toString() ?? '',
          isMine: false,
        );
      },
    );
  }

  Future<void> _handleSubmit(String? promptId) async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(artifactProvider.notifier).submitArtifact(
        matchId: widget.matchId,
        artifactType: ArtifactType.promptAnswer.name,
        payload: {'text': text},
        promptId: promptId,
      );

      // Refresh status after submission
      await ref
          .read(episodeStatusProvider(widget.matchId).notifier)
          .refresh(widget.matchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer submitted successfully!'),
            backgroundColor: AppTheme.sageGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
