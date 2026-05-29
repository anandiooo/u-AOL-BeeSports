import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/blocs/leaderboard_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<LeaderboardBloc>().add(LoadLeaderboard(SportType.futsal));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leaderboard',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          final selectedSport = state is LeaderboardLoaded
              ? state.selectedSport
              : SportType.futsal;
          return Column(children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: SportType.values.map((sport) {
                  final sel = sport == selectedSport;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => context
                          .read<LeaderboardBloc>()
                          .add(ChangeSport(sport)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              sel ? AppColors.neonGreen : AppColors.background,
                          borderRadius: BorderRadius.circular(30),
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
                          const SizedBox(width: 6),
                          Text(sport.label,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? AppColors.onAccent
                                      : AppColors.neonGreen)),
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
    );
  }

  Widget _buildBody(BuildContext context, LeaderboardState state) {
    if (state is LeaderboardLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen));
    }
    if (state is LeaderboardError) {
      return Center(
          child: Text(state.message,
              style: GoogleFonts.inter(color: AppColors.error)));
    }
    if (state is LeaderboardLoaded) {
      if (state.entries.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.leaderboard_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 12),
            Text('No rankings yet for ${state.selectedSport.label}',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
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
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onAccent)),
                  ),
                )
              : Center(
                  child: Text('#$rank',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.fullName ?? 'Unknown',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
            const SizedBox(height: 2),
            Text(
                '${entry.campus ?? ""} · ${entry.matchesPlayed} matches · ${entry.winRate.toStringAsFixed(0)}% WR',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${entry.eloRating}',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neonGreen)),
          Text('ELO',
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}
