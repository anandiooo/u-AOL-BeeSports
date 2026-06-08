import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beesports/app/app_theme.dart';

Future<bool?> showConfirmationSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  IconData? icon,
  bool isDestructive = false,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignConfig.roundedXl)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 48,
                  color: isDestructive ? AppColors.error : AppColors.neonGreen),
              const SizedBox(height: DesignConfig.spacingLg),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: DesignConfig.bodyLg.fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignConfig.spacingSm),
            Text(
              message,
              style: TextStyle(
                fontSize: DesignConfig.bodySm.fontSize,
                color: AppColors.mute,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignConfig.spacingXl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      side: const BorderSide(color: AppColors.hairline),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: DesignConfig.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isDestructive) {
                        HapticFeedback.heavyImpact();
                      } else {
                        HapticFeedback.mediumImpact();
                      }
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDestructive ? AppColors.error : AppColors.neonGreen,
                      foregroundColor:
                          isDestructive ? Colors.white : AppColors.onPrimary,
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

