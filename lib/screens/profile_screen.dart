import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/widgets/bottom_sheets.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(authState.user.id));
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showConfirmationSheet(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of BeeSports?',
      confirmLabel: 'Sign Out',
      cancelLabel: 'Cancel',
      icon: Icons.logout_rounded,
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(SignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: DesignConfig.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(DesignConfig.spacingSm),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            padding:
                                const EdgeInsets.all(DesignConfig.spacingSm),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.textPrimary),
                            onPressed: () => context.push('/profile/edit')),
                        IconButton(
                            padding:
                                const EdgeInsets.all(DesignConfig.spacingSm),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.logout,
                                color: AppColors.accentOrange),
                            onPressed: _handleLogout),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading)
                      return const ShimmerProfileHeader();
                    if (state is ProfileLoaded)
                      return _buildProfile(state.profile);
                    if (state is ProfileUpdateSuccess) {
                      return _buildProfile(state.profile);
                    }
                    if (state is ProfileError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: DesignConfig.spacingMd),
                            Text(state.message),
                            const SizedBox(height: DesignConfig.spacingMd),
                            ElevatedButton(
                                onPressed: _loadProfile,
                                child: const Text('Retry')),
                          ],
                        ),
                      );
                    }
                    return const ShimmerProfileHeader();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(ProfileEntity profile) {
    return RefreshIndicator(
      color: AppColors.neonGreen,
      onRefresh: () async => _loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    color: AppColors.neonGreen, shape: BoxShape.circle),
                child: ClipOval(
                  child: profile.avatarUrl != null &&
                          profile.avatarUrl!.isNotEmpty
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 96,
                          height: 96,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                (profile.fullName ?? 'U')[0].toUpperCase(),
                                style: AppTextStyles.bebas(
                                    DesignConfig.displayMd,
                                    color: AppColors.onAccent),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            (profile.fullName ?? 'U')[0].toUpperCase(),
                            style: AppTextStyles.bebas(DesignConfig.displayMd,
                                color: AppColors.onAccent),
                          ),
                        ),
                ),
              ),
            ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack),
            const SizedBox(height: DesignConfig.spacingMd),
            Text(
              profile.fullName ?? '[N/A]',
              style: AppTextStyles.profileName,
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: DesignConfig.spacingMd),
            Text(
              profile.email,
              style: AppTextStyles.bodySecondary,
            ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: DesignConfig.spacingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignConfig.spacingMd,
                    vertical: DesignConfig.spacingMd),
                decoration: BoxDecoration(
                    color: AppColors.softCloud,
                    borderRadius:
                        BorderRadius.circular(DesignConfig.roundedXl)),
                child: Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondaryItalic,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            ],
            const SizedBox(height: DesignConfig.spacingMd),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                    icon: Icons.badge_outlined, label: profile.nim ?? 'N/A'),
                _InfoPill(
                    icon: Icons.location_on_outlined,
                    label: profile.campus ?? '[N/A]'),
                _InfoPill(
                    icon: Icons.shield_outlined,
                    label: profile.role.toUpperCase()),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
            const SizedBox(height: DesignConfig.spacing2xl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Statistics', style: AppTextStyles.sectionTitle),
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
            const SizedBox(height: DesignConfig.spacingMd),
            Row(
              children: [
                _StatCard(
                    label: 'Elo Rating',
                    value: profile.eloRating.toString(),
                    icon: Icons.trending_up),
                const SizedBox(width: DesignConfig.spacingSm),
                _StatCard(
                    label: 'Reliability',
                    value: '${profile.reliabilityScore}%',
                    icon: Icons.verified_outlined),
              ],
            ).animate().fadeIn(delay: 350.ms, duration: 350.ms).slideY(
                begin: 0.05,
                delay: 350.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic),
            const SizedBox(height: DesignConfig.spacingSm),
            Row(
              children: [
                _StatCard(
                    label: 'Matches',
                    value: profile.matchesPlayed.toString(),
                    icon: Icons.sports_esports_outlined),
                const SizedBox(width: DesignConfig.spacingSm),
                _StatCard(
                    label: 'Win Rate',
                    value: '${profile.winRate.toStringAsFixed(0)}%',
                    icon: Icons.emoji_events_outlined),
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 350.ms).slideY(
                begin: 0.05,
                delay: 400.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic),
            const SizedBox(height: DesignConfig.spacing2xl),
            if (profile.sportPreferences.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Text('Sports & Skills', style: AppTextStyles.sectionTitle),
              ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
              const SizedBox(height: DesignConfig.spacingMd),
              ...profile.sportPreferences.asMap().entries.map((entry) {
                final index = entry.key;
                final sport = entry.value;
                final level = profile.skillLevels[sport];
                return Container(
                  margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
                  padding: const EdgeInsets.all(DesignConfig.spacingXl),
                  decoration: BoxDecoration(
                      color: AppColors.softCloud,
                      borderRadius:
                          BorderRadius.circular(DesignConfig.roundedXl)),
                  child: Row(
                    children: [
                      Icon(sport.icon, color: AppColors.neonGreen, size: 22),
                      const SizedBox(width: DesignConfig.spacingMd),
                      Text(sport.label, style: AppTextStyles.cardTitle),
                      const Spacer(),
                      if (level != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DesignConfig.spacingMd,
                              vertical: DesignConfig.spacingSm),
                          decoration: BoxDecoration(
                              color: AppColors.neonGreen,
                              borderRadius: BorderRadius.circular(
                                  DesignConfig.rounded2xl)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(level.icon,
                                  size: 14, color: AppColors.onAccent),
                              const SizedBox(width: DesignConfig.spacingXs),
                              Text(level.label, style: AppTextStyles.onAccent),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: (500 + 60 * index).ms,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic)
                    .slideX(
                        begin: 0.05,
                        delay: (500 + 60 * index).ms,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic);
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingMd),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
          border: Border.all(color: AppColors.hairline)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: DesignConfig.spacingMd),
          Text(label,
              style: AppTextStyles.bodySecondaryStrong
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DesignConfig.spacingXl),
        decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(DesignConfig.roundedXl)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.neonGreen, size: 22),
            const SizedBox(height: DesignConfig.spacingMd),
            Text(value, style: AppTextStyles.displayStat.copyWith(height: 1.2)),
            const SizedBox(height: DesignConfig.spacingMd),
            Text(label, style: AppTextStyles.bodySecondaryStrong),
          ],
        ),
      ),
    );
  }
}
