enum ParticipantStatus {
  joined('Joined'),
  waitlisted('Waitlisted'),
  confirmed('Confirmed'),
  removed('Removed'),
  left('Left'),
  noShow('No Show');

  final String label;

  const ParticipantStatus(this.label);

  String get value {
    switch (this) {
      case ParticipantStatus.noShow:
        return 'no_show';
      default:
        return name;
    }
  }

  static ParticipantStatus? fromString(String value) {
    switch (value) {
      case 'joined':
        return ParticipantStatus.joined;
      case 'waitlisted':
        return ParticipantStatus.waitlisted;
      case 'confirmed':
        return ParticipantStatus.confirmed;
      case 'removed':
        return ParticipantStatus.removed;
      case 'left':
        return ParticipantStatus.left;
      case 'no_show':
        return ParticipantStatus.noShow;
      default:
        return null;
    }
  }
}
