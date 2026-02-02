import 'package:flutter/foundation.dart';
import 'package:sevent_eps/models/profile_photo.dart';

class Candidate {
  final String userId;
  final String name;
  final int age;
  final String? city;
  final ProfilePhoto? photo;
  final String tagline;

  const Candidate({
    required this.userId,
    required this.name,
    required this.age,
    this.city,
    this.photo,
    required this.tagline,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Candidate.fromJson - Keys: ${json.keys.toList()}');
    debugPrint('   - candidate_user_id: ${json['candidate_user_id']}');
    debugPrint('   - candidate_name: ${json['candidate_name']}');
    debugPrint('   - candidate_age: ${json['candidate_age']}');
    debugPrint('   - candidate_city: ${json['candidate_city']}');
    debugPrint('   - candidate_photo_url: ${json['candidate_photo_url']}');
    debugPrint('   - candidate_tagline: ${json['candidate_tagline']}');

    return Candidate(
      userId: json['candidate_user_id'] as String,
      name: json['candidate_name'] as String,
      age: json['candidate_age'] as int,
      city: json['candidate_city'] as String?,
      photo: json['candidate_photo_url'] != null
          ? ProfilePhoto(
              id: '', // Not needed for candidate card
              userId: json['candidate_user_id'] as String,
              url: json['candidate_photo_url'] as String,
              sortOrder: 0,
              createdAt: DateTime.now(),
            )
          : null,
      tagline: json['candidate_tagline'] as String? ?? 'Exploring',
    );
  }

  /// Create candidate from full profile
  factory Candidate.fromProfile(Map<String, dynamic> profileJson) {
    final userId = profileJson['user_id'] as String;
    final interests = profileJson['interests'] as List<dynamic>?;
    final city = profileJson['city'] as String?;

    // Generate tagline from first interest or city
    String tagline;
    if (interests != null && interests.isNotEmpty) {
      final firstInterest = interests.first['name'] as String? ?? 'Something';
      tagline = '${_capitalize(firstInterest)} enthusiast';
    } else {
      tagline = 'Exploring ${city ?? 'the world'}';
    }

    // Get first photo
    final photos = profileJson['photos'] as List<dynamic>?;
    ProfilePhoto? photo;
    if (photos != null && photos.isNotEmpty) {
      photo = ProfilePhoto.fromJson(photos.first as Map<String, dynamic>);
    }

    return Candidate(
      userId: userId,
      name: profileJson['name'] as String,
      age: profileJson['age'] as int,
      city: city,
      photo: photo,
      tagline: tagline,
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Map<String, dynamic> toJson() => {
        'candidate_user_id': userId,
        'candidate_name': name,
        'candidate_age': age,
        'candidate_city': city,
        'candidate_photo_url': photo?.url,
        'candidate_tagline': tagline,
      };

  Candidate copyWith({
    String? userId,
    String? name,
    int? age,
    String? city,
    ProfilePhoto? photo,
    String? tagline,
  }) =>
      Candidate(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        age: age ?? this.age,
        city: city ?? this.city,
        photo: photo ?? this.photo,
        tagline: tagline ?? this.tagline,
      );
}
