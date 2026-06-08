import 'package:beesports/app/app_theme.dart';
import 'package:beesports/models/mission_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  List<MissionEntity> get _sampleMissions {
    final now = DateTime.now();
    final weekEnd = now.add(Duration(days: 7 - now.weekday));
    return [
      MissionEntity(
          id: '1',
          title: 'Play 3 Matches',
          description: 'Join and complete 3 matches this week',
          type: 'play_matches',
          targetCount: 3,
          currentProgress: 0,
          xpReward: 150,
          startsAt: now,
          expiresAt: weekEnd),
      MissionEntity(
          id: '2',
          title: 'Win a Match',
          description: 'Win at least 1 match this week',
          type: 'win_matches',
          targetCount: 1,
          currentProgress: 0,
          xpReward: 100,
          startsAt: now,
          expiresAt: weekEnd),
      MissionEntity(
          id: '3',
          title: 'Host a Lobby',
          description: 'Create and host a lobby this week',
          type: 'host_lobbies',
          targetCount: 1,
          currentProgress: 0,
          xpReward: 75,
          startsAt: now,
          expiresAt: weekEnd),
      MissionEntity(
          id: '4',
          title: 'Try 2 Sports',
          description: 'Play matches in 2 different sports',
          type: 'variety',
          targetCount: 2,
          currentProgress: 0,
          xpReward: 200,
          startsAt: now,
          expiresAt: weekEnd),
      MissionEntity(
          id: '5',
          title: 'Perfect Attendance',
          description: 'Confirm attendance for all your matches',
          type: 'attend',
          targetCount: 3,
          currentProgress: 0,
          xpReward: 125,
          startsAt: now,
          expiresAt: weekEnd),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final missions = _sampleMissions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Weekly Missions',
            style: AppTextStyles.displayOutfit(
                typography: DesignConfig.displayXs,
                color: AppColors.neonGreen,
                fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
            DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
        child: Column(
          children: [
            // Weekly progress header
            Container(
              margin: const EdgeInsets.only(bottom: DesignConfig.spacingLg),
              padding: const EdgeInsets.all(DesignConfig.spacingXl),
              color: AppColors.neonGreen,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('This Week',
                            style: AppTextStyles.displayOutfit(
                                typography: DesignConfig.displaySm,
                                color: AppColors.onAccent,
                                height: 1)),
                        const SizedBox(height: DesignConfig.spacingXs),
                        Text('0 / ${missions.length} missions completed',
                            style: AppTextStyles.displayOutfit(
                                typography: DesignConfig.bodyXs,
                                color:
                                    AppColors.onAccent.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignConfig.spacingLg,
                        vertical: DesignConfig.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.onAccent.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(DesignConfig.rounded2xl),
                    ),
                    child: Text(
                      '+${missions.fold<int>(0, (sum, m) => sum + m.xpReward)} XP',
                      style: AppTextStyles.displayOutfit(
                          typography: DesignConfig.bodyXs,
                          color: AppColors.onAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            // Missions list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final m = missions[index];
                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: DesignConfig.spacingSm),
                    padding: const EdgeInsets.all(DesignConfig.spacingLg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(DesignConfig.roundedXl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(m.title,
                                  style: AppTextStyles.displayOutfit(
                                      typography: DesignConfig.bodyXs,
                                      color: AppColors.neonGreen,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: DesignConfig.spacingMd,
                                  vertical: DesignConfig.spacingXs),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.neonGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    DesignConfig.rounded2xl),
                              ),
                              child: Text(
                                '+${m.xpReward} XP',
                                style: AppTextStyles.displayOutfit(
                                    typography: DesignConfig.bodyXs,
                                    color: AppColors.neonGreen,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignConfig.spacingXs),
                        Text(m.description,
                            style: AppTextStyles.displayOutfit(
                                typography: DesignConfig.bodyXs,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: DesignConfig.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    DesignConfig.roundedXs),
                                child: LinearProgressIndicator(
                                  value: m.progressPercent,
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.neonGreen),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: DesignConfig.spacingMd),
                            Text(
                              '${m.currentProgress}/${m.targetCount}',
                              style: AppTextStyles.displayOutfit(
                                  typography: DesignConfig.bodyXs,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 + index * 60),
                      duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
