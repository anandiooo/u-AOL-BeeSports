import 'package:beesports/app/app_colors.dart';
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
      appBar: AppBar(title: const Text('Leaderboard')),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          final selectedSport = state is LeaderboardLoaded
              ? state.selectedSport
              : SportType.futsal;

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: SportType.values.map((sport) {
                    final isSelected = sport == selectedSport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sport.icon,
                                size: 16,
                                color: isSelected ? Colors.black : sport.color),
                            const SizedBox(width: 6),
                            Text(sport.label),
                          ],
                        ),
                        selectedColor: sport.color,
                        checkmarkColor: Colors.black,
                        onSelected: (_) => context
                            .read<LeaderboardBloc>()
                            .add(ChangeSport(sport)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LeaderboardState state) {
    if (state is LeaderboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LeaderboardError) {
      return Center(
        child:
            Text(state.message, style: const TextStyle(color: AppColors.error)),
      );
    }

    if (state is LeaderboardLoaded) {
      final selectedSport = state.selectedSport;
      if (state.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.leaderboard_outlined,
                  size: 64, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 12),
              Text(
                'No rankings yet for ${state.selectedSport.label}',
                style: TextStyle(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardDark,
        onRefresh: () async {
          context.read<LeaderboardBloc>().add(LoadLeaderboard(selectedSport));
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.entries.length,
          itemBuilder: (context, index) {
            final entry = state.entries[index];
            return _LeaderboardTile(entry: entry, rank: index + 1);
          },
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
    Color? rankColor;
    IconData? trophyIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      trophyIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      trophyIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      trophyIcon = Icons.emoji_events;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: rank <= 3 ? rankColor?.withValues(alpha: 0.08) : null,
      child: ListTile(
        leading: rank <= 3
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor?.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(trophyIcon, color: rankColor, size: 22),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
        title: Text(
          entry.fullName ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${entry.campus ?? ""} • ${entry.matchesPlayed} matches • ${entry.winRate.toStringAsFixed(0)}% WR',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.eloRating}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: rankColor ?? AppColors.primary,
              ),
            ),
            Text(
              'ELO',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
