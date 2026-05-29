import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:beesports/app/app_colors.dart';

class EmptyLobbies extends StatelessWidget {
  final String? sportLabel;
  final VoidCallback onCreateTap;
  const EmptyLobbies({super.key, this.sportLabel, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_esports_outlined,
              size: 64, color: AppColors.mute.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            sportLabel == null
                ? 'No Lobbies Available'
                : 'No $sportLabel Lobbies',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to host a match!',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreateTap,
            child: const Text('Create Lobby'),
          ),
        ],
      ),
    );
  }
}

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.mute.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No Transactions Yet',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal),
            ),
            const SizedBox(height: 8),
            Text(
              'Your wallet history will appear here',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.mute.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'You\'re All Caught Up',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyUpcomingMatches extends StatelessWidget {
  final VoidCallback onFindMatch;
  const EmptyUpcomingMatches({super.key, required this.onFindMatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softCloud,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 32, color: AppColors.mute.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No upcoming matches',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onFindMatch,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Find a Match'),
          ),
        ],
      ),
    );
  }
}

class EmptyFriends extends StatelessWidget {
  const EmptyFriends({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: AppColors.mute.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No Friends Yet',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for users and add them!',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}

class EmptyMatches extends StatelessWidget {
  final VoidCallback onFindMatch;
  const EmptyMatches({super.key, required this.onFindMatch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_score_outlined,
              size: 64, color: AppColors.mute.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No Match History',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          Text(
            'Play your first match to see history!',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onFindMatch,
            child: const Text('Find Match'),
          ),
        ],
      ),
    );
  }
}
