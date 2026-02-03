enum MatchStatus { active, archived, completed }

class Match {
  final String id;
  final DateTime createdAt;
  final MatchStatus status;
  final int currentEpisode;
  final DateTime? completedAt;

  const Match({
    required this.id,
    required this.createdAt,
    this.status = MatchStatus.active,
    this.currentEpisode = 1,
    this.completedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        status: _parseStatus(json['status'] as String? ?? 'active'),
        currentEpisode: json['current_episode'] as int? ?? 1,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  static MatchStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return MatchStatus.active;
      case 'archived':
        return MatchStatus.archived;
      case 'completed':
        return MatchStatus.completed;
      default:
        return MatchStatus.active;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'status': status.name,
        'current_episode': currentEpisode,
        'completed_at': completedAt?.toIso8601String(),
      };

  /// Calculate blur amount based on current episode
  double get blurAmount {
    switch (currentEpisode) {
      case 1:
        return 15.0; // Heavy blur (~90% hidden)
      case 2:
        return 7.5; // 25% reveal = 75% blur
      case 3:
        return 3.75; // 50% reveal = 50% blur
      case 4:
        return 1.5; // 75% reveal = 25% blur
      default:
        return 0.0; // Episode 5+: 100% reveal (no blur)
    }
  }

  /// Get unblur percentage for UI display
  int get unblurPercentage {
    switch (currentEpisode) {
      case 1:
        return 10; // Heavy blur
      case 2:
        return 25; // After Episode 1 completion
      case 3:
        return 50; // After Episode 2 completion
      case 4:
        return 75; // After Episode 3 completion
      default:
        return 100; // Episode 5+: Fully revealed
    }
  }

  /// Check if match is completed (all 7 episodes done)
  bool get isCompleted => currentEpisode > 7 || status == MatchStatus.completed;

  /// Check if bio should be visible (episode 2+)
  bool get showBio => currentEpisode >= 2;

  /// Check if interests should be visible (episode 2+)
  bool get showInterests => currentEpisode >= 2;

  /// Check if compatibility score should be visible (episode 3+)
  bool get showCompatibility => currentEpisode >= 3;
}
