import 'package:flutter/material.dart';

/// BeeSports design system colors.
///
/// Semantic naming convention:
/// - `background` / `surface*` — scaffold & card fills
/// - `textPrimary` / `textSecondary` — text hierarchy
/// - `onAccent` — text drawn on top of accent (neonGreen) surfaces
/// - `accent` / `neonGreen` — primary brand accent
/// - `divider` / `border` — structural lines
class AppColors {
  AppColors._();

  // ── Core surfaces ──────────────────────────────────────────────
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF252547);
  static const Color surfaceVariant = Color(0xFF252547);

  // ── Brand accent ───────────────────────────────────────────────
  static const Color neonGreen = Color(0xFF76FF03);
  static const Color neonGreenDim = Color(0xFF5BC800);
  static const Color accent = Color(0xFFFF9100);

  // ── Text hierarchy ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF8888A0);
  static const Color onAccent = Color(0xFF111111);

  // ── Legacy aliases (map to new names for backward compat) ──────
  static const Color ink = background;
  static const Color onPrimary = onAccent;
  static const Color canvas = background;
  static const Color softCloud = surface;
  static const Color charcoal = textPrimary;
  static const Color ash = Color(0xFFB0B0C0);
  static const Color mute = textSecondary;
  static const Color stone = Color(0xFF5E5E78);

  // ── Borders & dividers ─────────────────────────────────────────
  static const Color divider = Color(0xFF35355A);
  static const Color border = Color(0xFF35355A);
  static const Color hairline = Color(0xFF35355A);
  static const Color hairlineSoft = Color(0xFF2A2A4A);

  // ── Semantic status colors ─────────────────────────────────────
  static const Color sale = Color(0xFFFF4444);
  static const Color saleDeep = Color(0xFFCC0000);
  static const Color success = Color(0xFF76FF03);
  static const Color successBright = Color(0xFF9EFF57);
  static const Color info = Color(0xFFFF9100);
  static const Color infoDeep = Color(0xFFE07D00);
  static const Color error = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFB300);

  // ── Decorative accents ─────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color accentPink = Color(0xFFFF2D78);
  static const Color accentPinkSoft = Color(0xFFFF6BA0);
  static const Color accentPurpleSoft = Color(0xFFBB86FC);
  static const Color accentPurplePale = Color(0xFFD4B8FF);
  static const Color accentTeal = Color(0xFF00E5FF);
  static const Color accentPinkDeep = Color(0xFFCC1560);

  // ── Sport colors ───────────────────────────────────────────────
  static const Color futsal = Color(0xFF76FF03);
  static const Color basketball = Color(0xFFFF9100);
  static const Color badminton = Color(0xFF00E5FF);
  static const Color volleyball = Color(0xFFBB86FC);
  static const Color tennis = Color(0xFFFFE600);
  static const Color tableTennis = Color(0xFFFF2D78);

  // ── Navigation ─────────────────────────────────────────────────
  static const Color navBar = Color(0xFF12122A);
  static const Color navSelected = neonGreen;
  static const Color navUnselected = textSecondary;

  // ── Glass effects ──────────────────────────────────────────────
  static const Color glassBg = Color(0xCC1A1A2E);
  static const Color glassBorder = Color(0x3376FF03);
}
