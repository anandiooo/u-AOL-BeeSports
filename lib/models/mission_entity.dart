import 'package:equatable/equatable.dart';

class MissionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // play_matches, win_matches, join_lobbies, etc.
  final int targetCount;
  final int currentProgress;
  final int xpReward;
  final bool isCompleted;
  final bool isRewardClaimed;
  final DateTime startsAt;
  final DateTime expiresAt;

  const MissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    this.currentProgress = 0,
    this.xpReward = 50,
    this.isCompleted = false,
    this.isRewardClaimed = false,
    required this.startsAt,
    required this.expiresAt,
  });

  double get progressPercent =>
      targetCount > 0 ? (currentProgress / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired && !isCompleted;

  factory MissionEntity.fromMap(Map<String, dynamic> map) {
    return MissionEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'play_matches',
      targetCount: (map['target_count'] as int?) ?? 1,
      currentProgress: (map['current_progress'] as int?) ?? 0,
      xpReward: (map['xp_reward'] as int?) ?? 50,
      isCompleted: (map['is_completed'] as bool?) ?? false,
      isRewardClaimed: (map['is_reward_claimed'] as bool?) ?? false,
      startsAt: DateTime.parse(map['starts_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetCount,
        currentProgress,
        xpReward,
        isCompleted,
        isRewardClaimed,
        startsAt,
        expiresAt,
      ];
}
