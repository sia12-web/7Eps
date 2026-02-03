enum ArtifactType {
  promptAnswer,
  voice,
  photo,
  tags,
  dealbreakers,
  scenario,
  dateChoice,
}

class Artifact {
  final String id;
  final String matchId;
  final String userId;
  final int episode;
  final ArtifactType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Artifact({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.episode,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  factory Artifact.fromJson(Map<String, dynamic> json) => Artifact(
        id: json['id'] as String,
        matchId: json['match_id'] as String,
        userId: json['user_id'] as String,
        episode: json['episode'] as int,
        type: _parseType(json['type'] as String),
        payload: json['payload'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  static ArtifactType _parseType(String type) {
    return type == 'prompt_answer'
        ? ArtifactType.promptAnswer
        : ArtifactType.values.firstWhere(
            (e) => e.name == type,
            orElse: () => ArtifactType.promptAnswer,
          );
  }

  /// Public method to parse artifact type from string
  static ArtifactType fromString(String type) {
    return _parseType(type);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'match_id': matchId,
        'user_id': userId,
        'episode': episode,
        'type': type.name,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Helper to get required artifact type for each episode
ArtifactType getArtifactTypeForEpisode(int episode) {
  switch (episode) {
    case 1:
      return ArtifactType.promptAnswer;
    case 2:
      return ArtifactType.voice;
    case 3:
      return ArtifactType.tags;
    case 4:
      return ArtifactType.photo;
    case 5:
      return ArtifactType.dealbreakers;
    case 6:
      return ArtifactType.scenario;
    case 7:
      return ArtifactType.dateChoice;
    default:
      throw ArgumentError('Invalid episode: $episode');
  }
}

/// Episode definitions with titles and descriptions
final Map<int, Map<String, String>> episodeDefinitions = {
  1: {
    'title': 'The First Spark',
    'description': 'Share a funny anecdote that makes you unique',
    'prompt':
        'What\'s a harmless habit or quirk of yours that always makes people laugh?',
  },
  2: {
    'title': 'Voice Connection',
    'description': 'Share a 30-second voice note about your perfect Sunday',
    'prompt': 'Describe your ideal Sunday morning in 30 seconds',
  },
  3: {
    'title': 'Perfect Sunday',
    'description': 'Share what your perfect Sunday looks like',
    'prompt': 'Tag 3 activities that make your perfect Sunday',
  },
  4: {
    'title': 'Candid Moment',
    'description': 'Share a candid photo behind your profile photos',
    'prompt': 'A photo that shows the real you',
  },
  5: {
    'title': 'Dealbreakers',
    'description': 'Share your non-negotiables in a relationship',
    'prompt': 'What are 3 things you absolutely cannot compromise on?',
  },
  6: {
    'title': 'Shared Future',
    'description': 'Collaborate on a scenario together',
    'prompt': 'If we could go anywhere together, where would we go and why?',
  },
  7: {
    'title': 'The Meeting',
    'description': 'Suggest date ideas and make it happen',
    'prompt': 'Share 3 date suggestions you\'d be excited about',
  },
};
