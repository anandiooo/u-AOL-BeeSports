import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => context.read<AuthBloc>().add(SignOutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileLoaded) {
            return _buildProfile(state.profile);
          }
          if (state is ProfileUpdateSuccess) {
            return _buildProfile(state.profile);
          }
          if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.textPrimaryDark),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildProfile(ProfileEntity profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (profile.fullName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName ?? 'Unknown',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryDark.withValues(alpha: 0.6),
            ),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
              ),
              child: Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimaryDark.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                icon: Icons.badge_outlined,
                label: profile.nim ?? 'N/A',
              ),
              _InfoChip(
                icon: Icons.location_on_outlined,
                label: profile.campus ?? 'Unknown',
              ),
              _InfoChip(
                icon: Icons.shield_outlined,
                label: profile.role.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BentoStat(
                label: 'Elo Rating',
                value: profile.eloRating.toString(),
                icon: Icons.trending_up,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _BentoStat(
                label: 'Reliability',
                value: '${profile.reliabilityScore}%',
                icon: Icons.verified_outlined,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BentoStat(
                label: 'Matches',
                value: profile.matchesPlayed.toString(),
                icon: Icons.sports_esports_outlined,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 16),
              _BentoStat(
                label: 'Win Rate',
                value: '${profile.winRate.toStringAsFixed(0)}%',
                icon: Icons.emoji_events_outlined,
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (profile.sportPreferences.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sports & Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...profile.sportPreferences.map((sport) {
              final level = profile.skillLevels[sport];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(sport.icon, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      sport.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const Spacer(),
                    if (level != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${level.emoji} ${level.label}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: AppColors.textPrimaryDark.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDark.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BentoStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
