import 'package:flutter/foundation.dart';
import 'package:sevent_eps/models/profile_photo.dart';

class Profile {
  final String userId;
  final String name;
  final int age;
  final String? bio;
  final List<String>? interests;
  final String? city;
  final String? university;
  final List<ProfilePhoto> photos;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Onboarding fields
  final int? onboardingStep;
  final DateTime? dob;
  final String? pronouns;
  final String? headline;
  final String? genderInterest;
  final int? ageMin;
  final int? ageMax;
  final int? distanceRadius;
  final DateTime? termsAcceptedAt;
  final DateTime? safetyAgreementAcceptedAt;
  final DateTime? onboardingCompletedAt;

  Profile({
    required this.userId,
    required this.name,
    required this.age,
    this.bio,
    this.interests,
    this.city,
    this.university,
    required this.photos,
    required this.createdAt,
    this.updatedAt,
    this.onboardingStep,
    this.dob,
    this.pronouns,
    this.headline,
    this.genderInterest,
    this.ageMin,
    this.ageMax,
    this.distanceRadius,
    this.termsAcceptedAt,
    this.safetyAgreementAcceptedAt,
    this.onboardingCompletedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    // Handle null values safely
    final userId = json['user_id'];
    final name = json['name'];
    final age = json['age'];
    final createdAt = json['created_at'];

    // Parse onboarding step
    final onboardingStep = json['onboarding_step'] as int?;

    // Parse DOB
    DateTime? dob;
    if (json['dob'] != null) {
      try {
        dob = DateTime.parse(json['dob'] as String);
      } catch (e) {
        debugPrint('Failed to parse DOB: ${json['dob']}');
      }
    }

    // Parse timestamps
    DateTime? termsAcceptedAt;
    if (json['terms_accepted_at'] != null) {
      try {
        termsAcceptedAt = DateTime.parse(json['terms_accepted_at'] as String);
      } catch (e) {
        debugPrint('Failed to parse terms_accepted_at');
      }
    }

    DateTime? safetyAgreementAcceptedAt;
    if (json['safety_agreement_accepted_at'] != null) {
      try {
        safetyAgreementAcceptedAt = DateTime.parse(json['safety_agreement_accepted_at'] as String);
      } catch (e) {
        debugPrint('Failed to parse safety_agreement_accepted_at');
      }
    }

    DateTime? onboardingCompletedAt;
    if (json['onboarding_completed_at'] != null) {
      try {
        onboardingCompletedAt = DateTime.parse(json['onboarding_completed_at'] as String);
      } catch (e) {
        debugPrint('Failed to parse onboarding_completed_at');
      }
    }

    // If critical fields are null, provide defaults for onboarding
    return Profile(
      userId: userId as String? ?? '',
      name: name as String? ?? '',
      age: age as int? ?? 0,
      bio: json['bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      city: json['city'] as String?,
      university: json['university'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => ProfilePhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: createdAt != null
          ? DateTime.parse(createdAt as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      onboardingStep: onboardingStep,
      dob: dob,
      pronouns: json['pronouns'] as String?,
      headline: json['headline'] as String?,
      genderInterest: json['gender_interest'] as String?,
      ageMin: json['age_min'] as int?,
      ageMax: json['age_max'] as int?,
      distanceRadius: json['distance_radius'] as int?,
      termsAcceptedAt: termsAcceptedAt,
      safetyAgreementAcceptedAt: safetyAgreementAcceptedAt,
      onboardingCompletedAt: onboardingCompletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'age': age,
        'bio': bio,
        'interests': interests,
        'city': city,
        'university': university,
        'photos': photos.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (onboardingStep != null) 'onboarding_step': onboardingStep,
        if (dob != null) 'dob': dob!.toIso8601String().split('T')[0], // Date only
        if (pronouns != null) 'pronouns': pronouns,
        if (headline != null) 'headline': headline,
        if (genderInterest != null) 'gender_interest': genderInterest,
        if (ageMin != null) 'age_min': ageMin,
        if (ageMax != null) 'age_max': ageMax,
        if (distanceRadius != null) 'distance_radius': distanceRadius,
        if (termsAcceptedAt != null) 'terms_accepted_at': termsAcceptedAt!.toIso8601String(),
        if (safetyAgreementAcceptedAt != null) 'safety_agreement_accepted_at': safetyAgreementAcceptedAt!.toIso8601String(),
        if (onboardingCompletedAt != null) 'onboarding_completed_at': onboardingCompletedAt!.toIso8601String(),
      };

  /// Check if profile is complete (ready for matching)
  bool get isComplete {
    final result = name.isNotEmpty &&
        age >= 18 &&
        (bio?.isNotEmpty ?? false) &&
        (interests?.isNotEmpty ?? false) &&
        (city?.isNotEmpty ?? false) &&
        photos.isNotEmpty;

    // Debug logging
    debugPrint('📊 isComplete check: $result');
    debugPrint('   - name.isNotEmpty: ${name.isNotEmpty} (name: "$name")');
    debugPrint('   - age >= 18: $age >= 18 (age: $age)');
    debugPrint('   - bio?.isNotEmpty: ${bio?.isNotEmpty ?? false}');
    debugPrint('   - interests?.isNotEmpty: ${interests?.isNotEmpty ?? false} (${interests?.length ?? 0} interests)');
    debugPrint('   - city?.isNotEmpty: ${city?.isNotEmpty ?? false}');
    debugPrint('   - photos.isNotEmpty: ${photos.isNotEmpty} (${photos.length} photos)');

    return result;
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding => isComplete;

  /// Get completion percentage (0-100)
  int get completionPercentage {
    int completed = 0;
    int total = 6; // name, age, bio, interests, city, photos

    if (name.isNotEmpty) completed++;
    if (age >= 18) completed++;
    if (bio?.isNotEmpty ?? false) completed++;
    if (interests?.isNotEmpty ?? false) completed++;
    if (city?.isNotEmpty ?? false) completed++;
    if (photos.isNotEmpty) completed++;

    final percentage = ((completed / total) * 100).round();

    // Debug logging
    debugPrint('📊 Completion: $percentage% ($completed/\$6)');
    debugPrint('   - name: ${name.isNotEmpty ? "✅" : "❌"}');
    debugPrint('   - age: ${age >= 18 ? "✅" : "❌"} ($age)');
    debugPrint('   - bio: ${bio?.isNotEmpty ?? false ? "✅" : "❌"}');
    debugPrint('   - interests: ${interests?.isNotEmpty ?? false ? "✅" : "❌"} (${interests?.length ?? 0})');
    debugPrint('   - city: ${city?.isNotEmpty ?? false ? "✅" : "❌"}');
    debugPrint('   - photos: ${photos.isNotEmpty ? "✅" : "❌"} (${photos.length})');

    return percentage;
  }

  Profile copyWith({
    String? userId,
    String? name,
    int? age,
    String? bio,
    List<String>? interests,
    String? city,
    String? university,
    List<ProfilePhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? onboardingStep,
    DateTime? dob,
    String? pronouns,
    String? headline,
    String? genderInterest,
    int? ageMin,
    int? ageMax,
    int? distanceRadius,
    DateTime? termsAcceptedAt,
    DateTime? safetyAgreementAcceptedAt,
    DateTime? onboardingCompletedAt,
  }) =>
      Profile(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        age: age ?? this.age,
        bio: bio ?? this.bio,
        interests: interests ?? this.interests,
        city: city ?? this.city,
        university: university ?? this.university,
        photos: photos ?? this.photos,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        onboardingStep: onboardingStep ?? this.onboardingStep,
        dob: dob ?? this.dob,
        pronouns: pronouns ?? this.pronouns,
        headline: headline ?? this.headline,
        genderInterest: genderInterest ?? this.genderInterest,
        ageMin: ageMin ?? this.ageMin,
        ageMax: ageMax ?? this.ageMax,
        distanceRadius: distanceRadius ?? this.distanceRadius,
        termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
        safetyAgreementAcceptedAt: safetyAgreementAcceptedAt ?? this.safetyAgreementAcceptedAt,
        onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
      );
}
