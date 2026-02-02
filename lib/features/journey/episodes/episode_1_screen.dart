import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/providers/artifact_provider.dart';

class Episode1Screen extends ConsumerStatefulWidget {
  final String matchId;

  const Episode1Screen({super.key, required this.matchId});

  @override
  ConsumerState<Episode1Screen> createState() => _Episode1ScreenState();
}

class _Episode1ScreenState extends ConsumerState<Episode1Screen> {
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final episodeDef = episodeDefinitions[1] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(episodeDef['title'] ?? 'Episode 1'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode info
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.sageGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.sageGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Episode 1 of 7',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.sageGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episodeDef['description'] ?? 'Share a story about yourself',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prompt
            Text(
              episodeDef['prompt'] ?? 'What\'s your story?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 16),

            // Text input
            TextField(
              controller: _textController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your funny anecdote...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.charcoal.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.charcoal.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.sageGreen,
                    width: 2,
                  ),
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
                '${_textController.text.length}/500',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _textController.text.length >= 500
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
                onPressed: _isSubmitting ||
                        _textController.text.trim().isEmpty
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: AppTheme.terracotta.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Anecdote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please share your anecdote first'),
            backgroundColor: AppTheme.terracotta,
          ),
        );
      }
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
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anecdote submitted successfully!'),
            backgroundColor: AppTheme.sageGreen,
          ),
        );
        // Navigate back to journey screen
        context.pop();
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
