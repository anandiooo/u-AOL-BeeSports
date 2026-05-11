import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletEntity> getWallet(String userId);

  Future<List<CreditTransactionEntity>> getTransactions(String userId);

  Future<void> topUp({
    required String userId,
    required double amount,
  });

  Future<void> holdDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<void> releaseDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<void> forfeitDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<void> withdraw({
    required String userId,
    required double amount,
  });
}
