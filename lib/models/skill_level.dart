import 'package:flutter/material.dart';

enum SkillLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  pro('Pro');

  final String label;

  const SkillLevel(this.label);

  IconData get icon {
    switch (this) {
      case SkillLevel.beginner:
        return Icons.star_border;
      case SkillLevel.intermediate:
        return Icons.bolt;
      case SkillLevel.advanced:
        return Icons.local_fire_department;
      case SkillLevel.pro:
        return Icons.emoji_events;
    }
  }

  static SkillLevel? fromString(String value) {
    try {
      return SkillLevel.values.firstWhere((s) => s.name == value);
    } catch (_) {
      return null;
    }
  }
}
