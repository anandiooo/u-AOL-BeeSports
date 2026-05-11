import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/match_entity.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<MatchBloc>().add(LoadMatchHistory(authState.user.id));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.error)),
            );
          }

          if (state is MatchHistoryLoaded) {
            if (state.matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No matches played yet',
                      style: TextStyle(
                        color:
                            AppColors.textSecondaryDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.matches.length,
              itemBuilder: (context, index) =>
                  _MatchCard(match: state.matches[index]),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchEntity match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final d = match.playedAt;
    final months = [
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

    Color resultColor;
    IconData resultIcon;
    if (match.teamAScore > match.teamBScore) {
      resultColor = AppColors.primary;
      resultIcon = Icons.emoji_events;
    } else if (match.teamBScore > match.teamAScore) {
      resultColor = AppColors.accent;
      resultIcon = Icons.emoji_events;
    } else {
      resultColor = AppColors.warning;
      resultIcon = Icons.handshake;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: match.sport.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(match.sport.icon, color: match.sport.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.sport.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(resultIcon, color: resultColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${match.teamAScore} - ${match.teamBScore}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  match.resultLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: resultColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
