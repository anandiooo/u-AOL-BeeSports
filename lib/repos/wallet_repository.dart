import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/wallet_entity.dart';
import 'package:beesports/core/result.dart';

abstract class WalletRepository {
  Future<Result<WalletEntity>> getWallet(String userId);

  Future<Result<List<CreditTransactionEntity>>> getTransactions(String userId);

  Future<Result<void>> topUp({
    required String userId,
    required double amount,
  });

  Future<Result<void>> holdDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<Result<void>> releaseDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<Result<void>> forfeitDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  });

  Future<Result<void>> withdraw({
    required String userId,
    required double amount,
  });
}
