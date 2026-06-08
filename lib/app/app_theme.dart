import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color yellow = Color(0xFFFFD54F);

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

  // ── Navigation ─────────────────────────────────────────────────
  static const Color navBar = Color(0xFF12122A);
  static const Color navSelected = neonGreen;
  static const Color navUnselected = textSecondary;

  // ── Glass effects ──────────────────────────────────────────────
  static const Color glassBg = Color(0xCC1A1A2E);
  static const Color glassBorder = Color(0x3376FF03);
}

class DesignTypography {
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final double? letterSpacing;

  const DesignTypography({
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    this.letterSpacing,
  });

  TextStyle get style => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight / fontSize,
        letterSpacing: letterSpacing,
      );
}

class DesignComponentConfig {
  final DesignTypography typography;
  final double? rounded;
  final EdgeInsets? padding;

  const DesignComponentConfig({
    required this.typography,
    this.rounded,
    this.padding,
  });
}

class DesignConfig {
  DesignConfig._();

  // ─── Typography ──────────────────────────────────────────────────────────
  static const displayMega = DesignTypography(
      fontSize: 126, fontWeight: FontWeight.w900, lineHeight: 107.1);
  static const displayXxl = DesignTypography(
      fontSize: 96, fontWeight: FontWeight.w900, lineHeight: 81.6);
  static const displayXl = DesignTypography(
      fontSize: 64, fontWeight: FontWeight.w900, lineHeight: 54.4);
  static const displayLg = DesignTypography(
      fontSize: 47,
      fontWeight: FontWeight.w400,
      lineHeight: 70.5,
      letterSpacing: -0.108);
  static const displayMd = DesignTypography(
      fontSize: 40, fontWeight: FontWeight.w900, lineHeight: 34);
  static const displaySm = DesignTypography(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      lineHeight: 38.4,
      letterSpacing: -0.96);
  static const displayXs = DesignTypography(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      lineHeight: 31.2,
      letterSpacing: -0.48);
  static const bodyLg = DesignTypography(
      fontSize: 20, fontWeight: FontWeight.w400, lineHeight: 30);
  static const bodyMd = DesignTypography(
      fontSize: 16, fontWeight: FontWeight.w400, lineHeight: 24);
  static const bodyMdStrong = DesignTypography(
      fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 24);
  static const bodySm = DesignTypography(
      fontSize: 14, fontWeight: FontWeight.w400, lineHeight: 20);
  static const bodySmStrong = DesignTypography(
      fontSize: 14, fontWeight: FontWeight.w600, lineHeight: 20);
  static const caption = DesignTypography(
      fontSize: 12, fontWeight: FontWeight.w400, lineHeight: 16);
  static const captionSm = DesignTypography(
      fontSize: 10, fontWeight: FontWeight.w400, lineHeight: 14);
  static const captionMd = DesignTypography(
      fontSize: 11, fontWeight: FontWeight.w500, lineHeight: 15);
  static const bodyXs = DesignTypography(
      fontSize: 13, fontWeight: FontWeight.w400, lineHeight: 18);
  static const titleMd = DesignTypography(
      fontSize: 20, fontWeight: FontWeight.w600, lineHeight: 28);
  static const displayXxs = DesignTypography(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      lineHeight: 22,
      letterSpacing: -0.36);
  static const buttonMd = DesignTypography(
      fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 24);

  // ─── Rounded ─────────────────────────────────────────────────────────────
  static const double roundedNone = 0;
  static const double roundedXs = 4;
  static const double roundedSm = 8;
  static const double roundedMd = 12;
  static const double roundedLg = 16;
  static const double roundedXl = 24;
  static const double rounded2xl = 32;
  static const double roundedPill = 9999;
  static const double roundedFull = 9999;

  // ─── Spacing ─────────────────────────────────────────────────────────────
  static const double spacingXxs = 2;
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacing2xl = 32;
  static const double spacing3xl = 48;

