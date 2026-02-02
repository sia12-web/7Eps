import 'package:flutter_test/flutter_test.dart';
import 'package:sevent_eps/models/match.dart';

void main() {
  group('Match Model', () {
    test('should calculate correct blur amount for episode 1', () {
      const match = Match(
        id: '1',
        createdAt: Duration(seconds: 0) as DateTime,
        currentEpisode: 1,
      );

      expect(match.blurAmount, 10.0);
      expect(match.unblurPercentage, 25);
      expect(match.showBio, false);
      expect(match.showInterests, false);
      expect(match.showCompatibility, false);
    });

    test('should calculate correct blur amount for episode 2', () {
      const match = Match(
        id: '2',
        createdAt: Duration(seconds: 0) as DateTime,
        currentEpisode: 2,
      );

      expect(match.blurAmount, 5.0);
      expect(match.unblurPercentage, 50);
      expect(match.showBio, true);
      expect(match.showInterests, true);
      expect(match.showCompatibility, false);
    });

    test('should calculate correct blur amount for episode 3', () {
      const match = Match(
        id: '3',
        createdAt: Duration(seconds: 0) as DateTime,
        currentEpisode: 3,
      );

      expect(match.blurAmount, 2.5);
      expect(match.unblurPercentage, 75);
      expect(match.showBio, true);
      expect(match.showInterests, true);
      expect(match.showCompatibility, true);
    });

    test('should have no blur for episode 4+', () {
      const match = Match(
        id: '4',
        createdAt: Duration(seconds: 0) as DateTime,
        currentEpisode: 4,
      );

      expect(match.blurAmount, 0.0);
      expect(match.unblurPercentage, 100);
    });

    test('should identify completed matches', () {
      const completedMatch = Match(
        id: 'completed',
        createdAt: Duration(seconds: 0) as DateTime,
        status: MatchStatus.completed,
        currentEpisode: 8,
      );

      expect(completedMatch.isCompleted, true);
    });

    test('should identify active matches', () {
      const activeMatch = Match(
        id: 'active',
        createdAt: Duration(seconds: 0) as DateTime,
        status: MatchStatus.active,
        currentEpisode: 3,
      );

      expect(activeMatch.isCompleted, false);
    });
  });
}
