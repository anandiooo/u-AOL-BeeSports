import 'package:beesports/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background, // Match theme background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / Logo
            Container(
              padding: const EdgeInsets.all(DesignConfig.spacingXl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.canvas,
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 64,
                color: AppColors.neonGreen,
              ),
            )
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms)
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white24),

            const SizedBox(height: DesignConfig.spacing2xl),

            // Text Logo
            Text(
              'BEESPORTS',
              style: textTheme.displayLarge?.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 4,
                height: 0.9,
              ),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),

          ],
        ),
      ),
    );
  }
}

