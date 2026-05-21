import 'package:flutter/material.dart';
import 'package:beesports/app/app_colors.dart';

enum TransactionType {
  topUp('Top Up', Icons.add_circle, AppColors.success),
  depositHold('Deposit Hold', Icons.lock, AppColors.accentTeal),
  depositRelease('Deposit Release', Icons.lock_open, AppColors.info),
  depositForfeit('Deposit Forfeit', Icons.money_off, AppColors.sale),
  refund('Withdraw', Icons.remove_circle, AppColors.sale);

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
      this == TransactionType.depositRelease;

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
