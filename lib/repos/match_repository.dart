import 'package:beesports/models/match_entity.dart';
import 'package:beesports/models/match_participant_entity.dart';

abstract class MatchRepository {
  Future<MatchEntity> submitResult({
    required String lobbyId,
    required int teamAScore,
    required int teamBScore,
  });

  Future<MatchEntity?> getMatchByLobby(String lobbyId);

  Future<List<MatchParticipantEntity>> getMatchParticipants(String matchId);

  Future<List<MatchEntity>> getMyMatches(String userId);

  Future<void> settleMatch(String matchId);
}
