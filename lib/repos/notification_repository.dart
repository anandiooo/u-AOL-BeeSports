import 'package:beesports/models/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}
