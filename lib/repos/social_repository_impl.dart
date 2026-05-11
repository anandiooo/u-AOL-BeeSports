import 'package:beesports/models/user_entity.dart';
import 'package:beesports/models/friendship_entity.dart';
import 'package:beesports/repos/social_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SupabaseClient _client;

  SocialRepositoryImpl(this._client);

  @override
  Future<void> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    await _client.from('friendships').insert({
      'requester_id': requesterId,
      'addressee_id': addresseeId,
      'status': 'pending',
    });
  }

  @override
  Future<void> respondToRequest(String friendshipId, bool accept) async {
    if (accept) {
      await _client
          .from('friendships')
          .update({'status': 'accepted'}).eq('id', friendshipId);
    } else {
      await _client.from('friendships').delete().eq('id', friendshipId);
    }
  }

  @override
  Future<List<FriendshipEntity>> getFriends(String userId) async {
    final data = await _client
        .from('friendships')
        .select(
          '*, requester:profiles!friendships_requester_id_fkey(full_name, avatar_url), addressee:profiles!friendships_addressee_id_fkey(full_name, avatar_url)',
        )
        .eq('status', 'accepted')
        .or('requester_id.eq.$userId,addressee_id.eq.$userId')
        .order('created_at', ascending: false);

    return (data as List).map((e) => FriendshipEntity.fromMap(e)).toList();
  }

  @override
  Future<List<FriendshipEntity>> getPendingRequests(String userId) async {
    final data = await _client
        .from('friendships')
        .select(
          '*, requester:profiles!friendships_requester_id_fkey(full_name, avatar_url)',
        )
        .eq('addressee_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((e) => FriendshipEntity.fromMap(e)).toList();
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    if (query.length < 2) return [];

    final data = await _client
        .from('profiles')
        .select()
        .or('full_name.ilike.%$query%,nim.ilike.%$query%')
        .limit(20);

    return (data as List).map((e) => UserEntity.fromMap(e)).toList();
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    await _client.from('friendships').delete().eq('id', friendshipId);
  }
}
