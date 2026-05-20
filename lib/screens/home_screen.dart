import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final userName =
        state is Authenticated ? (state.user.fullName ?? 'Player') : 'Player';

    return Scaffold(
      backgroundColor: AppColors.foursier,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with profile and notifications
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
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
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.primary,
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
                                          color: AppColors.secondaryDark,
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
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Hero(
                            tag: 'profile_avatar',
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.foursierLight,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.push('/lobbies'),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: AppColors.primary.withValues(alpha: 0.4),
                            size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Find matches, players, or lobbies...',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Hero campaign tile — Host a Match
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.push('/lobbies/create'),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Stack(
                      children: [
                        // Large display headline
                        Positioned(
                          left: 24,
                          top: 24,
                          right: 80,
                          child: Text(
                            'HOST A\nMATCH',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 56,
                              fontWeight: FontWeight.w400,
                              color: AppColors.foursierLight,
                              height: 0.9,
                            ),
                          ),
                        ),
                        // Pill CTA at bottom-left
                        Positioned(
                          left: 24,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.foursier,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Create Lobby',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        // Decorative icon
                        Positioned(
                          right: 16,
                          top: 16,
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 80,
                            color: AppColors.foursierLight.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Section: Explore Sports
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Explore Sports',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _SportCard(
                        title: 'Futsal',
                        icon: Icons.sports_soccer,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Basketball',
                        icon: Icons.sports_basketball,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Badminton',
                        icon: Icons.sports_tennis,
                        onTap: () => context.push('/lobbies')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Volleyball',
                        icon: Icons.sports_volleyball,
                        onTap: () => context.push('/lobbies')),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Quick Actions — 2-up grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'Find Match',
                        subtitle: 'Join an existing game',
                        icon: Icons.radar,
                        onTap: () => context.push('/lobbies'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionCard(
                        title: 'My Wallet',
                        subtitle: 'Manage balance',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => context.push('/wallet'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'Friends',
                        subtitle: 'Find & connect',
                        icon: Icons.people_outlined,
                        onTap: () => context.push('/friends'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionCard(
                        title: 'Leaderboard',
                        subtitle: 'Top players',
                        icon: Icons.leaderboard_outlined,
                        onTap: () => context.push('/leaderboard'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Upcoming Matches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Matches',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/lobbies'),
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.foursier,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_esports_outlined,
                        size: 40,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No matches soon',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hop into a lobby or create one to start playing!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.primaryLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sport card following Nike's category-icon-card pattern
class _SportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SportCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.secondaryLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action card — flat, no shadow, soft-cloud background
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.secondaryLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
