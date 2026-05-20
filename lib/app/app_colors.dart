import 'package:flutter/material.dart';

/// Sporty Neon Green design system colors.
/// Primary: Neon Green (#76FF03) on Dark Charcoal (#1A1A2E).
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // Brand & Core
  // ──────────────────────────────────────────────
  static const Color ink = Color(0xFF1A1A2E);          // Dark Charcoal background
  static const Color onPrimary = Color(0xFF111111);     // Dark text on neon buttons
  static const Color canvas = Color(0xFF1A1A2E);        // Main background
  static const Color softCloud = Color(0xFF252547);     // Elevated surface / card bg

  // Neon primary
  static const Color neonGreen = Color(0xFF76FF03);     // Primary brand color
  static const Color neonGreenDim = Color(0xFF5BC800);  // Pressed / darker variant

  // ──────────────────────────────────────────────
  // Text hierarchy (on dark backgrounds)
  // ──────────────────────────────────────────────
  static const Color charcoal = Color(0xFFE8E8F0);     // Primary text (off-white)
  static const Color ash = Color(0xFFB0B0C0);           // Slightly muted text
  static const Color mute = Color(0xFF8888A0);          // Secondary / subtitle text
  static const Color stone = Color(0xFF5E5E78);         // Low-emphasis text

  // ──────────────────────────────────────────────
  // Dividers & borders
  // ──────────────────────────────────────────────
  static const Color hairline = Color(0xFF35355A);      // Subtle divider on dark bg
  static const Color hairlineSoft = Color(0xFF2A2A4A);  // Very subtle divider

  // ──────────────────────────────────────────────
  // Semantic
  // ──────────────────────────────────────────────
  static const Color sale = Color(0xFFFF4444);          // Error / destructive red
  static const Color saleDeep = Color(0xFFCC0000);      // Deeper red
  static const Color success = Color(0xFF76FF03);       // Success = neon green
  static const Color successBright = Color(0xFF9EFF57); // Brighter success
  static const Color info = Color(0xFFFF9100);          // Info = orange accent
  static const Color infoDeep = Color(0xFFE07D00);      // Deeper orange
  static const Color error = Color(0xFFFF4444);         // Error red
  static const Color warning = Color(0xFFFFB300);       // Warning amber

  // ──────────────────────────────────────────────
  // Accent — secondary accent (orange)
  // ──────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFF9100);  // Secondary accent
  static const Color accentPink = Color(0xFFFF2D78);    // Table Tennis / hot pink
  static const Color accentPinkSoft = Color(0xFFFF6BA0); // Softer pink
  static const Color accentPurpleSoft = Color(0xFFBB86FC); // Volleyball purple
  static const Color accentPurplePale = Color(0xFFD4B8FF); // Pale purple
  static const Color accentTeal = Color(0xFF00E5FF);    // Badminton cyan
  static const Color accentPinkDeep = Color(0xFFCC1560); // Deep pink

  // ──────────────────────────────────────────────
  // Sport colors — unique neon per sport
  // ──────────────────────────────────────────────
  static const Color futsal = Color(0xFF76FF03);        // Neon Green
  static const Color basketball = Color(0xFFFF9100);    // Orange
  static const Color badminton = Color(0xFF00E5FF);     // Cyan
  static const Color volleyball = Color(0xFFBB86FC);    // Purple
  static const Color tennis = Color(0xFFFFE600);        // Yellow
  static const Color tableTennis = Color(0xFFFF2D78);   // Pink

  // ──────────────────────────────────────────────
  // Navigation
  // ──────────────────────────────────────────────
  static const Color navBar = Color(0xFF12122A);        // Bottom nav background
  static const Color navSelected = neonGreen;           // Selected nav item
  static const Color navUnselected = mute;              // Unselected nav item

  // ──────────────────────────────────────────────
  // Glass effect helpers
  // ──────────────────────────────────────────────
  static const Color glassBg = Color(0xCC1A1A2E);       // 80% opacity dark charcoal
  static const Color glassBorder = Color(0x3376FF03);    // 20% neon green border

  // ──────────────────────────────────────────────
  // Legacy aliases for backward compatibility
  // ──────────────────────────────────────────────
  // "primary" was the old ink-black — used as main text color AND dark bg color
  // for hero tiles, avatar circles, selected chips, etc.
  // In the new dark theme, we use neonGreen for these accents.
  static const Color primary = neonGreen;

  // "primaryLight" was subtler text (charcoal/muted) — now muted lavender
  static const Color primaryLight = mute;

  // "primaryDark" — bio text, similar emphasis to primary
  static const Color primaryDark = charcoal;

  // "accent" — secondary accent color
  static const Color accent = accentOrange;

  // Background surfaces
  static const Color backgroundDark = canvas;
  static const Color surfaceDark = softCloud;
  static const Color cardDark = softCloud;

  static const Color backgroundLight = canvas;
  static const Color surfaceLight = softCloud;
  static const Color cardLight = softCloud;

  // Text colors
  static const Color textPrimaryDark = charcoal;
  static const Color textSecondaryDark = mute;
  static const Color textPrimaryLight = charcoal;
  static const Color textSecondaryLight = mute;

  // Legacy palette aliases still referenced throughout the app UI.
  // "secondary" was success green — now orange accent for visual identity
  static const Color secondary = neonGreen;

  // "secondaryLight" was used as soft card backgrounds — now softCloud
  static const Color secondaryLight = softCloud;

  // "secondaryDark" was used for notification badges, logout icons — now orange
  static const Color secondaryDark = accentOrange;

  // "tersierDark" — error snackbar backgrounds
  static const Color tersierDark = error;

  // "tersierLight" — inactive indicators, borders, dividers
  static const Color tersierLight = hairline;

  // "foursier" — the main scaffold/canvas background
  static const Color foursier = canvas;

  // "foursierLight" — text/icons on primary-colored (neon green) backgrounds
  static const Color foursierLight = onPrimary;

  // "foursierDark" — unselected chip borders
  static const Color foursierDark = hairline;
}
