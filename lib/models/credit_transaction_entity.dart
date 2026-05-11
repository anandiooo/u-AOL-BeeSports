import 'package:beesports/models/transaction_type.dart';
import 'package:equatable/equatable.dart';

class CreditTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final double? balanceAfter;
  final String? referenceId;
  final String description;
  final DateTime createdAt;

  const CreditTransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.balanceAfter,
    this.referenceId,
    this.description = '',
    required this.createdAt,
  });

  bool get isCredit => type.isCredit;

  factory CreditTransactionEntity.fromMap(Map<String, dynamic> map) {
    return CreditTransactionEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: TransactionType.fromString(map['type'] as String) ??
          TransactionType.topUp,
      amount: (map['amount'] as num).toDouble(),
      balanceAfter: (map['balance_after'] as num?)?.toDouble(),
      referenceId: map['reference_id'] as String?,
      description: (map['description'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        balanceAfter,
        referenceId,
        description,
        createdAt,
      ];
}
