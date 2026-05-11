class MatchParticipantEntity {
  final String id;
  final String matchId;
  final String userId;
  final String? userName;
  final String? avatarUrl;
  final String? team;
  final String? result;
  final int? eloBefore;
  final int? eloAfter;
  final int? eloDelta;

  const MatchParticipantEntity({
    required this.id,
    required this.matchId,
    required this.userId,
    this.userName,
    this.avatarUrl,
    this.team,
    this.result,
    this.eloBefore,
    this.eloAfter,
    this.eloDelta,
  });

  bool get isWin => result == 'win';
  bool get isLoss => result == 'loss';
  bool get isDraw => result == 'draw';

  factory MatchParticipantEntity.fromMap(Map<String, dynamic> map) {
    final profile = map['profile'] as Map<String, dynamic>?;
    return MatchParticipantEntity(
      id: map['id'],
      matchId: map['match_id'],
      userId: map['user_id'],
      userName: profile?['full_name'] ?? map['full_name'],
      avatarUrl: profile?['avatar_url'] ?? map['avatar_url'],
      team: map['team'],
      result: map['result'],
      eloBefore: map['elo_before'],
      eloAfter: map['elo_after'],
      eloDelta: map['elo_delta'],
    );
  }
}
