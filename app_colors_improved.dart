import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Color - Professional teal (instead of harsh neon green)
  static const Color primary = Color(0xFF00D9FF);
  static const Color onPrimary = Color(0xFF0A1F2E);
  static const Color primaryActive = Color(0xFF26E8FF);
  static const Color primaryNeutral = Color(0xFF009DB3);
  static const Color primaryPale = Color(0xFF061A24);

  // Neutrals - Dark theme foundation
  static const Color canvas = Color(0xFF0F1419);
  static const Color canvasSoft = Color(0xFF1A1F2B);

  static const Color ink = Color(0xFFE8E8F0);
  static const Color inkDeep = Color(0xFFFFFFFF);
  static const Color body = Color(0xFF8888A0);
  static const Color mute = Color(0xFF5E5E78);

  // Status Colors
  static const Color positive = Color(0xFF4CAF50);
  static const Color positiveDeep = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningDeep = Color(0xFFE65100);
  static const Color warningContent = Color(0xFFFFB74D);

  static const Color negative = Color(0xFFEF5350);
  static const Color negativeDeep = Color(0xFFC62828);
  static const Color negativeDarkest = Color(0xFF880000);
  static const Color negativeBg = Color(0xFF2C0B0B);

  // Accent - Keep one accent instead of multiple
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentCyan = Color(0xFF00D9FF);

  // Semantic Aliases
  static const Color background = canvasSoft;
  static const Color surface = canvas;
  static const Color surfaceVariant = canvasSoft;
  static const Color neonGreen = Color(0xFF4CAF50); // Softer green for accents
  static const Color accent = accentCyan;

  static const Color textPrimary = ink;
  static const Color textSecondary = body;
  static const Color onAccent = onPrimary;

  static const Color divider = Color(0xFF2A3544);
  static const Color border = mute;
  static const Color hairline = Color(0xFF2A3544);
  static const Color hairlineSoft = Color(0xFF1F2937);

  static const Color success = positive;
  static const Color error = negative;
  static const Color softCloud = canvasSoft;
  static const Color info = accentCyan;
  static const Color accentTeal = accentCyan;
  static const Color sale = negative;

  // Navigation
  static const Color navBar = Color(0xFF0A0F1A);
  static const Color navSelected = primary;
  static const Color navUnselected = body;
  static const Color charcoal = ink;
  static const Color ash = Color(0xFFB0B0C0);
  static const Color stone = Color(0xFF5E5E78);

  // Glass Effect
  static const Color glassBg = Color(0xCC1A1F2B);
  static const Color glassBorder = Color(0x3300D9FF);

  // Sports Categories - Using the primary teal as base with muted variations
  static const Color futsal = Color(0xFF00D9FF); // Primary teal
  static const Color basketball = Color(0xFFFF9800); // Orange accent
  static const Color badminton = Color(0xFF4CAF50); // Green
  static const Color volleyball = Color(0xFFEF5350); // Red
  static const Color tennis = Color(0xFFFFB74D); // Amber
  static const Color tableTennis = Color(0xFF00D9FF); // Teal
}
