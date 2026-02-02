import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';
import 'package:sevent_eps/providers/daily_edition_provider.dart';

/// Generate Daily Edition step (Step 12)
/// Completes onboarding and generates first daily edition
class GenerateDailyEditionStep extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const GenerateDailyEditionStep({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<GenerateDailyEditionStep> createState() => _GenerateDailyEditionStepState();
}

class _GenerateDailyEditionStepState extends ConsumerState<GenerateDailyEditionStep> {
  bool _isGenerating = false;
  String _status = 'Finding your first matches...';

  final List<String> _progressSteps = [
    'Reviewing your profile...',
    'Scanning for compatible people...',
    'Curating your Daily Edition...',
    'Almost ready...',
  ];

  int _currentProgressStep = 0;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _currentProgressStep = 0;
    });

    // Simulate progress
    for (int i = 0; i < _progressSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentProgressStep = i;
          _status = _progressSteps[i];
        });
      }
    }

    // Complete onboarding and generate daily edition
    try {
      // Mark onboarding as complete
      await ref.read(onboardingProvider.notifier).completeOnboarding();

      // Generate daily edition
      await ref.read(dailyEditionProvider.notifier).loadDailyEdition();

      if (mounted) {
        // Show success message briefly, then redirect
        setState(() {
          _isGenerating = false;
          _status = 'Welcome to 7Eps!';
        });

        // Auto-redirect after 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          context.go('/daily-edition');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _status = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                if (_isGenerating)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.sageGreen,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle,
                    size: 120,
                    color: AppTheme.sageGreen,
                  ),

                const SizedBox(height: 48),

                // Status text
                Text(
                  _status,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                if (_isGenerating)
                  Text(
                    'This may take a moment...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.7),
                        ),
                  )
                else
                  Text(
                    'Your personalized daily edition is ready!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.charcoal.withOpacity(0.7),
                        ),
                  ),

                const SizedBox(height: 48),

                // Progress steps
                if (_isGenerating) ...[
                  ...List.generate(_progressSteps.length, (index) {
                    final isCompleted = index <= _currentProgressStep;
                    final isCurrent = index == _currentProgressStep;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : isCurrent
                                    ? Icons.radio_button_unchecked
                                    : Icons.circle_outlined,
                            size: 20,
                            color: isCompleted
                                ? AppTheme.sageGreen
                                : isCurrent
                                    ? AppTheme.terracotta
                                    : AppTheme.charcoal.withOpacity(0.3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _progressSteps[index],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isCompleted
                                        ? AppTheme.sageGreen
                                        : AppTheme.charcoal.withOpacity(0.7),
                                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (!_isGenerating && _status.startsWith('Error'))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _startGeneration,
                      child: const Text('Try Again'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
