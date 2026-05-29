import 'package:beesports/models/leaderboard_entry_entity.dart';
import 'package:beesports/repos/leaderboard_repository.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final SupabaseClient _client;

  LeaderboardRepositoryImpl(this._client);

  @override
  Future<Result<List<LeaderboardEntryEntity>>> getLeaderboard(
    SportType sport, {
    String? campus,
  }) async {
    return withRetry(() async {
      var query =
          _client.from('v_sport_leaderboard').select().eq('sport', sport.name);

      if (campus != null && campus.isNotEmpty) {
        query = query.eq('campus', campus);
      }

      final data = await query.order('sport_rank', ascending: true).limit(50);
      return (data as List)
          .map((e) => LeaderboardEntryEntity.fromMap(e))
          .toList();
    });
  }

  @override
  Future<Result<LeaderboardEntryEntity?>> getPlayerRanking(
    String userId,
    SportType sport,
  ) async {
    return withRetry(() async {
      final data = await _client
          .from('v_sport_leaderboard')
          .select()
          .eq('user_id', userId)
          .eq('sport', sport.name)
          .maybeSingle();

      if (data == null) return null;
      return LeaderboardEntryEntity.fromMap(data);
    });
  }
}
