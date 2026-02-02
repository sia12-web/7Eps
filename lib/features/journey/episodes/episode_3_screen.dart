import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/profile.dart';
import 'package:sevent_eps/providers/profile_provider.dart';
import 'package:sevent_eps/models/artifact.dart';
import 'package:sevent_eps/models/episode.dart';
import 'package:sevent_eps/providers/artifact_provider.dart';

class Episode3Screen extends ConsumerStatefulWidget {
  final String matchId;

  const Episode3Screen({super.key, required this.matchId});

  @override
  ConsumerState<Episode3Screen> createState() => _Episode3ScreenState();
}

class _Episode3ScreenState extends ConsumerState<Episode3Screen> {
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final episodeDef = episodeDefinitions[3] ?? {};
    final asyncProfile = ref.watch(profileProvider);

    return asyncProfile.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
      data: (profile) {
        final userInterests = profile?.interests ?? [];
        final allTags = _extractInterests(userInterests);

        return Scaffold(
          appBar: AppBar(
            title: Text(episodeDef['title'] ?? 'Episode 3'),
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
                      Text(
                        'Episode 3 of 7',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.sageGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        episodeDef['description'] ?? 'Select your interests',
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
                  episodeDef['prompt'] ?? 'What activities do you enjoy?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.charcoal,
                        fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Tag counter
                Row(
                  children: [
                    Text(
                      'Selected: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),
                    Text(
                      '${_selectedTags.length}/3',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedTags.length == 3
                                ? AppTheme.sageGreen
                                : AppTheme.terracotta,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tags selection
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (_selectedTags.length < 3) {
                              _selectedTags.add(tag);
                            }
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: AppTheme.sageGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.charcoal,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: isSelected
                          ? AppTheme.sageGreen
                          : AppTheme.charcoal.withOpacity(0.1),
                      side: BorderSide(
                        color: isSelected ? AppTheme.sageGreen : Colors.transparent,
                      ),
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedTags.length == 3 && !_isSubmitting
                        ? _handleSubmit
                        : null,
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
                        : const Text('Submit Tags'),
                  ),
                ),

                const SizedBox(height: 16),

                // Info text
                Text(
                  'Select exactly 3 activities',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.charcoal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _extractInterests(List<dynamic>? interests) {
    if (interests == null) return [];

    // Extract interest names from the JSON structure
    return interests
        .map((i) => i is String ? i as String : (i['name'] as String? ?? ''))
        .toSet()
        .toList();
  }

  Future<void> _handleSubmit() async {
    if (_selectedTags.length != 3) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(artifactProvider.notifier).submitArtifact(
        matchId: widget.matchId,
        artifactType: ArtifactType.tags.name,
        payload: {'tags': _selectedTags.toList()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tags submitted successfully!'),
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
