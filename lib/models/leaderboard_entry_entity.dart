import 'package:beesports/models/sport_type.dart';

class LeaderboardEntryEntity {
  final String userId;
  final String? fullName;
  final String? campus;
  final String? avatarUrl;
  final SportType sport;
  final int eloRating;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final double winRate;
  final int sportRank;
  final int campusRank;

  const LeaderboardEntryEntity({
    required this.userId,
    this.fullName,
    this.campus,
    this.avatarUrl,
    required this.sport,
    required this.eloRating,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.sportRank,
    required this.campusRank,
  });

  factory LeaderboardEntryEntity.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryEntity(
      userId: map['user_id'],
      fullName: map['full_name'],
      campus: map['campus'],
      avatarUrl: map['avatar_url'],
      sport: SportType.fromString(map['sport']) ?? SportType.futsal,
      eloRating: map['elo_rating'] ?? 1000,
      matchesPlayed: map['matches_played'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      winRate: (map['win_rate'] ?? 0).toDouble(),
      sportRank: map['sport_rank'] ?? 0,
      campusRank: map['campus_rank'] ?? 0,
    );
  }
}
