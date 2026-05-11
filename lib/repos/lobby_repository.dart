import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';

abstract class LobbyRepository {
  Future<List<LobbyEntity>> getLobbies({
    SportType? sport,
    LobbyStatus? status,
    String? sortBy,
  });

  Future<LobbyEntity?> getLobbyById(String lobbyId);

  Future<List<LobbyParticipantEntity>> getParticipants(String lobbyId);

  Future<LobbyEntity> createLobby(LobbyEntity lobby);

  Future<void> joinLobby({
    required String lobbyId,
    required String userId,
  });

  Future<void> leaveLobby({
    required String lobbyId,
    required String userId,
  });

  Future<void> updateLobbyStatus({
    required String lobbyId,
    required LobbyStatus status,
  });

  Future<List<LobbyEntity>> getMyLobbies(String userId);
}
