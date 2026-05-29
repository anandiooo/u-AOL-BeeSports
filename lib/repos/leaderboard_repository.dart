import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:beesports/core/result.dart';

abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardEntryEntity>>> getLeaderboard(
    SportType sport, {
    String? campus,
  });

  Future<Result<LeaderboardEntryEntity?>> getPlayerRanking(
    String userId,
    SportType sport,
  );
}
