import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevent_eps/core/theme/app_theme.dart';
import 'package:sevent_eps/models/onboarding_data.dart';
import 'package:sevent_eps/providers/onboarding_provider.dart';
import 'package:sevent_eps/features/onboarding/steps/welcome_slides_step.dart';
import 'package:sevent_eps/features/onboarding/steps/age_gate_step.dart';
import 'package:sevent_eps/features/onboarding/steps/basics_step.dart';
import 'package:sevent_eps/features/onboarding/steps/interests_step.dart';
import 'package:sevent_eps/features/onboarding/steps/photos_step.dart';
import 'package:sevent_eps/features/onboarding/steps/preferences_step.dart';
import 'package:sevent_eps/features/onboarding/steps/safety_step.dart';
import 'package:sevent_eps/features/onboarding/steps/tutorial_step.dart';
import 'package:sevent_eps/features/onboarding/steps/generate_daily_edition_step.dart';

/// Main onboarding flow screen container
/// Manages step navigation, progress indicator, and step state
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const OnboardingFlowScreen({
    super.key,
    this.initialStep = 1,
  });

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final int _totalSteps = 11; // Reduced from 12 after removing Auth step

  int get _currentStep => widget.initialStep;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 OnboardingFlowScreen init: step $_currentStep');
  }

  void _nextStep() {
    debugPrint('➡️ _nextStep called: current=$_currentStep, total=$_totalSteps');

    if (_currentStep < _totalSteps) {
      // Navigate first, then update state
      final nextStep = _currentStep + 1;
      debugPrint('🌐 Navigating to: /onboarding/$nextStep');

      context.go('/onboarding/$nextStep');

      // State will be updated when the widget rebuilds with new initialStep
    } else {
      // Onboarding complete - should be handled by final step
      debugPrint('✅ Onboarding complete!');
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      // Navigate first, then state will update on rebuild
      final prevStep = _currentStep - 1;
      context.go('/onboarding/$prevStep');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncOnboarding = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator (skip for welcome slides)
            if (_currentStep > 3) _buildProgressIndicator(),

            // Step content
            Expanded(
              child: asyncOnboarding.when(
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
                          'Unable to load onboarding',
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
                          onPressed: () => ref.read(onboardingProvider.notifier).refresh(),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (onboardingData) {
                  return _buildStepContent(onboardingData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Horizontal segmented bar
          Row(
            children: List.generate(_totalSteps, (index) {
              final step = index + 1;
              final isCompleted = step < _currentStep;
              final isCurrent = step == _currentStep;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.sageGreen
                        : isCurrent
                            ? AppTheme.terracotta
                            : AppTheme.charcoal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step $_currentStep of $_totalSteps',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.charcoal.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingData onboardingData) {
    // Route to appropriate step screen
    switch (_currentStep) {
      case 1:
        // Welcome slides - only show on step 1
        return WelcomeSlidesStep(
          initialSlide: 0,
          currentStep: _currentStep,
          onContinue: () {
            // Skip steps 2 and 3, go directly to step 4 (Age Gate)
            debugPrint('✅ Welcome slides complete, navigating to step 4 (Age Gate)');
            context.go('/onboarding/4');
          },
        );

      case 2:
      case 3:
        // Steps 2 and 3 are part of welcome slides - auto-advance to step 4
        debugPrint('⚠️ User accessed step $_currentStep directly, auto-advancing to step 4');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/onboarding/4');
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case 4:
        // Age gate
        return AgeGateStep(
          onContinue: _nextStep,
          onBack: _currentStep > 1 ? _previousStep : null,
        );

      case 5:
        // Basics (moved from step 6)
        return BasicsStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 6:
        // Interests (moved from step 7)
        return InterestsStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 7:
        // Photos (moved from step 8)
        return PhotosStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 8:
        // Preferences (moved from step 9)
        return PreferencesStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 9:
        // Safety agreement (moved from step 10)
        return SafetyStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 10:
        // Tutorial (moved from step 11)
        return TutorialStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );

      case 11:
        // Generate daily edition (moved from step 12)
        return const GenerateDailyEditionStep();

      default:
        // Fallback
        return Center(
          child: Text('Unknown step: $_currentStep'),
        );
    }
  }
}
