import 'package:flutter_test/flutter_test.dart';
import 'package:sevent_eps/models/artifact.dart';

void main() {
  group('Artifact Type Helpers', () {
    test('should return correct artifact type for each episode', () {
      expect(getArtifactTypeForEpisode(1), ArtifactType.promptAnswer);
      expect(getArtifactTypeForEpisode(2), ArtifactType.voice);
      expect(getArtifactTypeForEpisode(3), ArtifactType.tags);
      expect(getArtifactTypeForEpisode(4), ArtifactType.photo);
      expect(getArtifactTypeForEpisode(5), ArtifactType.dealbreakers);
      expect(getArtifactTypeForEpisode(6), ArtifactType.scenario);
      expect(getArtifactTypeForEpisode(7), ArtifactType.dateChoice);
    });

    test('should throw error for invalid episode', () {
      expect(
        () => getArtifactTypeForEpisode(8),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => getArtifactTypeForEpisode(0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Episode Definitions', () {
    test('should have all 7 episodes defined', () {
      expect(episodeDefinitions.length, 7);

      for (int i = 1; i <= 7; i++) {
        expect(episodeDefinitions.containsKey(i), true);
        expect(episodeDefinitions[i]!['title'], isNotEmpty);
        expect(episodeDefinitions[i]!['description'], isNotEmpty);
        expect(episodeDefinitions[i]!['prompt'], isNotEmpty);
      }
    });

    test('episode 1 should be about funny anecdote', () {
      final ep1 = episodeDefinitions[1]!;
      expect(ep1['title'], contains('First Spark'));
      expect(ep1['prompt'], contains('laugh'));
    });

    test('episode 2 should be about voice note', () {
      final ep2 = episodeDefinitions[2]!;
      expect(ep2['title'], contains('Voice'));
      expect(ep2['description'], contains('30-second'));
    });

    test('episode 7 should be about date suggestions', () {
      final ep7 = episodeDefinitions[7]!;
      expect(ep7['title'], contains('Meeting'));
      expect(ep7['prompt'], contains('date suggestions'));
    });
  });
}
