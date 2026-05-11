import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/repos/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  LoadNotifications(this.userId);
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;
  MarkAsRead(this.notificationId);
}

class MarkAllAsRead extends NotificationEvent {
  final String userId;
  MarkAllAsRead(this.userId);
}

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  NotificationLoaded(this.notifications, {this.unreadCount = 0});
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getNotifications(event.userId);
      final unread = await _repository.getUnreadCount(event.userId);
      emit(NotificationLoaded(notifications, unreadCount: unread));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);
      if (state is NotificationLoaded) {
        final loaded = state as NotificationLoaded;
        final updated = loaded.notifications.map((n) {
          if (n.id == event.notificationId) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              body: n.body,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        emit(NotificationLoaded(
          updated,
          unreadCount: (loaded.unreadCount - 1).clamp(0, 999),
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead(event.userId);
      if (state is NotificationLoaded) {
        final loaded = state as NotificationLoaded;
        final updated = loaded.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
        emit(NotificationLoaded(updated, unreadCount: 0));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
