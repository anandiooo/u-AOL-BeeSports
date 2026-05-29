import 'package:beesports/models/user_entity.dart';
import 'package:beesports/models/friendship_entity.dart';
import 'package:beesports/core/result.dart';

abstract class SocialRepository {
  Future<Result<void>> sendFriendRequest(
      String requesterId, String addresseeId);

  Future<Result<void>> respondToRequest(String friendshipId, bool accept);

  Future<Result<List<FriendshipEntity>>> getFriends(String userId);

  Future<Result<List<FriendshipEntity>>> getPendingRequests(String userId);

  Future<Result<List<UserEntity>>> searchUsers(String query);

  Future<Result<void>> removeFriend(String friendshipId);
}
