import 'package:beesports/models/participant_status.dart';
import 'package:equatable/equatable.dart';

class LobbyParticipantEntity extends Equatable {
  final String id;
  final String lobbyId;
  final String userId;
  final String? userName;
  final String? avatarUrl;
  final ParticipantStatus status;
  final String? team;
  final int? position;
  final bool depositHeld;
  final DateTime? confirmedAt;
  final DateTime? mustConfirmBy;
  final DateTime joinedAt;
  final DateTime? leftAt;

  const LobbyParticipantEntity({
    required this.id,
    required this.lobbyId,
    required this.userId,
    this.userName,
    this.avatarUrl,
    this.status = ParticipantStatus.joined,
    this.team,
    this.position,
    this.depositHeld = false,
    this.confirmedAt,
    this.mustConfirmBy,
    required this.joinedAt,
    this.leftAt,
  });

  bool get isActive =>
      status == ParticipantStatus.joined ||
      status == ParticipantStatus.confirmed;

  factory LobbyParticipantEntity.fromMap(Map<String, dynamic> map) {
    final profile =
        map['profiles'] is Map ? map['profiles'] as Map<String, dynamic> : null;

    return LobbyParticipantEntity(
      id: map['id'] as String,
      lobbyId: map['lobby_id'] as String,
      userId: map['user_id'] as String,
      userName: profile?['full_name'] as String? ?? map['user_name'] as String?,
      avatarUrl:
          profile?['avatar_url'] as String? ?? map['avatar_url'] as String?,
      status:
          ParticipantStatus.fromString(map['status'] as String? ?? 'joined') ??
              ParticipantStatus.joined,
      team: map['team'] as String?,
      position: map['position'] as int?,
      depositHeld: (map['deposit_held'] as bool?) ?? false,
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'] as String)
          : null,
      mustConfirmBy: map['must_confirm_by'] != null
          ? DateTime.parse(map['must_confirm_by'] as String)
          : null,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      leftAt: map['left_at'] != null
          ? DateTime.parse(map['left_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lobbyId,
        userId,
        userName,
        avatarUrl,
        status,
        team,
        position,
        depositHeld,
        confirmedAt,
        mustConfirmBy,
        joinedAt,
        leftAt,
      ];
}
