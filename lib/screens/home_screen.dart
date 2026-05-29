import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      context.read<ProfileBloc>().add(ProfileLoadRequested(authState.user.id));
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              color: AppColors.mute,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            style: GoogleFonts.inter(
                              color: AppColors.neonGreen,
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/notifications');
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.softCloud,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.neonGreen,
                                    size: 22,
                                  ),
                                  BlocBuilder<NotificationBloc,
                                      NotificationState>(
                                    builder: (context, nState) {
                                      final count = nState is NotificationLoaded
                                          ? nState.unreadCount
                                          : 0;
                                      if (count == 0)
                                        return const SizedBox.shrink();
                                      return Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: AppColors.accentOrange,
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
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/profile'),
                            borderRadius: BorderRadius.circular(20),
                            child: Hero(
                              tag: 'profile_avatar',
                              child: BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  String? avatarUrl;
                                  String initials = 'U';

                                  if (state is ProfileLoaded ||
                                      state is ProfileUpdateSuccess) {
                                    final profile = state is ProfileLoaded
                                        ? state.profile
                                        : (state as ProfileUpdateSuccess)
                                            .profile;
                                    avatarUrl = profile.avatarUrl;
                                    final name = profile.fullName ?? '';
                                    if (name.isNotEmpty) {
                                      initials = name
                                          .split(' ')
                                          .where((w) => w.isNotEmpty)
                                          .map((w) => w[0].toUpperCase())
                                          .join()
                                          .substring(
                                              0,
                                              (name
                                                              .split(' ')
                                                              .where((w) =>
                                                                  w.isNotEmpty)
                                                              .length >
                                                          1
                                                      ? 2
                                                      : 1)
                                                  .clamp(0, 2));
                                    }
                                  }

                                  return Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.neonGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: avatarUrl != null &&
                                              avatarUrl.isNotEmpty
                                          ? Image.network(
                                              avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.neonGreen,
                                                  child: Center(
                                                    child: Text(
                                                      initials,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.onPrimary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: AppColors.neonGreen,
                                              child: Center(
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: AppColors.onPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideY(
                      begin: -0.05,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/lobbies/create');
                    },
                    borderRadius: BorderRadius.zero,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 24,
                            top: 24,
                            right: 80,
                            child: Text(
                              'HOST A\nMATCH',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 56,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onPrimary,
                                height: 0.9,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            bottom: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Create Lobby',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neonGreen,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 80,
                              color:
                                  AppColors.onPrimary.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(
                  begin: 0.05,
                  delay: 100.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Explore Sports',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                    height: 1.2,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
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
                        color: AppColors.futsal,
                        onTap: () => context.go('/lobbies?sport=futsal')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Basketball',
                        icon: Icons.sports_basketball,
                        color: AppColors.basketball,
                        onTap: () => context.go('/lobbies?sport=basketball')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Badminton',
                        icon: Icons.sports_tennis,
                        color: AppColors.badminton,
                        onTap: () => context.go('/lobbies?sport=badminton')),
                    const SizedBox(width: 8),
                    _SportCard(
                        title: 'Volleyball',
                        icon: Icons.sports_volleyball,
                        color: AppColors.volleyball,
                        onTap: () => context.go('/lobbies?sport=volleyball')),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 350.ms).slideX(
                  begin: 0.05,
                  delay: 250.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                    height: 1.2,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                        child: _ActionCard(
                            title: 'Find Match',
                            subtitle: 'Join a lobby',
                            icon: Icons.radar,
                            onTap: () => context.go('/lobbies'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _ActionCard(
                            title: 'My Wallet',
                            subtitle: 'Manage balance',
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: () => context.go('/wallet'))),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 350.ms).slideY(
                  begin: 0.03,
                  delay: 350.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
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
                            onTap: () => context.push('/friends'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _ActionCard(
                            title: 'Leaderboard',
                            subtitle: 'Top players',
                            icon: Icons.leaderboard_outlined,
                            onTap: () => context.go('/leaderboard'))),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 350.ms).slideY(
                  begin: 0.03,
                  delay: 400.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
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
                        color: AppColors.charcoal,
                        height: 1.2,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/lobbies'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neonGreen,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: EmptyUpcomingMatches(
                    onFindMatch: () => context.go('/lobbies')),
              ).animate().fadeIn(delay: 500.ms, duration: 350.ms).slideY(
                  begin: 0.05,
                  delay: 500.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
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

  const _SportCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.neonGreen, size: 24),
              const SizedBox(height: 18),
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal,
                      height: 1.2)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.mute)),
            ],
          ),
        ),
      ),
    );
  }
}
