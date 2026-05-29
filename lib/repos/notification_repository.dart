import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/core/result.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications(String userId);
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead(String userId);
  Future<Result<int>> getUnreadCount(String userId);
  Stream<NotificationEntity> subscribeToNotifications(String userId);
  void unsubscribe(String userId);
}
