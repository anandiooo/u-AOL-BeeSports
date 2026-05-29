import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:beesports/core/result.dart';

abstract class LobbyRepository {
  Future<Result<List<LobbyEntity>>> getLobbies({
    SportType? sport,
    LobbyStatus? status,
    String? sortBy,
    String? searchQuery,
  });

  Future<Result<LobbyEntity?>> getLobbyById(String lobbyId);

  Stream<LobbyEntity?> watchLobby(String lobbyId);

  Future<Result<List<LobbyParticipantEntity>>> getParticipants(String lobbyId);

  Stream<List<LobbyParticipantEntity>> watchParticipants(String lobbyId);

  Future<Result<LobbyEntity>> createLobby(LobbyEntity lobby);

  Future<Result<void>> joinLobby({
    required String lobbyId,
    required String userId,
  });

  Future<Result<void>> leaveLobby({
    required String lobbyId,
    required String userId,
  });

  Future<Result<void>> updateLobbyStatus({
    required String lobbyId,
    required LobbyStatus status,
  });

  Future<Result<List<LobbyEntity>>> getMyLobbies(String userId);
}
