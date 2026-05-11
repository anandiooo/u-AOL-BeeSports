import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:equatable/equatable.dart';

class LobbyEntity extends Equatable {
  final String id;
  final String hostId;
  final String? hostName;
  final String? fieldId;
  final String title;
  final SportType sport;
  final String description;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int minPlayers;
  final int maxPlayers;
  final int currentPlayers;
  final int? minElo;
  final int? maxElo;
  final double depositAmount;
  final double? hostDepositAmount;
  final LobbyStatus status;
  final double? latitude;
  final double? longitude;
  final DateTime? confirmedAt;
  final DateTime? finishedAt;
  final DateTime? settledAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LobbyEntity({
    required this.id,
    required this.hostId,
    this.hostName,
    this.fieldId,
    required this.title,
    required this.sport,
    this.description = '',
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.minPlayers = 2,
    this.maxPlayers = 10,
    this.currentPlayers = 0,
    this.minElo,
    this.maxElo,
    this.depositAmount = 0,
    this.hostDepositAmount,
    this.status = LobbyStatus.open,
    this.latitude,
    this.longitude,
    this.confirmedAt,
    this.finishedAt,
    this.settledAt,
    this.cancelledAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isFull => currentPlayers >= maxPlayers;
  bool get hasMinPlayers => currentPlayers >= minPlayers;
  int get slotsAvailable => maxPlayers - currentPlayers;
  bool get isOpen => status == LobbyStatus.open;
  bool get hasDeposit => depositAmount > 0;

  LobbyEntity copyWith({
    String? id,
    String? hostId,
    String? hostName,
    String? fieldId,
    String? title,
    SportType? sport,
    String? description,
    DateTime? scheduledAt,
    int? durationMinutes,
    int? minPlayers,
    int? maxPlayers,
    int? currentPlayers,
    int? minElo,
    int? maxElo,
    double? depositAmount,
    double? hostDepositAmount,
    LobbyStatus? status,
    double? latitude,
    double? longitude,
    DateTime? confirmedAt,
    DateTime? finishedAt,
    DateTime? settledAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LobbyEntity(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      fieldId: fieldId ?? this.fieldId,
      title: title ?? this.title,
      sport: sport ?? this.sport,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      minElo: minElo ?? this.minElo,
      maxElo: maxElo ?? this.maxElo,
      depositAmount: depositAmount ?? this.depositAmount,
      hostDepositAmount: hostDepositAmount ?? this.hostDepositAmount,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      settledAt: settledAt ?? this.settledAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LobbyEntity.fromMap(Map<String, dynamic> map) {
    return LobbyEntity(
      id: map['id'] as String,
      hostId: map['host_id'] as String,
      hostName: map['host_name'] as String? ??
          (map['host'] is Map
              ? (map['host'] as Map)['full_name'] as String?
              : null),
      fieldId: map['field_id'] as String?,
      title: map['title'] as String,
      sport: SportType.fromString(map['sport'] as String) ?? SportType.futsal,
      description: (map['description'] as String?) ?? '',
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      durationMinutes: (map['duration_minutes'] as int?) ?? 60,
      minPlayers: (map['min_players'] as int?) ?? 2,
      maxPlayers: (map['max_players'] as int?) ?? 10,
      currentPlayers: (map['current_players'] as int?) ?? 0,
      minElo: map['min_elo'] as int?,
      maxElo: map['max_elo'] as int?,
      depositAmount: (map['deposit_amount'] as num?)?.toDouble() ?? 0,
      hostDepositAmount: (map['host_deposit_amount'] as num?)?.toDouble(),
      status: LobbyStatus.fromString(map['status'] as String? ?? 'open') ??
          LobbyStatus.open,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'] as String)
          : null,
      finishedAt: map['finished_at'] != null
          ? DateTime.parse(map['finished_at'] as String)
          : null,
      settledAt: map['settled_at'] != null
          ? DateTime.parse(map['settled_at'] as String)
          : null,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'host_id': hostId,
      'field_id': fieldId,
      'title': title,
      'sport': sport.name,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'deposit_amount': depositAmount,
      'host_deposit_amount': hostDepositAmount,
      'min_elo': minElo,
      'max_elo': maxElo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [
        id,
        hostId,
        hostName,
        fieldId,
        title,
        sport,
        description,
        scheduledAt,
        durationMinutes,
        minPlayers,
        maxPlayers,
        currentPlayers,
        minElo,
        maxElo,
        depositAmount,
        hostDepositAmount,
        status,
        latitude,
        longitude,
        confirmedAt,
        finishedAt,
        settledAt,
        cancelledAt,
        createdAt,
        updatedAt,
      ];
}
