import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';
import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/wallet_entity.dart';
import 'package:beesports/repos/wallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRepositoryImpl implements WalletRepository {
  final SupabaseClient _client;

  WalletRepositoryImpl(this._client);

  @override
  Future<Result<WalletEntity>> getWallet(String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('credit_wallets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        await _client.from('credit_wallets').insert({'user_id': userId});
        return WalletEntity(userId: userId);
      }

      return WalletEntity.fromMap(data);
    });
  }

  @override
  Future<Result<List<CreditTransactionEntity>>> getTransactions(
      String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('credit_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (data as List)
          .map((e) => CreditTransactionEntity.fromMap(e))
          .toList();
    });
  }

  @override
  Future<Result<void>> topUp({
    required String userId,
    required double amount,
  }) async {
    return withRetry(() async {
      final result = await getWallet(userId);
      final wallet = result.when(
          success: (w) => w,
          failure: (_) => throw Exception('Failed to get wallet'));
      final newBalance = wallet.balance + amount;

      await _client
          .from('credit_wallets')
          .update({'balance': newBalance}).eq('user_id', userId);

      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'top_up',
        'amount': amount,
        'balance_after': newBalance,
        'description': '',
      });
    });
  }

  @override
  Future<Result<void>> holdDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    return withRetry(() async {
      final result = await getWallet(userId);
      final wallet = result.when(
          success: (w) => w,
          failure: (_) => throw Exception('Failed to get wallet'));

      if (wallet.available < amount) {
        throw Exception('Insufficient balance. Please top up first.');
      }

      await _client.from('credit_wallets').update({
        'held': wallet.held + amount,
      }).eq('user_id', userId);

      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'deposit_hold',
        'amount': amount,
        'balance_after': wallet.balance,
        'reference_id': lobbyId,
        'description': '',
      });

      await _client
          .from('lobby_participants')
          .update({'deposit_held': true})
          .eq('lobby_id', lobbyId)
          .eq('user_id', userId);
    });
  }

  @override
  Future<Result<void>> releaseDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    return withRetry(() async {
      final result = await getWallet(userId);
      final wallet = result.when(
          success: (w) => w,
          failure: (_) => throw Exception('Failed to get wallet'));
      final newHeld = (wallet.held - amount).clamp(0, double.infinity);

      await _client.from('credit_wallets').update({
        'held': newHeld,
      }).eq('user_id', userId);

      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'deposit_release',
        'amount': amount,
        'balance_after': wallet.balance,
        'reference_id': lobbyId,
        'description': '',
      });
    });
  }

  @override
  Future<Result<void>> forfeitDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    return withRetry(() async {
      final result = await getWallet(userId);
      final wallet = result.when(
          success: (w) => w,
          failure: (_) => throw Exception('Failed to get wallet'));
      final newBalance = (wallet.balance - amount).clamp(0, double.infinity);
      final newHeld = (wallet.held - amount).clamp(0, double.infinity);

      await _client.from('credit_wallets').update({
        'balance': newBalance,
        'held': newHeld,
      }).eq('user_id', userId);

      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'deposit_forfeit',
        'amount': amount,
        'balance_after': newBalance,
        'reference_id': lobbyId,
        'description': '',
      });
    });
  }

  @override
  Future<Result<void>> withdraw({
    required String userId,
    required double amount,
  }) async {
    return withRetry(() async {
      final result = await getWallet(userId);
      final wallet = result.when(
          success: (w) => w,
          failure: (_) => throw Exception('Failed to get wallet'));

      if (wallet.available < amount) {
        throw Exception('Insufficient balance.');
      }

      final newBalance = wallet.balance - amount;

      await _client
          .from('credit_wallets')
          .update({'balance': newBalance}).eq('user_id', userId);

      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'type': 'refund',
        'amount': amount,
        'balance_after': newBalance,
        'description': '',
      });
    });
  }
}
