import 'package:beesports/app/app_theme.dart';
import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/blocs/leaderboard_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<LeaderboardBloc>().add(LoadLeaderboard(SportType.futsal));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: DesignConfig.spacingLg),
                child: Text('Leaderboard', style: AppTextStyles.sectionTitle),
              ),
              Expanded(
                child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                  builder: (context, state) {
                    final selectedSport = state is LeaderboardLoaded
                        ? state.selectedSport
                        : SportType.futsal;
                    return Column(children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: DesignConfig.spacingMd),
                        child: Row(
                          children: SportType.values.map((sport) {
                            final sel = sport == selectedSport;
                            return Padding(
                              padding: const EdgeInsets.only(right: DesignConfig.spacingSm),
                              child: GestureDetector(
                                onTap: () => context
                                    .read<LeaderboardBloc>()
                                    .add(ChangeSport(sport)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: DesignConfig.spacingLg, vertical: DesignConfig.spacingMd),
                                  decoration: BoxDecoration(
                                    color:
                                        sel ? AppColors.neonGreen : AppColors.background,
                                    borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
                                    border: Border.all(
                                        color:
                                            sel ? AppColors.neonGreen : AppColors.border),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(sport.icon,
                                        size: 16,
                                        color: sel
                                            ? AppColors.onAccent
                                            : AppColors.neonGreen),
                                    const SizedBox(width: DesignConfig.spacingSm),
                                    Text(sport.label,
                                        style: AppTextStyles.selectionLabel(selected: sel)),
                                  ]),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(child: _buildBody(context, state)),
                    ]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LeaderboardState state) {
    if (state is LeaderboardLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonGreen),
      );
    }
    if (state is LeaderboardError) {
      return Center(
        child: Text(state.message,
            style: AppTextStyles.error),
      );
    }
    if (state is LeaderboardLoaded) {
      if (state.entries.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.leaderboard_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: DesignConfig.spacingMd),
            Text('No rankings yet for ${state.selectedSport.label}',
                style: AppTextStyles.bodySecondary),
          ]),
        );
      }
      return RefreshIndicator(
        color: AppColors.neonGreen,
        backgroundColor: AppColors.background,
        onRefresh: () async => context
            .read<LeaderboardBloc>()
            .add(LoadLeaderboard(state.selectedSport)),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: state.entries.length,
          itemBuilder: (context, index) =>
              _LeaderboardTile(entry: state.entries[index], rank: index + 1),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final int rank;
  const _LeaderboardTile({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingXs),
      padding: const EdgeInsets.symmetric(vertical: DesignConfig.spacingLg, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(children: [
        SizedBox(
          width: 40,
          child: isTop3
              ? Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: AppColors.neonGreen, shape: BoxShape.circle),
                  child: Center(
                    child: Text('#$rank',
                        style: AppTextStyles.onAccentBody),
                  ),
                )
              : Center(
                  child: Text('#$rank',
                      style: AppTextStyles.bodySecondaryStrong),
                ),
        ),
        const SizedBox(width: DesignConfig.spacingMd),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.fullName ?? '[N/A]',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: DesignConfig.spacingXxs),
            Text(
                '${entry.campus ?? ""} · ${entry.matchesPlayed} matches · ${entry.winRate.toStringAsFixed(0)}% WR',
                style: AppTextStyles.caption),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${entry.eloRating}',
              style: AppTextStyles.emptyTitle.copyWith(color: AppColors.neonGreen)),
          Text('ELO',
              style: AppTextStyles.chatMeta),
        ]),
      ]),
    );
  }
}

