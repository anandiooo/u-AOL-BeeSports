import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LobbyListEvent extends Equatable {
  const LobbyListEvent();
  @override
  List<Object?> get props => [];
}

class LoadLobbies extends LobbyListEvent {
  final SportType? sport;
  final String? sortBy;
  const LoadLobbies({this.sport, this.sortBy});
  @override
  List<Object?> get props => [sport, sortBy];
}

class LoadMyLobbies extends LobbyListEvent {
  final String userId;
  const LoadMyLobbies(this.userId);
  @override
  List<Object?> get props => [userId];
}

abstract class LobbyListState extends Equatable {
  const LobbyListState();
  @override
  List<Object?> get props => [];
}

class LobbyListInitial extends LobbyListState {}

class LobbyListLoading extends LobbyListState {}

class LobbyListLoaded extends LobbyListState {
  final List<LobbyEntity> lobbies;
  final SportType? activeSportFilter;
  final String? activeSort;
  const LobbyListLoaded(this.lobbies,
      {this.activeSportFilter, this.activeSort});
  @override
  List<Object?> get props => [lobbies, activeSportFilter, activeSort];
}

class LobbyListError extends LobbyListState {
  final String message;
  const LobbyListError(this.message);
  @override
  List<Object?> get props => [message];
}

class LobbyListBloc extends Bloc<LobbyListEvent, LobbyListState> {
  final LobbyRepository _lobbyRepository;

  LobbyListBloc(this._lobbyRepository) : super(LobbyListInitial()) {
    on<LoadLobbies>(_onLoadLobbies);
    on<LoadMyLobbies>(_onLoadMyLobbies);
  }

  Future<void> _onLoadLobbies(
    LoadLobbies event,
    Emitter<LobbyListState> emit,
  ) async {
    emit(LobbyListLoading());
    try {
      final lobbies = await _lobbyRepository.getLobbies(
        sport: event.sport,
        sortBy: event.sortBy,
      );
      emit(LobbyListLoaded(
        lobbies,
        activeSportFilter: event.sport,
        activeSort: event.sortBy,
      ));
    } catch (e) {
      emit(LobbyListError(e.toString()));
    }
  }

  Future<void> _onLoadMyLobbies(
    LoadMyLobbies event,
    Emitter<LobbyListState> emit,
  ) async {
    emit(LobbyListLoading());
    try {
      final lobbies = await _lobbyRepository.getMyLobbies(event.userId);
      emit(LobbyListLoaded(lobbies));
    } catch (e) {
      emit(LobbyListError(e.toString()));
    }
  }
}
