import 'package:beesports/app/app_theme.dart';
import 'package:beesports/models/achievement_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  // Hardcoded achievement definitions for display. In production, these would
  // come from the database via a bloc.
  List<AchievementEntity> get _achievements => const [
        AchievementEntity(
            id: '1',
            key: 'first_match',
            title: 'First Match',
            description: 'Play your first match',
            icon: 'first_match',
            tier: 'bronze',
            xpReward: 100,
            requiredCount: 1),
        AchievementEntity(
            id: '2',
            key: 'match_5',
            title: 'Regular Player',
            description: 'Play 5 matches',
            icon: 'match_5',
            tier: 'bronze',
            xpReward: 200,
            requiredCount: 5),
        AchievementEntity(
            id: '3',
            key: 'match_25',
            title: 'Seasoned Athlete',
            description: 'Play 25 matches',
            icon: 'match_25',
            tier: 'silver',
            xpReward: 500,
            requiredCount: 25),
        AchievementEntity(
            id: '4',
            key: 'match_100',
            title: 'Century Club',
            description: 'Play 100 matches',
            icon: 'match_100',
            tier: 'gold',
            xpReward: 1000,
            requiredCount: 100),
        AchievementEntity(
            id: '5',
            key: 'win_first',
            title: 'First Victory',
            description: 'Win your first match',
            icon: 'win_first',
            tier: 'bronze',
            xpReward: 150,
            requiredCount: 1),
        AchievementEntity(
            id: '6',
            key: 'win_10',
            title: 'Winning Streak',
            description: 'Win 10 matches',
            icon: 'win_10',
            tier: 'silver',
            xpReward: 400,
            requiredCount: 10),
        AchievementEntity(
            id: '7',
            key: 'host_first',
            title: 'Host Debut',
            description: 'Host your first lobby',
            icon: 'host_first',
            tier: 'bronze',
            xpReward: 100,
            requiredCount: 1),
        AchievementEntity(
            id: '8',
            key: 'host_10',
            title: 'Community Builder',
            description: 'Host 10 lobbies',
            icon: 'host_10',
            tier: 'silver',
            xpReward: 300,
            requiredCount: 10),
        AchievementEntity(
            id: '9',
            key: 'reliable_100',
            title: 'Dependable',
            description: 'Maintain 100 reliability for 10 matches',
            icon: 'reliable_100',
            tier: 'gold',
            xpReward: 500,
            requiredCount: 10),
        AchievementEntity(
            id: '10',
            key: 'social_5',
            title: 'Socialite',
            description: 'Add 5 friends',
            icon: 'social_5',
            tier: 'bronze',
            xpReward: 150,
            requiredCount: 5),
        AchievementEntity(
            id: '11',
            key: 'multi_sport',
            title: 'All-Rounder',
            description: 'Play 3 different sports',
            icon: 'multi_sport',
            tier: 'silver',
            xpReward: 300,
            requiredCount: 3),
        AchievementEntity(
            id: '12',
            key: 'win_50',
            title: 'Champion',
            description: 'Win 50 matches',
            icon: 'win_50',
            tier: 'gold',
            xpReward: 800,
            requiredCount: 50),
      ];

  Color _tierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getIconData(String key) {
    switch (key) {
      case 'first_match':
        return Icons.sports_soccer;
      case 'match_5':
        return Icons.military_tech;
      case 'match_25':
        return Icons.workspace_premium;
      case 'match_100':
        return Icons.emoji_events;
      case 'win_first':
        return Icons.star;
      case 'win_10':
        return Icons.local_fire_department;
      case 'win_50':
        return Icons.workspace_premium;
      case 'host_first':
        return Icons.campaign;
      case 'host_10':
        return Icons.groups;
      case 'reliable_100':
        return Icons.verified;
      case 'social_5':
        return Icons.group_add;
      case 'multi_sport':
        return Icons.category;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Achievements',
            style: AppTextStyles.bangers(DesignConfig.displayXs, color: AppColors.neonGreen, fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
            DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final a = _achievements[index];
          return Container(
            margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
            padding: const EdgeInsets.all(DesignConfig.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _tierColor(a.tier).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
                  ),
                  child: Center(
                    child: Icon(_getIconData(a.key),
                        size: 24, color: _tierColor(a.tier)),
                  ),
                ),
                const SizedBox(width: DesignConfig.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(a.title,
                                style: AppTextStyles.bangers(DesignConfig.bodyXs, color: AppColors.neonGreen, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: DesignConfig.spacingSm, vertical: DesignConfig.spacingXs),
                            decoration: BoxDecoration(
                              color: _tierColor(a.tier).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
                            ),
                            child: Text(
                              a.tier.toUpperCase(),
                              style: AppTextStyles.bangers(
                                  DesignConfig.bodyXs,
                                  color: _tierColor(a.tier),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignConfig.spacingXs),
                      Text(a.description,
                          style: AppTextStyles.bangers(DesignConfig.bodyXs, color: AppColors.textSecondary)),
                      const SizedBox(height: DesignConfig.spacingSm),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(DesignConfig.roundedXs),
                              child: LinearProgressIndicator(
                                value: a.progressPercent,
                                backgroundColor: AppColors.divider,
                                valueColor:
                                    AlwaysStoppedAnimation(_tierColor(a.tier)),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignConfig.spacingMd),
                          Text(
                            '+${a.xpReward} XP',
                            style: AppTextStyles.bangers(DesignConfig.bodyXs, color: AppColors.neonGreen, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(
              delay: Duration(milliseconds: index * 50), duration: 300.ms);
        },
      ),
    );
  }
}