  // ─── Components ──────────────────────────────────────────────────────────
  static const navBar = DesignComponentConfig(
    typography: bodySmStrong,
    padding: EdgeInsets.symmetric(vertical: spacingMd, horizontal: spacingXl),
  );

  static const navLink = DesignComponentConfig(
    typography: bodySmStrong,
  );

  static const buttonPrimary = DesignComponentConfig(
    typography: buttonMd,
    rounded: roundedXl,
    padding: EdgeInsets.symmetric(vertical: spacingMd, horizontal: spacingXl),
  );

  static const buttonSecondary = DesignComponentConfig(
    typography: buttonMd,
    rounded: roundedXl,
    padding: EdgeInsets.symmetric(vertical: spacingMd, horizontal: spacingXl),
  );

  static const buttonTertiary = DesignComponentConfig(
    typography: buttonMd,
    rounded: roundedXl,
    padding: EdgeInsets.symmetric(vertical: spacingMd, horizontal: spacingXl),
  );

  static const buttonIconCircular = DesignComponentConfig(
    typography: buttonMd, // Placeholder since it's an icon
    rounded: roundedFull,
    padding: EdgeInsets.all(spacingSm),
  );

  static const textInput = DesignComponentConfig(
    typography: bodyMd,
    rounded: roundedMd,
    padding: EdgeInsets.symmetric(vertical: spacingMd, horizontal: spacingLg),
  );

  static const cardContent = DesignComponentConfig(
    typography: bodyMd,
    rounded: roundedXl,
    padding: EdgeInsets.all(spacingXl),
  );

  static const heroBand = DesignComponentConfig(
    typography: displayMega,
    padding: EdgeInsets.symmetric(vertical: spacing3xl, horizontal: spacingXl),
  );

  static const contentBand = DesignComponentConfig(
    typography: displayMd,
    padding: EdgeInsets.symmetric(vertical: spacing3xl, horizontal: spacingXl),
  );

  static const badgePositive = DesignComponentConfig(
    typography: bodySmStrong,
    rounded: roundedPill,
    padding: EdgeInsets.symmetric(vertical: spacingXs, horizontal: spacingMd),
  );

  static const footer = DesignComponentConfig(
    typography: bodySm,
    padding: EdgeInsets.symmetric(vertical: spacing3xl, horizontal: spacingXl),
  );
}

