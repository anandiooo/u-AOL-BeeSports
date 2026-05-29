import 'package:beesports/models/user_entity.dart';
import 'package:beesports/models/friendship_entity.dart';
import 'package:beesports/repos/social_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SupabaseClient _client;

  SocialRepositoryImpl(this._client);

  @override
  Future<Result<void>> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    return withRetry(() async {
      await _client.from('friendships').insert({
        'requester_id': requesterId,
        'addressee_id': addresseeId,
        'status': 'pending',
      });
    });
  }

  @override
  Future<Result<void>> respondToRequest(
      String friendshipId, bool accept) async {
    return withRetry(() async {
      if (accept) {
        await _client
            .from('friendships')
            .update({'status': 'accepted'}).eq('id', friendshipId);
      } else {
        await _client.from('friendships').delete().eq('id', friendshipId);
      }
    });
  }

  @override
  Future<Result<List<FriendshipEntity>>> getFriends(String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('friendships')
          .select(
            '*, requester:profiles!friendships_requester_id_fkey(full_name, avatar_url), addressee:profiles!friendships_addressee_id_fkey(full_name, avatar_url)',
          )
          .eq('status', 'accepted')
          .or('requester_id.eq.$userId,addressee_id.eq.$userId')
          .order('created_at', ascending: false);

      return (data as List).map((e) => FriendshipEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<List<FriendshipEntity>>> getPendingRequests(
      String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('friendships')
          .select(
            '*, requester:profiles!friendships_requester_id_fkey(full_name, avatar_url)',
          )
          .eq('addressee_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (data as List).map((e) => FriendshipEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<List<UserEntity>>> searchUsers(String query) async {
    return withRetry(() async {
      if (query.length < 2) return [];

      final data = await _client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,nim.ilike.%$query%')
          .limit(20);

      return (data as List).map((e) => UserEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<void>> removeFriend(String friendshipId) async {
    return withRetry(() async {
      await _client.from('friendships').delete().eq('id', friendshipId);
    });
  }
}
