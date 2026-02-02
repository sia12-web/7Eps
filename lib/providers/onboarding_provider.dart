import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevent_eps/models/onboarding_data.dart';

/// State notifier for managing onboarding progress
class OnboardingState extends StateNotifier<AsyncValue<OnboardingData>> {
  OnboardingState() : super(const AsyncValue.loading()) {
    _loadOnboardingState();
  }

  /// Load onboarding state from database
  Future<void> _loadOnboardingState() async {
    debugPrint('📋 ===== LOAD ONBOARDING STATE =====');

    state = const AsyncValue.loading();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Not authenticated');
        state = const AsyncValue.data(OnboardingData(currentStep: 1));
        return;
      }

      debugPrint('📖 Fetching onboarding data for user: $userId');

      final response = await Supabase.instance.client
          .from('profiles')
          .select('onboarding_step, dob, pronouns, headline, gender_interest, age_min, age_max, distance_radius')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No profile found, starting onboarding at step 1');
        state = const AsyncValue.data(OnboardingData(currentStep: 1));
        return;
      }

      final data = OnboardingData.fromJson(response);
      debugPrint('✅ Onboarding state loaded: step ${data.currentStep}');

      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR loading onboarding state: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Save onboarding step data to database
  Future<void> saveStep(int step, Map<String, dynamic> data) async {
    debugPrint('💾 ===== SAVE ONBOARDING STEP =====');
    debugPrint('💾 Step: $step');
    debugPrint('💾 Data: ${data.keys.toList()}');

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'onboarding_step': step,
        ...data,
      };

      await Supabase.instance.client
          .from('profiles')
          .update(updateData)
          .eq('user_id', userId);

      debugPrint('✅ Step saved successfully');

      // Update local state
      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(
          currentData.copyWith(
            currentStep: step,
            formData: {...currentData.formData, ...data},
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR saving step: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Update specific form data field
  Future<void> updateField(String key, dynamic value) async {
    debugPrint('📝 ===== UPDATE ONBOARDING FIELD =====');
    debugPrint('📝 Key: $key');
    debugPrint('📝 Value: $value');

    try {
      final currentData = state.value;
      if (currentData == null) {
        throw Exception('No onboarding data loaded');
      }

      // Save to database
      await saveStep(currentData.currentStep, {key: value});

      debugPrint('✅ Field updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR updating field: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    debugPrint('🎉 ===== COMPLETE ONBOARDING =====');

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      await Supabase.instance.client
          .from('profiles')
          .update({
            'onboarding_step': 11,
            'onboarding_completed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      debugPrint('✅ Onboarding marked as complete');

      // Update local state
      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(currentData.copyWith(currentStep: 11));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR completing onboarding: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    debugPrint('🔄 ===== RESET ONBOARDING =====');

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      await Supabase.instance.client
          .from('profiles')
          .update({'onboarding_step': 1})
          .eq('user_id', userId);

      debugPrint('✅ Onboarding reset');

      // Reload state
      await _loadOnboardingState();
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR resetting onboarding: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Refresh onboarding state
  Future<void> refresh() => _loadOnboardingState();
}

/// Provider for onboarding state
final onboardingProvider =
    StateNotifierProvider<OnboardingState, AsyncValue<OnboardingData>>((ref) {
  return OnboardingState();
});
