import 'package:beesports/models/sport_type.dart';

class MatchEntity {
  final String id;
  final String lobbyId;
  final SportType sport;
  final DateTime playedAt;
  final int? durationMinutes;
  final int teamAScore;
  final int teamBScore;
  final Map<String, dynamic> eloChanges;
  final bool settled;
  final DateTime createdAt;

  const MatchEntity({
    required this.id,
    required this.lobbyId,
    required this.sport,
    required this.playedAt,
    this.durationMinutes,
    required this.teamAScore,
    required this.teamBScore,
    this.eloChanges = const {},
    this.settled = false,
    required this.createdAt,
  });

  String get resultLabel {
    if (teamAScore > teamBScore) return 'Team A Wins';
    if (teamBScore > teamAScore) return 'Team B Wins';
    return 'Draw';
  }

  factory MatchEntity.fromMap(Map<String, dynamic> map) {
    return MatchEntity(
      id: map['id'],
      lobbyId: map['lobby_id'],
      sport: SportType.fromString(map['sport']) ?? SportType.futsal,
      playedAt: DateTime.parse(map['played_at']),
      durationMinutes: map['duration_minutes'],
      teamAScore: map['team_a_score'] ?? 0,
      teamBScore: map['team_b_score'] ?? 0,
      eloChanges: map['elo_changes'] is Map
          ? Map<String, dynamic>.from(map['elo_changes'])
          : {},
      settled: map['settled'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
