import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LobbyDetailEvent extends Equatable {
  const LobbyDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadLobbyDetail extends LobbyDetailEvent {
  final String lobbyId;
  const LoadLobbyDetail(this.lobbyId);
  @override
  List<Object?> get props => [lobbyId];
}

class JoinLobbyRequested extends LobbyDetailEvent {
  final String lobbyId;
  final String userId;
  const JoinLobbyRequested({required this.lobbyId, required this.userId});
  @override
  List<Object?> get props => [lobbyId, userId];
}

class LeaveLobbyRequested extends LobbyDetailEvent {
  final String lobbyId;
  final String userId;
  const LeaveLobbyRequested({required this.lobbyId, required this.userId});
  @override
  List<Object?> get props => [lobbyId, userId];
}

class ConfirmLobbyRequested extends LobbyDetailEvent {
  final String lobbyId;
  const ConfirmLobbyRequested(this.lobbyId);
  @override
  List<Object?> get props => [lobbyId];
}

class CancelLobbyRequested extends LobbyDetailEvent {
  final String lobbyId;
  const CancelLobbyRequested(this.lobbyId);
  @override
  List<Object?> get props => [lobbyId];
}

abstract class LobbyDetailState extends Equatable {
  const LobbyDetailState();
  @override
  List<Object?> get props => [];
}

class LobbyDetailInitial extends LobbyDetailState {}

class LobbyDetailLoading extends LobbyDetailState {}

class LobbyDetailLoaded extends LobbyDetailState {
  final LobbyEntity lobby;
  final List<LobbyParticipantEntity> participants;
  const LobbyDetailLoaded({required this.lobby, required this.participants});
  @override
  List<Object?> get props => [lobby, participants];
}

class LobbyDetailError extends LobbyDetailState {
  final String message;
  const LobbyDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class LobbyActionSuccess extends LobbyDetailState {
  final String message;
  const LobbyActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class LobbyDetailBloc extends Bloc<LobbyDetailEvent, LobbyDetailState> {
  final LobbyRepository _lobbyRepository;

  LobbyDetailBloc(this._lobbyRepository) : super(LobbyDetailInitial()) {
    on<LoadLobbyDetail>(_onLoad);
    on<JoinLobbyRequested>(_onJoin);
    on<LeaveLobbyRequested>(_onLeave);
    on<ConfirmLobbyRequested>(_onConfirm);
    on<CancelLobbyRequested>(_onCancel);
  }

  Future<void> _onLoad(
    LoadLobbyDetail event,
    Emitter<LobbyDetailState> emit,
  ) async {
    emit(LobbyDetailLoading());
    try {
      final lobby = await _lobbyRepository.getLobbyById(event.lobbyId);
      if (lobby == null) {
        emit(const LobbyDetailError('Lobby not found.'));
        return;
      }
      final participants =
          await _lobbyRepository.getParticipants(event.lobbyId);
      emit(LobbyDetailLoaded(lobby: lobby, participants: participants));
    } catch (e) {
      emit(LobbyDetailError(e.toString()));
    }
  }

  Future<void> _onJoin(
    JoinLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    try {
      await _lobbyRepository.joinLobby(
        lobbyId: event.lobbyId,
        userId: event.userId,
      );
      emit(const LobbyActionSuccess('Successfully joined the lobby!'));
      add(LoadLobbyDetail(event.lobbyId));
    } catch (e, st) {
      debugPrint('LobbyDetailBloc._onJoin error: $e\n$st');
      emit(LobbyDetailError(_friendlyError(e)));
    }
  }

  Future<void> _onLeave(
    LeaveLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    try {
      await _lobbyRepository.leaveLobby(
        lobbyId: event.lobbyId,
        userId: event.userId,
      );
      emit(const LobbyActionSuccess('You have left the lobby.'));
      add(LoadLobbyDetail(event.lobbyId));
    } catch (e, st) {
      debugPrint('LobbyDetailBloc._onLeave error: $e\n$st');
      emit(LobbyDetailError(_friendlyError(e)));
    }
  }

  Future<void> _onConfirm(
    ConfirmLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    try {
      await _lobbyRepository.updateLobbyStatus(
        lobbyId: event.lobbyId,
        status: LobbyStatus.confirmed,
      );
      emit(const LobbyActionSuccess('Lobby confirmed!'));
      add(LoadLobbyDetail(event.lobbyId));
    } catch (e, st) {
      debugPrint('LobbyDetailBloc._onConfirm error: $e\n$st');
      emit(LobbyDetailError(_friendlyError(e)));
    }
  }

  Future<void> _onCancel(
    CancelLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    try {
      await _lobbyRepository.updateLobbyStatus(
        lobbyId: event.lobbyId,
        status: LobbyStatus.cancelled,
      );
      emit(const LobbyActionSuccess('Lobby cancelled.'));
      add(LoadLobbyDetail(event.lobbyId));
    } catch (e, st) {
      debugPrint('LobbyDetailBloc._onCancel error: $e\n$st');
      emit(LobbyDetailError(_friendlyError(e)));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Time conflict')) {
      return 'You already have a lobby during this time slot.';
    }
    if (msg.contains('duplicate key') || msg.contains('unique')) {
      return 'You have already joined this lobby.';
    }
    return 'Something went wrong. Please try again.';
  }
}
