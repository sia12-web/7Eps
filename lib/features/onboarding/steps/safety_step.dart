import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';

/// Safety Agreement step (Step 10)
/// Community guidelines acceptance (required to continue)
class SafetyStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const SafetyStep({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<SafetyStep> createState() => _SafetyStepState();
}

class _SafetyStepState extends ConsumerState<SafetyStep> {
  bool _agreementAccepted = false;

  final List<SafetySection> _sections = const [
    SafetySection(
      title: 'Be Respectful',
      icon: Icons.favorite,
      color: AppTheme.sageGreen,
      content: 'Treat everyone with kindness and respect. No harassment, hate speech, or inappropriate content.',
    ),
    SafetySection(
      title: 'Be Authentic',
      icon: Icons.verified,
      color: AppTheme.sageGreen,
      content: 'Be yourself and use real photos and genuine information. Catfishing and fake profiles are not allowed.',
    ),
    SafetySection(
      title: 'Stay Safe',
      icon: Icons.shield,
      color: AppTheme.sageGreen,
      content: 'Don\'t share personal information too early. Meet in public places for first dates. Trust your instincts.',
    ),
    SafetySection(
      title: 'Report Issues',
      icon: Icons.flag,
      color: AppTheme.sageGreen,
      content: 'Help us keep the community safe by reporting any violations or suspicious behavior.',
    ),
  ];

  Future<void> _acceptAndContinue() async {
    if (!_agreementAccepted) return;

    try {
      // Save acceptance timestamp
      await ref.read(onboardingProvider.notifier).saveStep(10, {
        'safety_agreement_accepted_at': DateTime.now().toIso8601String(),
      });

      widget.onContinue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if (widget.onBack != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.terracotta.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: AppTheme.terracotta,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Community Guidelines',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.charcoal,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Please review and accept our community guidelines',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.7),
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Safety sections
                    ...List.generate(_sections.length, (index) {
                      return _buildSafetySection(_sections[index]);
                    }),

                    const SizedBox(height: 32),

                    // Agreement checkbox
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.sageGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.sageGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreementAccepted,
                            onChanged: (value) {
                              setState(() {
                                _agreementAccepted = value ?? false;
                              });
                            },
                            activeColor: AppTheme.sageGreen,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreementAccepted = !_agreementAccepted;
                                });
                              },
                              child: Text(
                                'I have read and agree to the Community Guidelines',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _agreementAccepted ? _acceptAndContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _agreementAccepted
                              ? AppTheme.terracotta
                              : AppTheme.charcoal.withOpacity(0.3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _agreementAccepted ? 'Continue' : 'Accept to Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info text
                    Text(
                      'You can review these guidelines anytime in Settings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.charcoal.withOpacity(0.5),
                          ),
                      textAlign: TextAlign.center,
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

  Widget _buildSafetySection(SafetySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.charcoal.withOpacity(0.1),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: section.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            section.icon,
            color: section.color,
            size: 20,
          ),
        ),
        title: Text(
          section.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              section.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class SafetySection {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const SafetySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });
}
