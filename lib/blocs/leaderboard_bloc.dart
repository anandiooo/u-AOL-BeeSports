import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/repos/leaderboard_repository.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {
  final SportType sport;
  final String? campus;
  LoadLeaderboard(this.sport, {this.campus});
}

class ChangeSport extends LeaderboardEvent {
  final SportType sport;
  ChangeSport(this.sport);
}

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntryEntity> entries;
  final SportType selectedSport;
  final String? campus;
  LeaderboardLoaded(this.entries, this.selectedSport, {this.campus});
}

class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _repository;

  LeaderboardBloc(this._repository) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoad);
    on<ChangeSport>(_onChangeSport);
  }

  Future<void> _onLoad(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final entries = await _repository.getLeaderboard(
        event.sport,
        campus: event.campus,
      );
      emit(LeaderboardLoaded(entries, event.sport, campus: event.campus));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onChangeSport(
    ChangeSport event,
    Emitter<LeaderboardState> emit,
  ) async {
    final currentCampus =
        state is LeaderboardLoaded ? (state as LeaderboardLoaded).campus : null;
    add(LoadLeaderboard(event.sport, campus: currentCampus));
  }
}
