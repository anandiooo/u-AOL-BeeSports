import 'dart:async';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/models/participant_status.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/repos/wallet_repository.dart';
import 'package:beesports/repos/match_repository.dart';
import 'package:beesports/app/di.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:equatable/equatable.dart';
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

class LobbyDetailUpdated extends LobbyDetailEvent {
  final LobbyEntity lobby;
  final List<LobbyParticipantEntity> participants;
  const LobbyDetailUpdated(this.lobby, this.participants);
  @override
  List<Object?> get props => [lobby, participants];
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

class SettleLobbyRequested extends LobbyDetailEvent {
  final String lobbyId;
  const SettleLobbyRequested(this.lobbyId);
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
  StreamSubscription<LobbyEntity?>? _lobbySubscription;
  StreamSubscription<List<LobbyParticipantEntity>>? _participantsSubscription;

  LobbyDetailBloc(this._lobbyRepository) : super(LobbyDetailInitial()) {
    on<LoadLobbyDetail>(_onLoad);
    on<LobbyDetailUpdated>(_onUpdate);
    on<JoinLobbyRequested>(_onJoin);
    on<LeaveLobbyRequested>(_onLeave);
    on<ConfirmLobbyRequested>(_onConfirm);
    on<CancelLobbyRequested>(_onCancel);
    on<SettleLobbyRequested>(_onSettle);
  }

  void _onUpdate(LobbyDetailUpdated event, Emitter<LobbyDetailState> emit) {
    emit(LobbyDetailLoaded(
        lobby: event.lobby, participants: event.participants));
  }

  @override
  Future<void> close() {
    _lobbySubscription?.cancel();
    _participantsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadLobbyDetail event,
    Emitter<LobbyDetailState> emit,
  ) async {
    emit(LobbyDetailLoading());
    final lobbyResult = await _lobbyRepository.getLobbyById(event.lobbyId);

    await lobbyResult.when(
      success: (lobby) async {
        if (lobby == null) {
          emit(const LobbyDetailError('Lobby not found.'));
          return;
        }
        final participantsResult =
            await _lobbyRepository.getParticipants(event.lobbyId);
        participantsResult.when(
          success: (participants) {
            emit(LobbyDetailLoaded(lobby: lobby, participants: participants));

            _lobbySubscription?.cancel();
            _participantsSubscription?.cancel();

            _lobbySubscription = _lobbyRepository
                .watchLobby(event.lobbyId)
                .listen((updatedLobby) {
              if (updatedLobby != null && state is LobbyDetailLoaded) {
                final currentState = state as LobbyDetailLoaded;
                add(LobbyDetailUpdated(
                    updatedLobby, currentState.participants));
              }
            });

            _participantsSubscription = _lobbyRepository
                .watchParticipants(event.lobbyId)
                .listen((updatedParticipants) {
              if (state is LobbyDetailLoaded) {
                final currentState = state as LobbyDetailLoaded;
                add(LobbyDetailUpdated(
                    currentState.lobby, updatedParticipants));
              }
            });
          },
          failure: (f) {
            emit(LobbyDetailError(f.message));
          },
        );
      },
      failure: (f) async {
        emit(LobbyDetailError(f.message));
      },
    );
  }

  Future<void> _onJoin(
    JoinLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    // Hold deposit first if required
    double heldAmount = 0;
    if (state is LobbyDetailLoaded) {
      final current = state as LobbyDetailLoaded;
      final lobby = current.lobby;
      if (lobby.hasDeposit && lobby.depositAmount > 0) {
        heldAmount = lobby.depositAmount;
        final holdResult = await sl<WalletRepository>().holdDeposit(
          userId: event.userId,
          lobbyId: event.lobbyId,
          amount: heldAmount,
        );
        
        bool holdSuccess = false;
        holdResult.when(
          success: (_) => holdSuccess = true,
          failure: (f) {
            emit(LobbyDetailError(f.message));
          },
        );

        if (!holdSuccess) return;
      }
    }

    // Optimistic UI Update
    if (state is LobbyDetailLoaded) {
      final current = state as LobbyDetailLoaded;
      final optimisticLobby = current.lobby.copyWith(
        currentPlayers: current.lobby.currentPlayers + 1,
      );
      final optimisticParticipant = LobbyParticipantEntity(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        lobbyId: event.lobbyId,
        userId: event.userId,
        status: current.lobby.isFull
            ? ParticipantStatus.waitlisted
            : ParticipantStatus.joined,
        joinedAt: DateTime.now(),
      );
      emit(LobbyDetailLoaded(
        lobby: optimisticLobby,
        participants: [...current.participants, optimisticParticipant],
      ));
    }

    final result = await _lobbyRepository.joinLobby(
      lobbyId: event.lobbyId,
      userId: event.userId,
    );
    await result.when(
      success: (_) async {
        emit(const LobbyActionSuccess('Successfully joined the lobby!'));
        sl<WalletBloc>().add(LoadWallet(event.userId));
        add(LoadLobbyDetail(event.lobbyId));
      },
      failure: (f) async {
        if (heldAmount > 0) {
          // Release deposit if join failed
          await sl<WalletRepository>().releaseDeposit(
            userId: event.userId,
            lobbyId: event.lobbyId,
            amount: heldAmount,
          );
        }
        emit(LobbyDetailError(f.message));
        add(LoadLobbyDetail(event.lobbyId)); // Revert optimistic update
      },
    );
  }

