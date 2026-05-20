import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NotificationBloc>().add(LoadNotifications(authState.user.id));
    }
    return Scaffold(
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.primary)),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    final a = context.read<AuthBloc>().state;
                    if (a is Authenticated) {
                      context
                          .read<NotificationBloc>()
                          .add(MarkAllAsRead(a.user.id));
                    }
                  },
                  child: Text('Mark All Read',
                      style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline)),
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
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is NotificationError) {
            return Center(
                child: Text(state.message,
                    style: GoogleFonts.inter(color: AppColors.tersierDark)));
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmpty(context);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.foursier,
              onRefresh: () async {
                final a = context.read<AuthBloc>().state;
                if (a is Authenticated) {
                  context
                      .read<NotificationBloc>()
                      .add(LoadNotifications(a.user.id));
                }
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final n = state.notifications[index];
                  return _NotificationTile(
                    notification: n,
                    onTap: () {
                      if (!n.isRead) {
                        context
                            .read<NotificationBloc>()
                            .add(MarkAsRead(n.id));
                      }
                      _navigateToTarget(context, n);
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

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.foursier,
      onRefresh: () async {
        final a = context.read<AuthBloc>().state;
        if (a is Authenticated) {
          context.read<NotificationBloc>().add(LoadNotifications(a.user.id));
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
                  const Icon(Icons.notifications_none,
                      size: 64, color: AppColors.tersierLight),
                  const SizedBox(height: 12),
                  Text('No notifications yet',
                      style: GoogleFonts.inter(color: AppColors.primaryLight)),
                ]),
          ),
        ),
      ),
    );
  }

  void _navigateToTarget(
      BuildContext context, NotificationEntity notification) {
    final data = notification.data;
    if (data == null) return;
    final lobbyId = data['lobby_id'] as String?;
    if (lobbyId != null) context.push('/lobbies/$lobbyId');
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.tersierLight)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? AppColors.secondaryLight
                  : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon,
                size: 20,
                color: notification.isRead
                    ? AppColors.primaryLight
                    : AppColors.foursierLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: GoogleFonts.inter(
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.primaryLight)),
                ]),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ]),
      ),
    );
  }
}
