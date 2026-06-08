import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final String tier; // bronze, silver, gold, platinum
  final int xpReward;
  final int? requiredCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;

  const AchievementEntity({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    this.icon = 'trophy',
    this.tier = 'bronze',
    this.xpReward = 100,
    this.requiredCount,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
  });

  double get progressPercent =>
      requiredCount != null && requiredCount! > 0
          ? (progress / requiredCount!).clamp(0.0, 1.0)
          : (isUnlocked ? 1.0 : 0.0);

  factory AchievementEntity.fromMap(Map<String, dynamic> map) {
    return AchievementEntity(
      id: map['id'] as String,
      key: map['key'] as String? ?? '',
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? 'trophy',
      tier: map['tier'] as String? ?? 'bronze',
      xpReward: (map['xp_reward'] as int?) ?? 100,
      requiredCount: map['required_count'] as int?,
      isUnlocked: (map['is_unlocked'] as bool?) ?? false,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      progress: (map['progress'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        key,
        title,
        description,
        icon,
        tier,
        xpReward,
        requiredCount,
        isUnlocked,
        unlockedAt,
        progress,
      ];
}
