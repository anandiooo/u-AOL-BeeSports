enum SkillLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  pro('Pro');

  final String label;

  const SkillLevel(this.label);

  String get emoji {
    switch (this) {
      case SkillLevel.beginner:
        return '🌱';
      case SkillLevel.intermediate:
        return '⚡';
      case SkillLevel.advanced:
        return '🔥';
      case SkillLevel.pro:
        return '🏆';
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
