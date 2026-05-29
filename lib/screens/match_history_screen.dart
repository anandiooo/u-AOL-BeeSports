import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/match_entity.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<MatchBloc>().add(LoadMatchHistory(authState.user.id));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Match History',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: BlocBuilder<MatchBloc, MatchState>(builder: (context, state) {
        if (state is MatchLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen));
        }
        if (state is MatchError) {
          return Center(
              child: Text(state.message,
                  style: GoogleFonts.inter(color: AppColors.error)));
        }
        if (state is MatchHistoryLoaded) {
          if (state.matches.isEmpty) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_outlined,
                        size: 64, color: AppColors.divider),
                    const SizedBox(height: 12),
                    Text('No matches played yet',
                        style:
                            GoogleFonts.inter(color: AppColors.textSecondary)),
                  ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: state.matches.length,
            itemBuilder: (context, index) =>
                _MatchCard(match: state.matches[index]),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchEntity match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final d = match.playedAt;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateStr =
        '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceVariant,
      child: Row(children: [
        Icon(match.sport.icon, color: AppColors.neonGreen, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(match.sport.label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.neonGreen)),
            const SizedBox(height: 4),
            Text(dateStr,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${match.teamAScore} - ${match.teamBScore}',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neonGreen)),
          const SizedBox(height: 4),
          Text(match.resultLabel,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}
