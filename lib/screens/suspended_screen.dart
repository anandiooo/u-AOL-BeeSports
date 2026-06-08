import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuspendedScreen extends StatelessWidget {
  final String message;
  const SuspendedScreen({super.key, this.message = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
                DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: DesignConfig.spacingXl),
                Text(
                  'Account Suspended',
                  style: AppTextStyles.displayOutfit(typography: DesignConfig.displayXl, color: AppColors.error, letterSpacing: 2),
                ),
                const SizedBox(height: DesignConfig.spacingMd),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'Your account has been suspended due to repeated violations of our community guidelines. If you believe this is an error, please contact support.',
                  style: AppTextStyles.displayOutfit(typography: DesignConfig.bodyXs, color: AppColors.textSecondary, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignConfig.spacing2xl),
                Text(
                  'Contact: support@beesports.id',
                  style: AppTextStyles.displayOutfit(typography: DesignConfig.bodyXs, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: DesignConfig.spacing3xl),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: AppTextStyles.displayOutfit(typography: DesignConfig.bodyMdStrong, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


