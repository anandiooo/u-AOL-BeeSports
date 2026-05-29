import 'package:beesports/models/match_entity.dart';
import 'package:beesports/models/match_participant_entity.dart';
import 'package:beesports/core/result.dart';

abstract class MatchRepository {
  Future<Result<MatchEntity>> submitResult({
    required String lobbyId,
    required int teamAScore,
    required int teamBScore,
  });

  Future<Result<MatchEntity?>> getMatchByLobby(String lobbyId);

  Future<Result<List<MatchParticipantEntity>>> getMatchParticipants(
      String matchId);

  Future<Result<List<MatchEntity>>> getMyMatches(String userId);

  Future<Result<void>> settleMatch(String matchId);
}
