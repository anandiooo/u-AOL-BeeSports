import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/repos/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List).map((e) => NotificationEntity.fromMap(e)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }
}
