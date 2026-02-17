import 'package:flutter/material.dart';

enum SportType {
  futsal('Futsal', Icons.sports_soccer, Color(0xFF66BB6A)),
  basketball('Basketball', Icons.sports_basketball, Color(0xFFEF5350)),
  badminton('Badminton', Icons.sports_tennis, Color(0xFF42A5F5)),
  volleyball('Volleyball', Icons.sports_volleyball, Color(0xFFAB47BC)),
  tennis('Tennis', Icons.sports_tennis, Color(0xFFFFEE58)),
  tableTennis('Table Tennis', Icons.sports_cricket, Color(0xFF26C6DA));

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
