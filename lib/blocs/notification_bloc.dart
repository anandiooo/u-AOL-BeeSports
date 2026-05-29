import 'dart:async';
import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/repos/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  LoadNotifications(this.userId);
}

class NewNotificationReceived extends NotificationEvent {
  final NotificationEntity notification;
  NewNotificationReceived(this.notification);
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
  StreamSubscription<NotificationEntity>? _subscription;
  String? _currentUserId;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<NewNotificationReceived>(_onNewNotification);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  void _onNewNotification(
    NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final loaded = state as NotificationLoaded;
      emit(NotificationLoaded(
        [event.notification, ...loaded.notifications],
        unreadCount: loaded.unreadCount + 1,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    if (_currentUserId != null) {
      _repository.unsubscribe(_currentUserId!);
    }
    return super.close();
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final notifsResult = await _repository.getNotifications(event.userId);
    final unreadResult = await _repository.getUnreadCount(event.userId);

    notifsResult.when(
      success: (notifications) {
        if (_currentUserId != null && _currentUserId != event.userId) {
          _subscription?.cancel();
          _repository.unsubscribe(_currentUserId!);
        }

        _currentUserId = event.userId;
        _subscription?.cancel();
        _subscription = _repository
            .subscribeToNotifications(event.userId)
            .listen((notif) => add(NewNotificationReceived(notif)));

        final unread = unreadResult.when(success: (u) => u, failure: (_) => 0);
        emit(NotificationLoaded(notifications, unreadCount: unread));
      },
      failure: (f) {
        emit(NotificationError(f.message));
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAsRead(event.notificationId);
    result.when(
      success: (_) {
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
      },
      failure: (f) {
        emit(NotificationError(f.message));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAllAsRead(event.userId);
    result.when(
      success: (_) {
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
      },
      failure: (f) {
        emit(NotificationError(f.message));
      },
    );
  }
}
