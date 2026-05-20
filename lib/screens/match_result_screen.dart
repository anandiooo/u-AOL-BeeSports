import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Match result submitted! Elo updated.'),
              backgroundColor: AppColors.secondary));
          context.pop();
        } else if (state is MatchError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.tersierDark));
        }
      },
      builder: (context, state) {
        final isLoading = state is MatchLoading;
        return Scaffold(
          backgroundColor: AppColors.foursier,
          appBar: AppBar(
            title: Text('Submit Match Result',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, color: AppColors.primary)),
            backgroundColor: AppColors.foursier,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 24),
              Text('ENTER FINAL SCORE',
                  style: GoogleFonts.bebasNeue(
                      fontSize: 36, color: AppColors.primary)),
              const SizedBox(height: 32),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TeamScoreColumn(
                        label: 'Team A',
                        score: _teamAScore,
                        onIncrement: () => setState(() => _teamAScore++),
                        onDecrement: () => setState(() {
                              if (_teamAScore > 0) _teamAScore--;
                            })),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: AppColors.secondaryLight,
                      child: Text('VS',
                          style: GoogleFonts.bebasNeue(
                              fontSize: 24, color: AppColors.primaryLight)),
                    ),
                    _TeamScoreColumn(
                        label: 'Team B',
                        score: _teamBScore,
                        onIncrement: () => setState(() => _teamBScore++),
                        onDecrement: () => setState(() {
                              if (_teamBScore > 0) _teamBScore--;
                            })),
                  ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.secondaryLight,
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Submitting will update Elo ratings for all participants and mark the lobby as finished.',
                        style: GoogleFonts.inter(
                            color: AppColors.primaryLight, fontSize: 13)),
                  ),
                ]),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => context.read<MatchBloc>().add(SubmitMatchResult(
                            widget.lobbyId, _teamAScore, _teamBScore)),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.foursierLight))
                      : const Text('Submit Result'),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _TeamScoreColumn extends StatelessWidget {
  final String label;
  final int score;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _TeamScoreColumn(
      {required this.label,
      required this.score,
      required this.onIncrement,
      required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.secondaryLight,
        child: Column(children: [
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.add,
                  color: AppColors.foursierLight, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          Text('$score',
              style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: score > 0 ? AppColors.primary : AppColors.tersierLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove,
                  color: score > 0 ? AppColors.foursierLight : AppColors.primaryLight,
                  size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }
}
