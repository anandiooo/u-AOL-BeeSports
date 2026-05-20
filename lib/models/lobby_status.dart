import 'package:flutter/material.dart';
import 'package:beesports/app/app_colors.dart';

enum LobbyStatus {
  open('Open', AppColors.success),
  confirmed('Confirmed', AppColors.info),
  inProgress('In Progress', AppColors.accentTeal),
  finished('Finished', AppColors.stone),
  settled('Settled', AppColors.mute),
  cancelled('Cancelled', AppColors.sale);

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
