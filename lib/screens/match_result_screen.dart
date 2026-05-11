import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MatchResultScreen extends StatefulWidget {
  final String lobbyId;
  const MatchResultScreen({super.key, required this.lobbyId});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  int _teamAScore = 0;
  int _teamBScore = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state is MatchSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match result submitted! Elo updated.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is MatchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is MatchLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Submit Match Result')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Enter Final Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TeamScoreColumn(
                      label: 'Team A',
                      color: AppColors.primary,
                      score: _teamAScore,
                      onIncrement: () => setState(() => _teamAScore++),
                      onDecrement: () => setState(() {
                        if (_teamAScore > 0) _teamAScore--;
                      }),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                    _TeamScoreColumn(
                      label: 'Team B',
                      color: AppColors.accent,
                      score: _teamBScore,
                      onIncrement: () => setState(() => _teamBScore++),
                      onDecrement: () => setState(() {
                        if (_teamBScore > 0) _teamBScore--;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Submitting will update Elo ratings for all participants and mark the lobby as finished.',
                          style: TextStyle(
                            color: AppColors.warning.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<MatchBloc>().add(
                                  SubmitMatchResult(
                                    widget.lobbyId,
                                    _teamAScore,
                                    _teamBScore,
                                  ),
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Result'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TeamScoreColumn extends StatelessWidget {
  final String label;
  final Color color;
  final int score;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TeamScoreColumn({
    required this.label,
    required this.color,
    required this.score,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle, color: color, size: 36),
                onPressed: onIncrement,
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle, color: color, size: 36),
                onPressed: onDecrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
