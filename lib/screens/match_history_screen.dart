import 'package:beesports/app/app_theme.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Match History',
            style: AppTextStyles.sectionTitle),
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
                  style: AppTextStyles.error));
        }
        if (state is MatchHistoryLoaded) {
          if (state.matches.isEmpty) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_outlined,
                        size: 64, color: AppColors.divider),
                    const SizedBox(height: DesignConfig.spacingMd),
                    Text('No matches played yet',
                        style:
                            AppTextStyles.bodySecondary),
                  ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
                DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
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
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: Row(children: [
        Icon(match.sport.icon, color: AppColors.neonGreen, size: 28),
        const SizedBox(width: DesignConfig.spacingLg),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(match.sport.label,
                style: AppTextStyles.accentBody),
            const SizedBox(height: DesignConfig.spacingXs),
            Text(dateStr,
                style: AppTextStyles.caption),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${match.teamAScore} - ${match.teamBScore}',
              style: AppTextStyles.emptyTitle.copyWith(color: AppColors.neonGreen)),
          const SizedBox(height: DesignConfig.spacingXs),
          Text(match.resultLabel,
              style: AppTextStyles.chatTimestamp),
        ]),
      ]),
    );
  }
}

