import 'package:flutter_test/flutter_test.dart';
import 'package:sevent_eps/models/match.dart';

void main() {
  group('Match Model', () {
    final now = DateTime.now();

    test('should calculate correct blur amount for episode 1', () {
      final match = Match(
        id: '1',
        createdAt: now,
        currentEpisode: 1,
      );

      expect(match.blurAmount, 15.0);
      expect(match.unblurPercentage, 10);
      expect(match.showBio, false);
      expect(match.showInterests, false);
      expect(match.showCompatibility, false);
    });

    test('should calculate correct blur amount for episode 2', () {
      final match = Match(
        id: '2',
        createdAt: now,
        currentEpisode: 2,
      );

      expect(match.blurAmount, 7.5);
      expect(match.unblurPercentage, 25);
      expect(match.showBio, true);
      expect(match.showInterests, true);
      expect(match.showCompatibility, false);
    });

    test('should calculate correct blur amount for episode 3', () {
      final match = Match(
        id: '3',
        createdAt: now,
        currentEpisode: 3,
      );

      expect(match.blurAmount, 3.75);
      expect(match.unblurPercentage, 50);
      expect(match.showBio, true);
      expect(match.showInterests, true);
      expect(match.showCompatibility, true);
    });

    test('should have no blur for episode 4+', () {
      final match = Match(
        id: '4',
        createdAt: now,
        currentEpisode: 4,
      );

      expect(match.blurAmount, 1.5);
      expect(match.unblurPercentage, 75);
    });

    test('should have no blur for episode 5+', () {
      final match = Match(
        id: '5',
        createdAt: now,
        currentEpisode: 5,
      );

      expect(match.blurAmount, 0.0);
      expect(match.unblurPercentage, 100);
    });

    test('should identify completed matches', () {
      final completedMatch = Match(
        id: 'completed',
        createdAt: now,
        status: MatchStatus.completed,
        currentEpisode: 8,
      );

      expect(completedMatch.isCompleted, true);
    });

    test('should identify active matches', () {
      final activeMatch = Match(
        id: 'active',
        createdAt: now,
        status: MatchStatus.active,
        currentEpisode: 3,
      );

      expect(activeMatch.isCompleted, false);
    });
  });
}
