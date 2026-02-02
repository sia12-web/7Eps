/// Model for tracking onboarding progress and form data
class OnboardingData {
  final int currentStep;
  final Map<String, dynamic> formData;

  const OnboardingData({
    required this.currentStep,
    this.formData = const {},
  });

  /// Create from JSON (for loading from database)
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    final onboardingStep = json['onboarding_step'] as int? ?? 1;

    // Extract form data from various fields
    final formData = <String, dynamic>{};

    if (json['dob'] != null) formData['dob'] = json['dob'];
    if (json['pronouns'] != null) formData['pronouns'] = json['pronouns'];
    if (json['headline'] != null) formData['headline'] = json['headline'];
    if (json['gender_interest'] != null) {
      formData['genderInterest'] = json['gender_interest'];
    }
    if (json['age_min'] != null) formData['ageMin'] = json['age_min'];
    if (json['age_max'] != null) formData['ageMax'] = json['age_max'];
    if (json['distance_radius'] != null) {
      formData['distanceRadius'] = json['distance_radius'];
    }

    return OnboardingData(
      currentStep: onboardingStep,
      formData: formData,
    );
  }

  /// Convert to JSON (for saving to database)
  Map<String, dynamic> toJson() {
    return {
      'onboarding_step': currentStep,
      ...formData,
    };
  }

  /// Check if onboarding is complete
  bool get isComplete => currentStep >= 11;

  /// Create a copy with updated fields
  OnboardingData copyWith({
    int? currentStep,
    Map<String, dynamic>? formData,
  }) {
    return OnboardingData(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
    );
  }

  /// Update form data for a specific field
  OnboardingData withFormData(String key, dynamic value) {
    final newFormData = Map<String, dynamic>.from(formData);
    newFormData[key] = value;
    return OnboardingData(
      currentStep: currentStep,
      formData: newFormData,
    );
  }

  /// Get form data value by key
  T? getData<T>(String key) {
    return formData[key] as T?;
  }

  @override
  String toString() =>
      'OnboardingData(currentStep: $currentStep, formData keys: ${formData.keys.toList()})';
}
