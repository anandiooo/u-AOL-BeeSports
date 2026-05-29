import 'dart:async';
import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/repos/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications(
      String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List).map((e) => NotificationEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    return withRetry(() async {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    });
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    return withRetry(() async {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    });
  }

  @override
  Future<Result<int>> getUnreadCount(String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      return (data as List).length;
    });
  }

  final Map<String, RealtimeChannel> _channels = {};

  @override
  Stream<NotificationEntity> subscribeToNotifications(String userId) {
    final controller = StreamController<NotificationEntity>.broadcast();

    final channel = _client
        .channel('user-notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty) {
              controller.add(NotificationEntity.fromMap(newRow));
            }
          },
        )
        .subscribe();

    _channels[userId] = channel;

    controller.onCancel = () {
      unsubscribe(userId);
    };

    return controller.stream;
  }

  @override
  void unsubscribe(String userId) {
    final channel = _channels.remove(userId);
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }
}
