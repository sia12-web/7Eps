import 'package:sevent_eps/models/artifact.dart';

class Episode {
  final int number;
  final String title;
  final String description;
  final String prompt;
  final ArtifactType artifactType;
  final int unblurReward;

  Episode({
    required this.number,
    required this.title,
    required this.description,
    required this.prompt,
    required this.artifactType,
    required this.unblurReward,
  });

  /// All 7 episodes with their configurations
  static List<Episode> get allEpisodes => [
        Episode(
          number: 1,
          title: 'The First Spark',
          description: 'Share a funny anecdote that makes you unique',
          prompt:
              'What\'s a harmless habit or quirk of yours that always makes people laugh?',
          artifactType: ArtifactType.promptAnswer,
          unblurReward: 25,
        ),
        Episode(
          number: 2,
          title: 'Voice Connection',
          description: 'Share a 30-second voice note about your perfect Sunday',
          prompt: 'Describe your ideal Sunday morning in 30 seconds',
          artifactType: ArtifactType.voice,
          unblurReward: 50,
        ),
        Episode(
          number: 3,
          title: 'Perfect Sunday',
          description: 'Share what your perfect Sunday looks like',
          prompt: 'Tag 3 activities that make your perfect Sunday',
          artifactType: ArtifactType.tags,
          unblurReward: 75,
        ),
        Episode(
          number: 4,
          title: 'Candid Moment',
          description: 'Share a candid photo behind your profile photos',
          prompt: 'A photo that shows the real you',
          artifactType: ArtifactType.photo,
          unblurReward: 100,
        ),
        Episode(
          number: 5,
          title: 'Dealbreakers',
          description: 'Share your non-negotiables in a relationship',
          prompt: 'What are 3 things you absolutely cannot compromise on?',
          artifactType: ArtifactType.dealbreakers,
          unblurReward: 100,
        ),
        Episode(
          number: 6,
          title: 'Shared Future',
          description: 'Collaborate on a scenario together',
          prompt: 'If we could go anywhere together, where would we go and why?',
          artifactType: ArtifactType.scenario,
          unblurReward: 100,
        ),
        Episode(
          number: 7,
          title: 'The Meeting',
          description: 'Suggest date ideas and make it happen',
          prompt: 'Share 3 date suggestions you\'d be excited about',
          artifactType: ArtifactType.dateChoice,
          unblurReward: 100,
        ),
      ];
}
