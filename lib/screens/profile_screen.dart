import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/widgets/bottom_sheets.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/profile/edit')),
          IconButton(
              icon: const Icon(Icons.logout, color: AppColors.accentOrange),
              onPressed: _handleLogout),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) return const ShimmerProfileHeader();
          if (state is ProfileLoaded) return _buildProfile(state.profile);
          if (state is ProfileUpdateSuccess)
            return _buildProfile(state.profile);
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.mute),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: _loadProfile, child: const Text('Retry')),
                ],
              ),
            );
          }
          return const ShimmerProfileHeader();
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  child:
                      profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                          ? Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 96,
                              height: 96,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    (profile.fullName ?? 'U')[0].toUpperCase(),
                                    style: GoogleFonts.bebasNeue(
                                        fontSize: 40,
                                        color: AppColors.onPrimary),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                (profile.fullName ?? 'U')[0].toUpperCase(),
                                style: GoogleFonts.bebasNeue(
                                    fontSize: 40, color: AppColors.onPrimary),
                              ),
                            ),
                ),
              ),
            ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack),
            const SizedBox(height: 18),
            Text(
              profile.fullName ?? 'Unknown',
              style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal),
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute),
            ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.softCloud,
                    borderRadius: BorderRadius.circular(16)),
                child: Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: AppColors.charcoal,
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            ],
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                    icon: Icons.badge_outlined, label: profile.nim ?? 'N/A'),
                _InfoPill(
                    icon: Icons.location_on_outlined,
                    label: profile.campus ?? 'Unknown'),
                _InfoPill(
                    icon: Icons.shield_outlined,
                    label: profile.role.toUpperCase()),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
            const SizedBox(height: 48),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Statistics',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal)),
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
            const SizedBox(height: 18),
            Row(
              children: [
                _StatCard(
                    label: 'Elo Rating',
                    value: profile.eloRating.toString(),
                    icon: Icons.trending_up),
                const SizedBox(width: 8),
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
            const SizedBox(height: 8),
            Row(
              children: [
                _StatCard(
                    label: 'Matches',
                    value: profile.matchesPlayed.toString(),
                    icon: Icons.sports_esports_outlined),
                const SizedBox(width: 8),
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
            const SizedBox(height: 48),
            if (profile.sportPreferences.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Sports & Skills',
                    style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal)),
              ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
              const SizedBox(height: 18),
              ...profile.sportPreferences.asMap().entries.map((entry) {
                final index = entry.key;
                final sport = entry.value;
                final level = profile.skillLevels[sport];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                      color: AppColors.softCloud,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Icon(sport.icon, color: AppColors.neonGreen, size: 22),
                      const SizedBox(width: 14),
                      Text(sport.label,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.charcoal)),
                      const Spacer(),
                      if (level != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.neonGreen,
                              borderRadius: BorderRadius.circular(30)),
                          child: Text('${level.emoji} ${level.label}',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onPrimary)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.hairline)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.mute),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.neonGreen, size: 22),
            const SizedBox(height: 18),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                    height: 1.2)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mute)),
          ],
        ),
      ),
    );
  }
}
