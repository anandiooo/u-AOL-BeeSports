import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateLobbyEvent extends Equatable {
  const CreateLobbyEvent();
  @override
  List<Object?> get props => [];
}

class SubmitLobby extends CreateLobbyEvent {
  final String hostId;
  final String title;
  final SportType sport;
  final String description;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int minPlayers;
  final int maxPlayers;
  final double depositAmount;
  final int? minElo;
  final int? maxElo;

  const SubmitLobby({
    required this.hostId,
    required this.title,
    required this.sport,
    this.description = '',
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.minPlayers = 2,
    this.maxPlayers = 10,
    this.depositAmount = 0,
    this.minElo,
    this.maxElo,
  });

  @override
  List<Object?> get props => [
        hostId,
        title,
        sport,
        description,
        scheduledAt,
        durationMinutes,
        minPlayers,
        maxPlayers,
        depositAmount,
        minElo,
        maxElo,
      ];
}

abstract class CreateLobbyState extends Equatable {
  const CreateLobbyState();
  @override
  List<Object?> get props => [];
}

class CreateLobbyInitial extends CreateLobbyState {}

class CreateLobbyLoading extends CreateLobbyState {}

class CreateLobbySuccess extends CreateLobbyState {
  final LobbyEntity lobby;
  const CreateLobbySuccess(this.lobby);
  @override
  List<Object?> get props => [lobby];
}

class CreateLobbyError extends CreateLobbyState {
  final String message;
  const CreateLobbyError(this.message);
  @override
  List<Object?> get props => [message];
}

class CreateLobbyBloc extends Bloc<CreateLobbyEvent, CreateLobbyState> {
  final LobbyRepository _lobbyRepository;

  CreateLobbyBloc(this._lobbyRepository) : super(CreateLobbyInitial()) {
    on<SubmitLobby>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitLobby event,
    Emitter<CreateLobbyState> emit,
  ) async {
    emit(CreateLobbyLoading());
    final lobby = LobbyEntity(
      id: '',
      hostId: event.hostId,
      title: event.title,
      sport: event.sport,
      description: event.description,
      scheduledAt: event.scheduledAt,
      durationMinutes: event.durationMinutes,
      minPlayers: event.minPlayers,
      maxPlayers: event.maxPlayers,
      depositAmount: event.depositAmount,
      minElo: event.minElo,
      maxElo: event.maxElo,
      createdAt: DateTime.now(),
    );

    final result = await _lobbyRepository.createLobby(lobby);
    result.when(
      success: (created) {
        emit(CreateLobbySuccess(created));
      },
      failure: (f) {
        emit(CreateLobbyError(f.message));
      },
    );
  }
}