/// Semantic text styles — use these in screens for consistent font size & color.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter(
    DesignTypography typography, {
    required Color color,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      textStyle: typography.style,
      color: color,
      fontWeight: fontWeight,
      height: height != null ? height / typography.fontSize : null,
      letterSpacing: letterSpacing,
    );
  }

  // ── App bar & section headers ──────────────────────────────────
  static TextStyle get appBarTitle => _inter(
        DesignConfig.displayXs,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get sectionTitle => appBarTitle;

  // ── Primary text hierarchy ─────────────────────────────────────
  static TextStyle get body => _inter(DesignConfig.bodyMd, color: AppColors.textPrimary);

  static TextStyle get bodyStrong =>
      _inter(DesignConfig.bodyMdStrong, color: AppColors.textPrimary);

  static TextStyle get bodySecondary =>
      _inter(DesignConfig.bodySm, color: AppColors.textSecondary);

  static TextStyle get bodySecondaryStrong => _inter(
        DesignConfig.bodySm,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption =>
      _inter(DesignConfig.caption, color: AppColors.textSecondary);

  static TextStyle get captionStrong => _inter(
        DesignConfig.caption,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      );

  // ── Accent variants ────────────────────────────────────────────
  static TextStyle get accentBody => _inter(
        DesignConfig.bodyMd,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get accentLabel => _inter(
        DesignConfig.bodySm,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get accentCaption => _inter(
        DesignConfig.caption,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get link => accentLabel;

  static TextStyle get linkUnderlined =>
      link.copyWith(decoration: TextDecoration.underline);

  static TextStyle get sectionTitleSpaced =>
      sectionTitle.copyWith(letterSpacing: 3);

  static TextStyle get bodySecondaryItalic =>
      bodySecondary.copyWith(fontStyle: FontStyle.italic, height: 1.5);

  static TextStyle get profileName => _inter(
        DesignConfig.displayXs,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle notificationBody({required bool isRead}) => _inter(
        DesignConfig.bodySm,
        color: AppColors.textPrimary,
        fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
      );

  static TextStyle selectionLabel({required bool selected}) => _inter(
        DesignConfig.bodySm,
        color: selected ? AppColors.onAccent : AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  // ── On-accent (badges, filled buttons) ─────────────────────────
  static TextStyle get onAccent => _inter(
        DesignConfig.caption,
        color: AppColors.onAccent,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get onAccentBody => _inter(
        DesignConfig.bodySm,
        color: AppColors.onAccent,
        fontWeight: FontWeight.w500,
      );

  // ── Display / hero ─────────────────────────────────────────────
  static TextStyle get displayHero => _inter(
        DesignConfig.displayLg,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get displayStat => _inter(
        DesignConfig.displayXxs,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get userName => _inter(
        DesignConfig.displayXxs,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get greeting => _inter(
        DesignConfig.bodySm,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      );

  // ── Card & list items ──────────────────────────────────────────
  static TextStyle get cardTitle => _inter(
        DesignConfig.bodyMd,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get cardSubtitle =>
      _inter(DesignConfig.bodySm, color: AppColors.textSecondary);

  static TextStyle get listTitle => cardTitle;

  static TextStyle get listSubtitle => cardSubtitle;

  // ── Error / status ─────────────────────────────────────────────
  static TextStyle get error =>
      _inter(DesignConfig.bodySm, color: AppColors.error);

  static TextStyle get errorStrong => _inter(
        DesignConfig.bodySm,
        color: AppColors.error,
        fontWeight: FontWeight.w500,
      );

  // ── Form ───────────────────────────────────────────────────────
  static TextStyle get formLabel => _inter(
        DesignConfig.bodySmStrong,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get inputText =>
      _inter(DesignConfig.bodyMd, color: AppColors.textPrimary);

  static TextStyle get inputHint =>
      _inter(DesignConfig.bodyMd, color: AppColors.textSecondary);

  // ── Specialized ────────────────────────────────────────────────
  static TextStyle get emptyTitle => _inter(
        DesignConfig.titleMd,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get progressLabel =>
      _inter(DesignConfig.bodyXs, color: AppColors.textSecondary);

  static TextStyle get progressValue => _inter(
        DesignConfig.bodyXs,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get chatTimestamp =>
      _inter(DesignConfig.captionMd, color: AppColors.textSecondary);

  static TextStyle get chatMeta =>
      _inter(DesignConfig.captionSm, color: AppColors.textSecondary);

  static TextStyle get tabLabel => _inter(
        DesignConfig.bodySmStrong,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle bebas(
    DesignTypography typography, {
    Color color = AppColors.neonGreen,
    double? height,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.bebasNeue(
        fontSize: typography.fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  static TextStyle displayBebas({
    Color color = AppColors.onAccent,
    double? height,
  }) =>
      bebas(DesignConfig.displayXl, color: color, height: height);

  static TextStyle bangers(
    DesignTypography typography, {
    required Color color,
    FontWeight? fontWeight,
  }) =>
      GoogleFonts.bangers(
        fontSize: typography.fontSize,
        color: color,
        fontWeight: fontWeight,
      );

  static TextStyle displayOutfit({
    required DesignTypography typography,
    required Color color,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.outfit(
        fontSize: typography.fontSize,
        fontWeight: fontWeight ?? typography.fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme =
        GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.accentOrange,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onAccent,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          textStyle: DesignConfig.displayMega.style,
          color: AppColors.neonGreen,
        ),
        displayMedium: GoogleFonts.inter(
          textStyle: DesignConfig.displayXxl.style,
          color: AppColors.neonGreen,
        ),
        displaySmall: GoogleFonts.inter(
          textStyle: DesignConfig.displayXl.style,
          color: AppColors.neonGreen,
        ),
        headlineLarge: GoogleFonts.inter(
          textStyle: DesignConfig.displayLg.style,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          textStyle: DesignConfig.displayMd.style,
          color: AppColors.charcoal,
        ),
        headlineSmall: GoogleFonts.inter(
          textStyle: DesignConfig.displaySm.style,
          color: AppColors.charcoal,
        ),
        titleLarge: GoogleFonts.inter(
          textStyle: DesignConfig.displayXs.style,
          color: AppColors.charcoal,
        ),
        titleMedium: GoogleFonts.inter(
          textStyle: DesignConfig.bodyLg.style,
          color: AppColors.charcoal,
        ),
        titleSmall: GoogleFonts.inter(
          textStyle: DesignConfig.bodyMdStrong.style,
          color: AppColors.charcoal,
        ),
        bodyLarge: GoogleFonts.inter(
          textStyle: DesignConfig.bodyMd.style,
          color: AppColors.charcoal,
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: DesignConfig.bodySm.style,
          color: AppColors.charcoal,
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: DesignConfig.caption.style,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          textStyle: DesignConfig.buttonMd.style,
          color: AppColors.charcoal,
        ),
        labelMedium: GoogleFonts.inter(
          textStyle: DesignConfig.bodySmStrong.style,
          color: AppColors.charcoal,
        ),
        labelSmall: GoogleFonts.inter(
          textStyle: DesignConfig.caption.style,
          color: AppColors.mute,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.navBar.typography.style,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.cardContent.rounded ?? DesignConfig.roundedXl),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: DesignConfig.buttonPrimary.padding,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                DesignConfig.buttonPrimary.rounded ?? DesignConfig.roundedXl),
          ),
          textStyle: GoogleFonts.inter(
            textStyle: DesignConfig.buttonPrimary.typography.style,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          side: const BorderSide(color: AppColors.neonGreen),
          padding: DesignConfig.buttonSecondary.padding,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                DesignConfig.buttonSecondary.rounded ?? DesignConfig.roundedXl),
          ),
          textStyle: GoogleFonts.inter(
            textStyle: DesignConfig.buttonSecondary.typography.style,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          padding: DesignConfig.buttonTertiary.padding,
          textStyle: GoogleFonts.inter(
            textStyle: DesignConfig.buttonTertiary.typography.style,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.textInput.rounded ?? DesignConfig.roundedMd),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.textInput.rounded ?? DesignConfig.roundedMd),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.textInput.rounded ?? DesignConfig.roundedMd),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.textInput.rounded ?? DesignConfig.roundedMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              DesignConfig.textInput.rounded ?? DesignConfig.roundedMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: DesignConfig.textInput.padding,
        hintStyle:
            TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.neonGreen,
        labelStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodySmStrong.style,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConfig.roundedLg),
          side: const BorderSide(color: AppColors.hairline),
        ),
        side: const BorderSide(color: AppColors.hairline),
        padding: const EdgeInsets.symmetric(
            horizontal: DesignConfig.spacingLg, vertical: DesignConfig.spacingSm),
        showCheckmark: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: AppColors.navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConfig.roundedLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConfig.roundedMd)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConfig.roundedMd)),
        titleTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodyLg.style,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodyMd.style,
          color: AppColors.ash,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConfig.roundedMd)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonGreen,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConfig.roundedMd)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConfig.roundedMd)),
        hourMinuteTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.displayMd.style,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodyMdStrong.style,
        ),
        dialTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodyMd.style,
          fontWeight: FontWeight.w500,
        ),
        helpTextStyle: GoogleFonts.inter(
          textStyle: DesignConfig.bodySm.style,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.neonGreen,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.neonGreen,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return AppColors.stone;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neonGreen.withValues(alpha: 0.3);
          }
          return AppColors.hairline;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.textSecondary, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return AppColors.textSecondary;
        }),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),
    );
  }
}