  Future<void> _onLeave(
    LeaveLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    double releaseAmount = 0;
    if (state is LobbyDetailLoaded) {
      final current = state as LobbyDetailLoaded;
      final lobby = current.lobby;
      final participant = current.participants.firstWhere(
        (p) => p.userId == event.userId,
        orElse: () => LobbyParticipantEntity(
          id: '',
          lobbyId: '',
          userId: '',
          status: ParticipantStatus.left,
          joinedAt: DateTime.now(),
        ),
      );
      // Only release deposit if it was actually held for this participant
      if (lobby.hasDeposit && lobby.depositAmount > 0 && participant.depositHeld) {
        releaseAmount = lobby.depositAmount;
      }
    }

    // Optimistic UI Update
    if (state is LobbyDetailLoaded) {
      final current = state as LobbyDetailLoaded;
      final optimisticLobby = current.lobby.copyWith(
        currentPlayers: (current.lobby.currentPlayers - 1).clamp(0, 999),
      );
      final optimisticParticipants =
          current.participants.where((p) => p.userId != event.userId).toList();
      emit(LobbyDetailLoaded(
        lobby: optimisticLobby,
        participants: optimisticParticipants,
      ));
    }

    final result = await _lobbyRepository.leaveLobby(
      lobbyId: event.lobbyId,
      userId: event.userId,
    );
    await result.when(
      success: (_) async {
        if (releaseAmount > 0) {
          await sl<WalletRepository>().releaseDeposit(
            userId: event.userId,
            lobbyId: event.lobbyId,
            amount: releaseAmount,
          );
        }
        emit(const LobbyActionSuccess('Successfully left the lobby.'));
        sl<WalletBloc>().add(LoadWallet(event.userId));
        add(LoadLobbyDetail(event.lobbyId));
      },
      failure: (f) {
        emit(LobbyDetailError(f.message));
        add(LoadLobbyDetail(event.lobbyId)); // Revert optimistic update
      },
    );
  }

  Future<void> _onConfirm(
    ConfirmLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    final result = await _lobbyRepository.updateLobbyStatus(
      lobbyId: event.lobbyId,
      status: LobbyStatus.confirmed,
    );
    result.when(
      success: (_) {
        emit(const LobbyActionSuccess('Lobby confirmed!'));
        add(LoadLobbyDetail(event.lobbyId));
      },
      failure: (f) {
        emit(LobbyDetailError(f.message));
      },
    );
  }

  Future<void> _onCancel(
    CancelLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    final result = await _lobbyRepository.updateLobbyStatus(
      lobbyId: event.lobbyId,
      status: LobbyStatus.cancelled,
    );
    result.when(
      success: (_) {
        emit(const LobbyActionSuccess('Lobby cancelled.'));
        add(LoadLobbyDetail(event.lobbyId));
      },
      failure: (f) {
        emit(LobbyDetailError(f.message));
      },
    );
  }

  Future<void> _onSettle(
    SettleLobbyRequested event,
    Emitter<LobbyDetailState> emit,
  ) async {
    emit(LobbyDetailLoading());
    final settleResult = await sl<MatchRepository>().settleLobby(event.lobbyId);
    await settleResult.when(
      success: (_) async {
        emit(const LobbyActionSuccess('Lobby settled and bills split!'));
        if (state is LobbyDetailLoaded) {
          final loaded = state as LobbyDetailLoaded;
          sl<WalletBloc>().add(LoadWallet(loaded.lobby.hostId));
          for (final p in loaded.participants) {
            sl<WalletBloc>().add(LoadWallet(p.userId));
          }
        }
        add(LoadLobbyDetail(event.lobbyId));
      },
      failure: (f) async {
        emit(LobbyDetailError(f.message));
        add(LoadLobbyDetail(event.lobbyId));
      },
    );
  }
}
