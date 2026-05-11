import 'package:flutter/material.dart';

enum TransactionType {
  topUp('Top Up', Icons.add_circle, Color(0xFF4CAF50)),
  depositHold('Deposit Hold', Icons.lock, Color(0xFFFF9800)),
  depositRelease('Deposit Release', Icons.lock_open, Color(0xFF42A5F5)),
  depositForfeit('Deposit Forfeit', Icons.money_off, Color(0xFFEF5350)),
  refund('Refund', Icons.replay, Color(0xFF9C27B0));

  final String label;
  final IconData icon;
  final Color color;

  const TransactionType(this.label, this.icon, this.color);

  String get value {
    switch (this) {
      case TransactionType.topUp:
        return 'top_up';
      case TransactionType.depositHold:
        return 'deposit_hold';
      case TransactionType.depositRelease:
        return 'deposit_release';
      case TransactionType.depositForfeit:
        return 'deposit_forfeit';
      case TransactionType.refund:
        return 'refund';
    }
  }

  bool get isCredit =>
      this == TransactionType.topUp ||
      this == TransactionType.depositRelease ||
      this == TransactionType.refund;

  static TransactionType? fromString(String value) {
    switch (value) {
      case 'top_up':
        return TransactionType.topUp;
      case 'deposit_hold':
        return TransactionType.depositHold;
      case 'deposit_release':
        return TransactionType.depositRelease;
      case 'deposit_forfeit':
        return TransactionType.depositForfeit;
      case 'refund':
        return TransactionType.refund;
      default:
        return null;
    }
  }
}
