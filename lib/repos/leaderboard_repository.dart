import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/models/sport_type.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntryEntity>> getLeaderboard(
    SportType sport, {
    String? campus,
  });

  Future<LeaderboardEntryEntity?> getPlayerRanking(
    String userId,
    SportType sport,
  );
}
