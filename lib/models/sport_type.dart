import 'package:beesports/app/app_theme.dart';
import 'package:flutter/material.dart';

enum SportType {
  futsal('Futsal', Icons.sports_soccer, AppColors.futsal),
  basketball('Basketball', Icons.sports_basketball, AppColors.basketball),
  badminton('Badminton', Icons.sports_tennis, AppColors.badminton),
  volleyball('Volleyball', Icons.sports_volleyball, AppColors.volleyball);

  final String label;
  final IconData icon;
  final Color color;

  const SportType(this.label, this.icon, this.color);

  static SportType? fromString(String value) {
    try {
      return SportType.values.firstWhere(
        (s) => s.name == value,
      );
    } catch (_) {
      return null;
    }
  }
}

