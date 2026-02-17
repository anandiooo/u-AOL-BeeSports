import 'package:beesports/shared/models/skill_level.dart';
import 'package:beesports/shared/models/sport_type.dart';
import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? nim;
  final String? campus;
  final String role;
  final String bio;
  final String? avatarUrl;
  final List<SportType> sportPreferences;
  final Map<SportType, SkillLevel> skillLevels;
  final int eloRating;
  final int reliabilityScore;
  final double sportsmanshipRating;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final bool isOnboarded;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.nim,
    this.campus,
    this.role = 'player',
    this.bio = '',
    this.avatarUrl,
    this.sportPreferences = const [],
    this.skillLevels = const {},
    this.eloRating = 1000,
    this.reliabilityScore = 100,
    this.sportsmanshipRating = 5.0,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.isOnboarded = false,
    this.createdAt,
    this.updatedAt,
  });

  double get winRate => matchesPlayed > 0 ? (wins / matchesPlayed) * 100 : 0.0;

  ProfileEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nim,
    String? campus,
    String? role,
    String? bio,
    String? avatarUrl,
    List<SportType>? sportPreferences,
    Map<SportType, SkillLevel>? skillLevels,
    int? eloRating,
    int? reliabilityScore,
    double? sportsmanshipRating,
    int? matchesPlayed,
    int? wins,
    int? losses,
    bool? isOnboarded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nim: nim ?? this.nim,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sportPreferences: sportPreferences ?? this.sportPreferences,
      skillLevels: skillLevels ?? this.skillLevels,
      eloRating: eloRating ?? this.eloRating,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      sportsmanshipRating: sportsmanshipRating ?? this.sportsmanshipRating,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    final sportPrefs = (map['sport_preferences'] as List<dynamic>?)
            ?.map((s) => SportType.fromString(s as String))
            .whereType<SportType>()
            .toList() ??
        [];

    final skillMap = <SportType, SkillLevel>{};
    final rawSkills = map['skill_levels'] as Map<String, dynamic>?;
    if (rawSkills != null) {
      for (final entry in rawSkills.entries) {
        final sport = SportType.fromString(entry.key);
        final level = SkillLevel.fromString(entry.value as String);
        if (sport != null && level != null) {
          skillMap[sport] = level;
        }
      }
    }

    return ProfileEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      nim: map['nim'] as String?,
      campus: map['campus'] as String?,
      role: (map['role'] as String?) ?? 'player',
      bio: (map['bio'] as String?) ?? '',
      avatarUrl: map['avatar_url'] as String?,
      sportPreferences: sportPrefs,
      skillLevels: skillMap,
      eloRating: (map['elo_rating'] as int?) ?? 1000,
      reliabilityScore: (map['reliability_score'] as int?) ?? 100,
      sportsmanshipRating:
          (map['sportsmanship_rating'] as num?)?.toDouble() ?? 5.0,
      matchesPlayed: (map['matches_played'] as int?) ?? 0,
      wins: (map['wins'] as int?) ?? 0,
      losses: (map['losses'] as int?) ?? 0,
      isOnboarded: (map['is_onboarded'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'nim': nim,
      'campus': campus,
      'role': role,
      'bio': bio,
      'avatar_url': avatarUrl,
      'sport_preferences': sportPreferences.map((s) => s.name).toList(),
      'skill_levels': skillLevels.map(
        (sport, level) => MapEntry(sport.name, level.name),
      ),
      'is_onboarded': isOnboarded,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        nim,
        campus,
        role,
        bio,
        avatarUrl,
        sportPreferences,
        skillLevels,
        eloRating,
        reliabilityScore,
        sportsmanshipRating,
        matchesPlayed,
        wins,
        losses,
        isOnboarded,
        createdAt,
        updatedAt,
      ];
}
