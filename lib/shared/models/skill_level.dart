enum SkillLevel {
  beginner('Beginner', '🟢', 'Just starting out'),
  intermediate('Intermediate', '🟡', 'Play regularly'),
  advanced('Advanced', '🔴', 'Competitive level');

  final String label;
  final String emoji;
  final String description;

  const SkillLevel(this.label, this.emoji, this.description);

  static SkillLevel? fromString(String value) {
    try {
      return SkillLevel.values.firstWhere((s) => s.name == value);
    } catch (_) {
      return null;
    }
  }
}
