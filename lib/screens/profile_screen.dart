import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondaryDark),
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
                style: GoogleFonts.inter(color: AppColors.primary),
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
          // Avatar — ink circle with white initial
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (profile.fullName ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  fontSize: 40,
                  color: AppColors.foursierLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            profile.fullName ?? 'Unknown',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.primaryLight,
            ),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.secondaryLight,
              ),
              child: Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.primaryDark,
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Info pills
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.badge_outlined,
                label: profile.nim ?? 'N/A',
              ),
              _InfoPill(
                icon: Icons.location_on_outlined,
                label: profile.campus ?? 'Unknown',
              ),
              _InfoPill(
                icon: Icons.shield_outlined,
                label: profile.role.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Statistics section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Statistics',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatCard(
                label: 'Elo Rating',
                value: profile.eloRating.toString(),
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Reliability',
                value: '${profile.reliabilityScore}%',
                icon: Icons.verified_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatCard(
                label: 'Matches',
                value: profile.matchesPlayed.toString(),
                icon: Icons.sports_esports_outlined,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Win Rate',
                value: '${profile.winRate.toStringAsFixed(0)}%',
                icon: Icons.emoji_events_outlined,
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Sports & Skills
          if (profile.sportPreferences.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sports & Skills',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...profile.sportPreferences.map((sport) {
              final level = profile.skillLevels[sport];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                ),
                child: Row(
                  children: [
                    Icon(sport.icon, color: AppColors.primary, size: 22),
                    const SizedBox(width: 14),
                    Text(
                      sport.label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.primary,
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${level.emoji} ${level.label}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foursierLight,
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

/// Info pill — canvas bg with hairline border, pill shape
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.foursier,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.foursierDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card — flat soft-cloud, no shadow, no elevation
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.secondaryLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 18),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
