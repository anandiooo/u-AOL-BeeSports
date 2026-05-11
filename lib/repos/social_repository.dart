import 'package:beesports/models/user_entity.dart';
import 'package:beesports/models/friendship_entity.dart';

abstract class SocialRepository {
  Future<void> sendFriendRequest(String requesterId, String addresseeId);

  Future<void> respondToRequest(String friendshipId, bool accept);

  Future<List<FriendshipEntity>> getFriends(String userId);

  Future<List<FriendshipEntity>> getPendingRequests(String userId);

  Future<List<UserEntity>> searchUsers(String query);

  Future<void> removeFriend(String friendshipId);
}
