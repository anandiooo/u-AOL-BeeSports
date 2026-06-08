import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/screens/lobby_list_screen.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tryLoadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && context.mounted) {
      _reloadIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _tryLoadData() {
    if (_hasLoaded) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      setState(() => _hasLoaded = true);
      context
          .read<NotificationBloc>()
          .add(LoadNotifications(authState.user.id));
      context.read<ProfileBloc>().add(ProfileLoadRequested(authState.user.id));
      context.read<LobbyListBloc>().add(LoadMyLobbies(authState.user.id));
    }
  }

  void _reloadIfNeeded() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<LobbyListBloc>()
          .add(LoadMyLobbies(authState.user.id));
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
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTextStyles.greeting,
                        ),
                        const SizedBox(height: DesignConfig.spacingXxs),
                        Text(
                          userName,
                          style: AppTextStyles.userName.copyWith(height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DesignConfig.spacingMd),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/notifications');
                          },
                          borderRadius:
                              BorderRadius.circular(DesignConfig.roundedLg),
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
                                    if (count == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Positioned(
                                      top: DesignConfig.spacingSm,
                                      right: DesignConfig.spacingSm,
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
                      const SizedBox(width: DesignConfig.spacingMd),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/profile'),
                          borderRadius:
                              BorderRadius.circular(DesignConfig.roundedLg),
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
                                      : (state as ProfileUpdateSuccess).profile;
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
                                                    style: AppTextStyles
                                                        .onAccentBody
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                style: AppTextStyles
                                                    .onAccentBody
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
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
              )
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideY(
                      begin: -0.05,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: DesignConfig.spacing2xl),
              Material(
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
                          left: DesignConfig.spacingXl,
                          top: DesignConfig.spacingXl,
                          right: DesignConfig.spacing3xl,
                          child: Text(
                            'HOST A\nMATCH',
                            style: AppTextStyles.bebas(
                              DesignConfig.displayXl,
                              color: AppColors.onAccent,
                              height: 0.9,
                            ),
                          ),
                        ),
                        Positioned(
                          right: DesignConfig.spacingLg,
                          top: DesignConfig.spacingLg,
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 80,
                            color: AppColors.onAccent.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(
                  begin: 0.05,
                  delay: 100.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: DesignConfig.spacing2xl),
              Text(
                'Explore Sports',
                style: AppTextStyles.sectionTitle,
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
              const SizedBox(height: DesignConfig.spacingMd),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    _SportCard(
                        title: 'Futsal',
                        icon: Icons.sports_soccer,
                        color: AppColors.futsal,
                        onTap: () => context.go('/lobbies?sport=futsal')),
                    const SizedBox(width: DesignConfig.spacingSm),
                    _SportCard(
                        title: 'Basketball',
                        icon: Icons.sports_basketball,
                        color: AppColors.basketball,
                        onTap: () => context.go('/lobbies?sport=basketball')),
                    const SizedBox(width: DesignConfig.spacingSm),
                    _SportCard(
                        title: 'Badminton',
                        icon: Icons.sports_tennis,
                        color: AppColors.badminton,
                        onTap: () => context.go('/lobbies?sport=badminton')),
                    const SizedBox(width: DesignConfig.spacingSm),
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
              const SizedBox(height: DesignConfig.spacing2xl),
              Text(
                'Quick Actions',
                style: AppTextStyles.sectionTitle,
              ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
              const SizedBox(height: DesignConfig.spacingMd),
              Row(
                children: [
                  Expanded(
                      child: _ActionCard(
                          title: 'Find Match',
                          subtitle: 'Join a lobby',
                          icon: Icons.radar,
                          onTap: () => context.go('/lobbies'))),
                  const SizedBox(width: DesignConfig.spacingSm),
                  Expanded(
                      child: _ActionCard(
                          title: 'My Wallet',
                          subtitle: 'Manage balance',
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => context.go('/wallet'))),
                ],
              ).animate().fadeIn(delay: 350.ms, duration: 350.ms).slideY(
                  begin: 0.03,
                  delay: 350.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: DesignConfig.spacingSm),
              Row(
                children: [
                  Expanded(
                      child: _ActionCard(
                          title: 'Friends',
                          subtitle: 'Find & connect',
                          icon: Icons.people_outlined,
                          onTap: () => context.push('/friends'))),
                  const SizedBox(width: DesignConfig.spacingSm),
                  Expanded(
                      child: _ActionCard(
                          title: 'Leaderboard',
                          subtitle: 'Top players',
                          icon: Icons.leaderboard_outlined,
                          onTap: () => context.go('/leaderboard'))),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 350.ms).slideY(
                  begin: 0.03,
                  delay: 400.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: DesignConfig.spacing2xl),
              Text(
                'Upcoming Matches',
                style: AppTextStyles.sectionTitle,
              ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
              const SizedBox(height: DesignConfig.spacingMd),
              BlocBuilder<LobbyListBloc, LobbyListState>(
                builder: (context, state) {
                  if (state is LobbyListLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.neonGreen),
                    );
                  }
                  if (state is LobbyListLoaded) {
                    final lobbies = state.lobbies;
                    if (lobbies.isEmpty) {
                      return EmptyUpcomingMatches(
                          onFindMatch: () => context.go('/lobbies'));
                    }
                    return Column(
                      children: lobbies
                          .map((lobby) => Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: LobbyCard(lobby: lobby),
                              ))
                          .toList(),
                    );
                  }
                  if (state is LobbyListError) {
                    return Text(
                      'Failed to load matches: ${state.message}',
                      style: AppTextStyles.bodySecondary,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ).animate().fadeIn(delay: 500.ms, duration: 350.ms).slideY(
                  begin: 0.05,
                  delay: 500.ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic),
              const SizedBox(height: DesignConfig.spacing2xl),
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
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: DesignConfig.spacingXl),
          decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: DesignConfig.spacingMd),
              Text(title,
                  style: AppTextStyles.bodySecondaryStrong
                      .copyWith(color: AppColors.textPrimary)),
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
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
        child: Container(
          padding: const EdgeInsets.all(DesignConfig.spacingXl),
          decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.neonGreen, size: 24),
              const SizedBox(height: DesignConfig.spacingMd),
              Text(title, style: AppTextStyles.cardTitle.copyWith(height: 1.2)),
              const SizedBox(height: DesignConfig.spacingXs),
              Text(subtitle, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
