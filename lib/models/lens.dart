import 'package:flutter/foundation.dart';

class Lens {
  final String id;
  final String key;
  final String name;
  final String description;
  final LensWeightProfile weightProfile;
  final List<String> exampleSignals;

  const Lens({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.weightProfile,
    required this.exampleSignals,
  });

  factory Lens.fromJson(Map<String, dynamic> json) {
    return Lens(
      id: json['lens_id'] as String? ?? json['id'] as String,
      key: json['lens_key'] as String? ?? json['key'] as String,
      name: json['lens_name'] as String? ?? json['name'] as String,
      description: json['lens_description'] as String? ?? json['description'] as String,
      weightProfile: LensWeightProfile.fromJson(
        json['weight_profile'] as Map<String, dynamic>? ?? {},
      ),
      exampleSignals: (json['example_signals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'description': description,
        'weight_profile': weightProfile.toJson(),
        'example_signals': exampleSignals,
      };

  Lens copyWith({
    String? id,
    String? key,
    String? name,
    String? description,
    LensWeightProfile? weightProfile,
    List<String>? exampleSignals,
  }) =>
      Lens(
        id: id ?? this.id,
        key: key ?? this.key,
        name: name ?? this.name,
        description: description ?? this.description,
        weightProfile: weightProfile ?? this.weightProfile,
        exampleSignals: exampleSignals ?? this.exampleSignals,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lens &&
        other.id == id &&
        other.key == key &&
        other.name == name &&
        other.description == description &&
        other.exampleSignals.length == other.exampleSignals.length;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        key.hashCode ^
        name.hashCode ^
        description.hashCode ^
        exampleSignals.hashCode;
  }
}

class LensWeightProfile {
  final Map<String, double> interestBoosts;
  final Map<String, double> interestPenalties;
  final double distanceMultiplier;
  final double sharedInterestBonus;

  const LensWeightProfile({
    this.interestBoosts = const {},
    this.interestPenalties = const {},
    this.distanceMultiplier = 1.0,
    this.sharedInterestBonus = 1.5,
  });

  factory LensWeightProfile.fromJson(Map<String, dynamic> json) {
    final boosts = json['interest_boosts'] as Map<String, dynamic>?;
    final penalties = json['interest_penalties'] as Map<String, dynamic>?;

    return LensWeightProfile(
      interestBoosts: boosts?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      interestPenalties: penalties?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      distanceMultiplier: (json['distance_multiplier'] as num?)?.toDouble() ?? 1.0,
      sharedInterestBonus: (json['shared_interest_bonus'] as num?)?.toDouble() ?? 1.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'interest_boosts': interestBoosts,
        'interest_penalties': interestPenalties,
        'distance_multiplier': distanceMultiplier,
        'shared_interest_bonus': sharedInterestBonus,
      };

  LensWeightProfile copyWith({
    Map<String, double>? interestBoosts,
    Map<String, double>? interestPenalties,
    double? distanceMultiplier,
    double? sharedInterestBonus,
  }) =>
      LensWeightProfile(
        interestBoosts: interestBoosts ?? this.interestBoosts,
        interestPenalties: interestPenalties ?? this.interestPenalties,
        distanceMultiplier: distanceMultiplier ?? this.distanceMultiplier,
        sharedInterestBonus: sharedInterestBonus ?? this.sharedInterestBonus,
      );
}

class UserLens {
  final String userId;
  final Lens lens;
  final int rank; // 1-3

  const UserLens({
    required this.userId,
    required this.lens,
    required this.rank,
  });

  factory UserLens.fromJson(Map<String, dynamic> json) {
    return UserLens(
      userId: json['user_id'] as String,
      lens: Lens.fromJson(json),
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'lens': lens.toJson(),
        'rank': rank,
      };

  UserLens copyWith({
    String? userId,
    Lens? lens,
    int? rank,
  }) =>
      UserLens(
        userId: userId ?? this.userId,
        lens: lens ?? this.lens,
        rank: rank ?? this.rank,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserLens &&
        other.userId == userId &&
        other.lens == lens &&
        other.rank == rank;
  }

  @override
  int get hashCode => userId.hashCode ^ lens.hashCode ^ rank.hashCode;
}
