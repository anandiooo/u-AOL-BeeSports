import 'package:flutter/material.dart';

enum LobbyStatus {
  open('Open', Color(0xFF4CAF50)),
  confirmed('Confirmed', Color(0xFF42A5F5)),
  inProgress('In Progress', Color(0xFFFF9800)),
  finished('Finished', Color(0xFF9E9E9E)),
  settled('Settled', Color(0xFF78909C)),
  cancelled('Cancelled', Color(0xFFEF5350));

  final String label;
  final Color color;

  const LobbyStatus(this.label, this.color);

  String get value {
    switch (this) {
      case LobbyStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  static LobbyStatus? fromString(String value) {
    switch (value) {
      case 'open':
        return LobbyStatus.open;
      case 'confirmed':
        return LobbyStatus.confirmed;
      case 'in_progress':
        return LobbyStatus.inProgress;
      case 'finished':
        return LobbyStatus.finished;
      case 'settled':
        return LobbyStatus.settled;
      case 'cancelled':
        return LobbyStatus.cancelled;
      default:
        return null;
    }
  }
}
