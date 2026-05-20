import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:beesports/app/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double radiusNone = 0;
  static const double radiusSm = 18;
  static const double radiusMd = 24;
  static const double radiusLg = 30;
  static const double radiusFull = 9999;

  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 18;
  static const double spaceXl = 24;
  static const double spaceXxl = 30;
  static const double spaceSection = 48;

  static ThemeData get darkTheme => lightTheme;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.accentOrange,
        surface: AppColors.softCloud,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.charcoal,
        onSurface: AppColors.charcoal,
        onError: AppColors.charcoal,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.bebasNeue(
          fontSize: 96,
          fontWeight: FontWeight.w500,
          height: 0.9,
          letterSpacing: 0,
          color: AppColors.neonGreen,
        ),
        displayMedium: GoogleFonts.bebasNeue(
          fontSize: 64,
          fontWeight: FontWeight.w500,
          height: 0.9,
          color: AppColors.neonGreen,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: AppColors.charcoal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: AppColors.charcoal,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.75,
          color: AppColors.charcoal,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: AppColors.charcoal,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.mute,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.charcoal,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.mute,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.charcoal,
        ),
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.softCloud,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          side: const BorderSide(color: AppColors.neonGreen),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softCloud,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.mute.withValues(alpha: 0.7)),
        prefixIconColor: AppColors.mute,
        suffixIconColor: AppColors.mute,
        labelStyle: const TextStyle(color: AppColors.mute),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softCloud,
        selectedColor: AppColors.neonGreen,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.hairline),
        ),
        side: const BorderSide(color: AppColors.hairline),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.softCloud,
        contentTextStyle: GoogleFonts.inter(color: AppColors.charcoal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.softCloud,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.charcoal,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.ash,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.softCloud,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonGreen,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.softCloud,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.softCloud,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.neonGreen,
        unselectedLabelColor: AppColors.mute,
        indicatorColor: AppColors.neonGreen,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return AppColors.stone;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen.withValues(alpha: 0.3);
          return AppColors.hairline;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.mute, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonGreen;
          return AppColors.mute;
        }),
      ),
      iconTheme: const IconThemeData(color: AppColors.charcoal),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.charcoal,
        iconColor: AppColors.mute,
      ),
    );
  }
}
