import 'package:beesports/models/match_entity.dart';
import 'package:beesports/models/match_participant_entity.dart';
import 'package:beesports/repos/match_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MatchEvent {}

class SubmitMatchResult extends MatchEvent {
  final String lobbyId;
  final int teamAScore;
  final int teamBScore;
  SubmitMatchResult(this.lobbyId, this.teamAScore, this.teamBScore);
}

class LoadMatchDetail extends MatchEvent {
  final String lobbyId;
  LoadMatchDetail(this.lobbyId);
}

class LoadMatchHistory extends MatchEvent {
  final String userId;
  LoadMatchHistory(this.userId);
}

abstract class MatchState {}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchDetailLoaded extends MatchState {
  final MatchEntity match;
  final List<MatchParticipantEntity> participants;
  MatchDetailLoaded(this.match, this.participants);
}

class MatchHistoryLoaded extends MatchState {
  final List<MatchEntity> matches;
  MatchHistoryLoaded(this.matches);
}

class MatchSubmitted extends MatchState {
  final MatchEntity match;
  MatchSubmitted(this.match);
}

class MatchError extends MatchState {
  final String message;
  MatchError(this.message);
}

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository _repository;

  MatchBloc(this._repository) : super(MatchInitial()) {
    on<SubmitMatchResult>(_onSubmit);
    on<LoadMatchDetail>(_onLoadDetail);
    on<LoadMatchHistory>(_onLoadHistory);
  }

  Future<void> _onSubmit(
    SubmitMatchResult event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await _repository.submitResult(
      lobbyId: event.lobbyId,
      teamAScore: event.teamAScore,
      teamBScore: event.teamBScore,
    );
    result.when(
      success: (match) {
        emit(MatchSubmitted(match));
      },
      failure: (f) {
        emit(MatchError(f.message));
      },
    );
  }

  Future<void> _onLoadDetail(
    LoadMatchDetail event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final matchResult = await _repository.getMatchByLobby(event.lobbyId);

    await matchResult.when(
      success: (match) async {
        if (match == null) {
          emit(MatchError('No match found for this lobby'));
          return;
        }
        final participantsResult =
            await _repository.getMatchParticipants(match.id);
        participantsResult.when(
          success: (participants) {
            emit(MatchDetailLoaded(match, participants));
          },
          failure: (f) {
            emit(MatchError(f.message));
          },
        );
      },
      failure: (f) async {
        emit(MatchError(f.message));
      },
    );
  }

  Future<void> _onLoadHistory(
    LoadMatchHistory event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await _repository.getMyMatches(event.userId);
    result.when(
      success: (matches) {
        emit(MatchHistoryLoaded(matches));
      },
      failure: (f) {
        emit(MatchError(f.message));
      },
    );
  }
}
