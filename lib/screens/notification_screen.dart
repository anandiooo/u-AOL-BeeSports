import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/notification_entity.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<NotificationBloc>()
          .add(LoadNotifications(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: AppTextStyles.sectionTitle),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final a = context.read<AuthBloc>().state;
                    if (a is Authenticated) {
                      context
                          .read<NotificationBloc>()
                          .add(MarkAllAsRead(a.user.id));
                    }
                  },
                  child: Text(
                    'Mark All Read',
                    style: AppTextStyles.linkUnderlined,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
            DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return ShimmerListView.notifications(count: 6);
            }
            if (state is NotificationError) {
              return Center(
                  child: Text(state.message,
                      style: AppTextStyles.error));
            }
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) return const EmptyNotifications();
              return RefreshIndicator(
                color: AppColors.neonGreen,
                onRefresh: () async {
                  final a = context.read<AuthBloc>().state;
                  if (a is Authenticated) {
                    context
                        .read<NotificationBloc>()
                        .add(LoadNotifications(a.user.id));
                  }
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.zero,
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final n = state.notifications[index];
                  return _NotificationTile(
                    notification: n,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (!n.isRead) {
                        context.read<NotificationBloc>().add(MarkAsRead(n.id));
                      }
                      _navigateToTarget(context, n);
                    },
                  )
                      .animate()
                      .fadeIn(
                          delay: (60 * index).ms,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic)
                      .slideX(
                          begin: 0.05,
                          delay: (60 * index).ms,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: DesignConfig.spacingLg),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.hairline))),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.softCloud
                      : AppColors.neonGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon,
                    size: 20,
                    color: notification.isRead
                        ? AppColors.textSecondary
                        : AppColors.onAccent),
              ),
              const SizedBox(width: DesignConfig.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.notificationBody(
                        isRead: notification.isRead,
                      ),
                    ),
                    const SizedBox(height: DesignConfig.spacingXxs),
                    Text(notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.neonGreen, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}


