import 'package:flutter/foundation.dart';

class DailyEdition {
  final String id;
  final String userId;
  final DateTime editionDate;
  final List<String> candidateUserIds;
  final DateTime createdAt;

  const DailyEdition({
    required this.id,
    required this.userId,
    required this.editionDate,
    required this.candidateUserIds,
    required this.createdAt,
  });

  factory DailyEdition.fromJson(Map<String, dynamic> json) {
    return DailyEdition(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      editionDate: DateTime.parse(json['edition_date'] as String),
      candidateUserIds: (json['candidate_user_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'edition_date': editionDate.toIso8601String(),
        'candidate_user_ids': candidateUserIds,
        'created_at': createdAt.toIso8601String(),
      };

  /// Check if this edition is for today
  bool get isToday {
    final now = DateTime.now();
    return editionDate.year == now.year &&
        editionDate.month == now.month &&
        editionDate.day == now.day;
  }

  /// Get the number of candidates
  int get candidateCount => candidateUserIds.length;

  DailyEdition copyWith({
    String? id,
    String? userId,
    DateTime? editionDate,
    List<String>? candidateUserIds,
    DateTime? createdAt,
  }) =>
      DailyEdition(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        editionDate: editionDate ?? this.editionDate,
        candidateUserIds: candidateUserIds ?? this.candidateUserIds,
        createdAt: createdAt ?? this.createdAt,
      );
}
