import 'dart:async'; // For Timer

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
  final String? searchQuery;
  const LoadLobbies({this.sport, this.sortBy, this.searchQuery});
  @override
  List<Object?> get props => [sport, sortBy, searchQuery];
}

class SearchLobbies extends LobbyListEvent {
  final String query;
  final SportType? sport;
  final String? sortBy;
  const SearchLobbies(this.query, {this.sport, this.sortBy});
  @override
  List<Object?> get props => [query, sport, sortBy];
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
  final String? activeSearch;
  const LobbyListLoaded(this.lobbies,
      {this.activeSportFilter, this.activeSort, this.activeSearch});
  @override
  List<Object?> get props =>
      [lobbies, activeSportFilter, activeSort, activeSearch];
}

class LobbyListError extends LobbyListState {
  final String message;
  const LobbyListError(this.message);
  @override
  List<Object?> get props => [message];
}

class LobbyListBloc extends Bloc<LobbyListEvent, LobbyListState> {
  final LobbyRepository _lobbyRepository;
  Timer? _debounceTimer;

  LobbyListBloc(this._lobbyRepository) : super(LobbyListInitial()) {
    on<LoadLobbies>(_onLoadLobbies);
    on<LoadMyLobbies>(_onLoadMyLobbies);
    on<SearchLobbies>(_onSearchLobbies);
  }

  Future<void> _onLoadLobbies(
    LoadLobbies event,
    Emitter<LobbyListState> emit,
  ) async {
    emit(LobbyListLoading());
    final result = await _lobbyRepository.getLobbies(
      sport: event.sport,
      sortBy: event.sortBy,
      searchQuery: event.searchQuery,
    );
    result.when(
      success: (lobbies) {
        emit(LobbyListLoaded(
          lobbies,
          activeSportFilter: event.sport,
          activeSort: event.sortBy,
          activeSearch: event.searchQuery,
        ));
      },
      failure: (f) {
        emit(LobbyListError(f.message));
      },
    );
  }

  void _onSearchLobbies(
    SearchLobbies event,
    Emitter<LobbyListState> emit,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(LoadLobbies(
        sport: event.sport,
        sortBy: event.sortBy,
        searchQuery: event.query,
      ));
    });
  }

  Future<void> _onLoadMyLobbies(
    LoadMyLobbies event,
    Emitter<LobbyListState> emit,
  ) async {
    emit(LobbyListLoading());
    final result = await _lobbyRepository.getMyLobbies(event.userId);
    result.when(
      success: (lobbies) {
        emit(LobbyListLoaded(lobbies));
      },
      failure: (f) {
        emit(LobbyListError(f.message));
      },
    );
  }
}
