import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String userId;
  final double balance;
  final double held;
  final DateTime? updatedAt;

  const WalletEntity({
    required this.userId,
    this.balance = 0,
    this.held = 0,
    this.updatedAt,
  });

  double get available => balance - held;

  factory WalletEntity.fromMap(Map<String, dynamic> map) {
    return WalletEntity(
      userId: map['user_id'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      held: (map['held'] as num?)?.toDouble() ?? 0,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [userId, balance, held, updatedAt];
}
