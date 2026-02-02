import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/providers/artifact_provider.dart';

class Episode2Screen extends ConsumerStatefulWidget {
  final String matchId;

  const Episode2Screen({super.key, required this.matchId});

  @override
  ConsumerState<Episode2Screen> createState() => _Episode2ScreenState();
}

class _Episode2ScreenState extends ConsumerState<Episode2Screen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordedSeconds = 0;
  String? _audioPath;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final episodeDef = episodeDefinitions[2] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(episodeDef['title'] ?? 'Episode 2'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Episode info
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.sageGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Episode 2 of 7',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.sageGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episodeDef['description'] ?? 'Share your voice',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Prompt
            Text(
              episodeDef['prompt'] ?? 'Record a voice note',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Recording button
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? AppTheme.terracotta
                      : AppTheme.sageGreen,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording
                              ? AppTheme.terracotta
                              : AppTheme.sageGreen)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Timer display
            if (_recordedSeconds > 0 || _isRecording)
              Text(
                _isRecording
                    ? 'Recording... ${_recordedSeconds}s'
                    : 'Duration: ${_recordedSeconds}s',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
              ),

            const SizedBox(height: 32),

            // Playback controls (if recorded)
            if (_audioPath != null && !_isRecording) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                    onPressed: _togglePlayback,
                    color: AppTheme.sageGreen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 32),
                    onPressed: _resetRecording,
                    color: AppTheme.charcoal.withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_audioPath == null || _isSubmitting)
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
                    : const Text('Submit Voice Note'),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Text(
              'Maximum 30 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordedSeconds = 0;
    });

    // TODO: Implement actual audio recording
    // For now, simulate recording with timer
    _simulateRecording();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _simulateRecording() {
    // Simulate recording with timer
    Future.delayed(const Duration(seconds: 30), () {
      if (_isRecording) {
        if (mounted) {
          setState(() {
            _isRecording = false;
            _recordedSeconds = 30;
            _audioPath = '/path/to/audio.mp3'; // Placeholder
          });
        }
      }
    });

    // Update timer every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordedSeconds++;
        });
        return true;
      } else {
        return false;
      }
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Implement actual audio playback
  }

  void _resetRecording() {
    setState(() {
      _recordedSeconds = 0;
      _audioPath = null;
      _isPlaying = false;
    });
  }

  Future<void> _handleSubmit() async {
    if (_audioPath == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Upload audio to Supabase Storage first
      // For now, submit with placeholder path
      await ref.read(artifactProvider.notifier).submitArtifact(
        matchId: widget.matchId,
        artifactType: ArtifactType.voice.name,
        payload: {
          'audio_url': _audioPath!,
          'duration': _recordedSeconds,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice note submitted successfully!'),
            backgroundColor: AppTheme.sageGreen,
          ),
        );
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
