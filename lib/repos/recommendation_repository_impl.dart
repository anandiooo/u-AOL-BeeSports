import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/repos/recommendation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final SupabaseClient _client;

  RecommendationRepositoryImpl(this._client);

  @override
  Future<Result<List<LobbyEntity>>> getRecommendedLobbies(
      String userId) async {
    return withRetry(() async {
      // Fetch user's sport preferences and campus
      final profile = await _client
          .from('profiles')
          .select('sport_preferences, campus')
          .eq('id', userId)
          .single();

      final sportPrefs =
          List<String>.from(profile['sport_preferences'] ?? []);

      // Fetch open lobbies that match user's sport preferences
      var query = _client
          .from('lobbies')
          .select(
              '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
          .eq('status', 'open')
          .gt('scheduled_at', DateTime.now().toIso8601String());

      if (sportPrefs.isNotEmpty) {
        query = query.inFilter('sport', sportPrefs);
      }

      final data =
          await query.order('scheduled_at', ascending: true).limit(10);

      final lobbies =
          (data as List).map((e) => LobbyEntity.fromMap(e)).toList();

      // Sort by relevance: prefer lobbies from same campus host, with available slots
      lobbies.sort((a, b) {
        // Prefer lobbies with more slots available
        final slotsA = a.slotsAvailable;
        final slotsB = b.slotsAvailable;
        if (slotsA != slotsB) return slotsB.compareTo(slotsA);
        // Then by time (sooner first)
        return a.scheduledAt.compareTo(b.scheduledAt);
      });

      return lobbies;
    });
  }
}
