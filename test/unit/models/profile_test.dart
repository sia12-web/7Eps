import 'package:flutter_test/flutter_test.dart';
import 'package:sevent_eps/models/profile.dart';
import 'package:sevent_eps/models/profile_photo.dart';

void main() {
  group('Profile Model', () {
    test('should create profile with required fields', () {
      final now = DateTime.now();
      final profile = Profile(
        userId: 'user-123',
        name: 'John Doe',
        age: 25,
        photos: [],
        createdAt: now,
      );

      expect(profile.userId, 'user-123');
      expect(profile.name, 'John Doe');
      expect(profile.age, 25);
      expect(profile.photos, isEmpty);
      expect(profile.isComplete, false);
    });

    test('should calculate completion percentage correctly', () {
      final now = DateTime.now();
      final profile = Profile(
        userId: 'user-123',
        name: 'Jane Doe',
        age: 28,
        bio: 'Love hiking',
        interests: ['hiking', 'coffee'],
        city: 'San Francisco',
        photos: [
          ProfilePhoto(
            id: 'photo1',
            userId: 'user-123',
            url: 'https://example.com/photo.jpg',
            sortOrder: 0,
            createdAt: now,
          ),
        ],
        createdAt: now,
      );

      // All fields filled should be 100%
      expect(profile.completionPercentage, 100);
      expect(profile.isComplete, true);
      expect(profile.hasCompletedOnboarding, true);
    });

    test('should calculate partial completion', () {
      final now = DateTime.now();
      final profile = Profile(
        userId: 'user-123',
        name: 'Test User',
        age: 30,
        photos: [],
        createdAt: now,
      );

      // Only name and age filled (2/6 = 33%)
      expect(profile.completionPercentage, 33);
      expect(profile.isComplete, false);
    });

    test('should serialize and deserialize correctly', () {
      final now = DateTime.now();
      const profileJson = {
        'user_id': 'user-123',
        'name': 'Test User',
        'age': 30,
        'bio': 'Test bio',
        'interests': ['test'],
        'city': 'Test City',
        'university': 'Test University',
        'photos': [],
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T01:00:00.000Z',
      };

      final profile = Profile.fromJson(profileJson);

      expect(profile.userId, 'user-123');
      expect(profile.name, 'Test User');
      expect(profile.age, 30);
    });
  });

  group('Profile CopyWith', () {
    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final profile = Profile(
        userId: 'user-123',
        name: 'John',
        age: 25,
        photos: [],
        createdAt: now,
      );

      final updated = profile.copyWith(name: 'Jane');

      expect(updated.name, 'Jane');
      expect(updated.userId, 'user-123'); // unchanged
      expect(updated.age, 25); // unchanged
    });
  });
}
