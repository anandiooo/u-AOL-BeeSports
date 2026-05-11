import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<NotificationBloc>()
          .add(LoadNotifications(authState.user.id));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is Authenticated) {
                      context
                          .read<NotificationBloc>()
                          .add(MarkAllAsRead(authState.user.id));
                    }
                  },
                  child: const Text('Mark All Read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.error)),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated) {
                    context
                        .read<NotificationBloc>()
                        .add(LoadNotifications(authState.user.id));
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.1)),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: AppColors.textSecondaryDark
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardDark,
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context
                      .read<NotificationBloc>()
                      .add(LoadNotifications(authState.user.id));
                }
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context
                            .read<NotificationBloc>()
                            .add(MarkAsRead(notification.id));
                      }
                      _navigateToTarget(context, notification);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToTarget(
      BuildContext context, NotificationEntity notification) {
    final data = notification.data;
    if (data == null) return;

    final lobbyId = data['lobby_id'] as String?;
    if (lobbyId != null) {
      context.push('/lobbies/$lobbyId');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData get _icon {
    switch (notification.type) {
      case 'lobby_join':
        return Icons.group_add;
      case 'lobby_leave':
        return Icons.group_remove;
      case 'match_result':
        return Icons.scoreboard;
      case 'friend_request':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'lobby_join':
        return AppColors.primary;
      case 'lobby_leave':
        return AppColors.warning;
      case 'match_result':
        return AppColors.accent;
      case 'friend_request':
        return const Color(0xFF42A5F5);
      default:
        return AppColors.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead
          ? null
          : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: _iconColor, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          notification.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
