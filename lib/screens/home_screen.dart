import 'dart:math' as math;

import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<NotificationBloc>()
          .add(LoadNotifications(authState.user.id));
      // Load the user's upcoming lobbies for the Upcoming Matches section
      context
          .read<LobbyListBloc>()
          .add(LoadMyLobbies(authState.user.id));
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final userName =
        state is Authenticated ? (state.user.fullName ?? 'Player') : 'Player';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header & profile card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: AppColors.textPrimaryDark
                                .withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      // notification bell
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textPrimaryDark
                                  .withValues(alpha: 0.05),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textPrimaryDark
                                    .withValues(alpha: 0.7),
                                size: 22,
                              ),
                              BlocBuilder<NotificationBloc, NotificationState>(
                                builder: (context, nState) {
                                  final count = nState is NotificationLoaded
                                      ? nState.unreadCount
                                      : 0;
                                  if (count == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // profile avatar
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: AppColors.textPrimaryDark,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // search bar
              GestureDetector(
                onTap: () => context.push('/lobbies'),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            AppColors.textPrimaryDark.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color:
                              AppColors.textPrimaryDark.withValues(alpha: 0.5)),
                      const SizedBox(width: 12),
                      Text(
                        'Find matches, players, or lobbies...',
                        style: TextStyle(
                          color:
                              AppColors.textPrimaryDark.withValues(alpha: 0.4),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // categories header
              const Text(
                'Explore Sports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // horizontal sports list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _SportCard(
                        title: 'Futsal',
                        icon: Icons.sports_soccer,
                        color: AppColors.futsal,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 16),
                    _SportCard(
                        title: 'Basketball',
                        icon: Icons.sports_basketball,
                        color: AppColors.basketball,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 16),
                    _SportCard(
                        title: 'Badminton',
                        icon: Icons.sports_tennis,
                        color: AppColors.badminton,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 16),
                    _SportCard(
                        title: 'Volleyball',
                        icon: Icons.sports_volleyball,
                        color: AppColors.volleyball,
                        onTap: () => context.push('/lobbies')),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // quick actions header
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // hero action - create lobby
              GestureDetector(
                onTap: () => context.push('/lobbies/create'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // decorative background icon
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Transform.rotate(
                          angle: -math.pi / 12,
                          child: Icon(
                            Icons.add_circle,
                            size: 120,
                            color: AppColors.backgroundLight
                                .withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.backgroundDark,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Host a Match',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.backgroundDark,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new lobby and invite players',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.backgroundDark
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // secondary actions row
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      title: 'Find Match',
                      subtitle: 'Join an existing game',
                      icon: Icons.radar,
                      iconColor: AppColors.primaryLight,
                      onTap: () => context.push('/lobbies'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BentoCard(
                      title: 'My Wallet',
                      subtitle: 'Manage balance',
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.success,
                      onTap: () => context.push('/wallet'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      title: 'Friends',
                      subtitle: 'Find & connect',
                      icon: Icons.people_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      onTap: () => context.push('/friends'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BentoCard(
                      title: 'Leaderboard',
                      subtitle: 'Top players',
                      icon: Icons.leaderboard_rounded,
                      iconColor: AppColors.warning,
                      onTap: () => context.push('/leaderboard'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // upcoming matches header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Matches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/lobbies'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // upcoming matches section
              BlocBuilder<LobbyListBloc, LobbyListState>(
                builder: (context, state) {
                  if (state is LobbyListLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    );
                  }

                  final lobbies = state is LobbyListLoaded
                      ? state.lobbies
                          .where((l) =>
                              l.status == LobbyStatus.open ||
                              l.status == LobbyStatus.confirmed)
                          .toList()
                      : <LobbyEntity>[];

                  if (lobbies.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.textPrimaryDark
                                .withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textPrimaryDark
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              size: 48,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No matches soon',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hop into a lobby or create one to start playing!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimaryDark
                                  .withValues(alpha: 0.5),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show up to 3 upcoming match cards
                  final preview = lobbies.take(3).toList();
                  return Column(
                    children: preview
                        .map((lobby) => _UpcomingMatchCard(lobby: lobby))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _BentoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingMatchCard extends StatelessWidget {
  final LobbyEntity lobby;

  const _UpcomingMatchCard({required this.lobby});

  @override
  Widget build(BuildContext context) {
    final sport = lobby.sport;
    final now = DateTime.now();
    final diff = lobby.scheduledAt.difference(now);
    final String dateLabel;
    if (diff.inDays == 0 && lobby.scheduledAt.day == now.day) {
      dateLabel = 'Today';
    } else if (diff.inDays <= 1 &&
        lobby.scheduledAt.day == now.day + 1) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel =
          '${lobby.scheduledAt.day}/${lobby.scheduledAt.month}';
    }
    final timeLabel =
        '${lobby.scheduledAt.hour.toString().padLeft(2, '0')}:${lobby.scheduledAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => context.push('/lobbies/${lobby.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // sport icon bubble
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sport.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(sport.icon, color: sport.color, size: 22),
            ),
            const SizedBox(width: 14),
            // lobby info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lobby.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.textPrimaryDark
                              .withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '$dateLabel • $timeLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimaryDark
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: lobby.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                lobby.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: lobby.status.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
