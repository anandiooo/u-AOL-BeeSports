import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/wallet_entity.dart';
import 'package:beesports/repos/wallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRepositoryImpl implements WalletRepository {
  final SupabaseClient _client;

  WalletRepositoryImpl(this._client);

  @override
  Future<WalletEntity> getWallet(String userId) async {
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
  }

  @override
  Future<List<CreditTransactionEntity>> getTransactions(String userId) async {
    final data = await _client
        .from('credit_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List)
        .map((e) => CreditTransactionEntity.fromMap(e))
        .toList();
  }

  @override
  Future<void> topUp({
    required String userId,
    required double amount,
  }) async {
    final wallet = await getWallet(userId);
    final newBalance = wallet.balance + amount;

    await _client
        .from('credit_wallets')
        .update({'balance': newBalance}).eq('user_id', userId);

    await _client.from('credit_transactions').insert({
      'user_id': userId,
      'type': 'top_up',
      'amount': amount,
      'balance_after': newBalance,
      'description': 'Top-up Rp${amount.toStringAsFixed(0)}',
    });
  }

  @override
  Future<void> holdDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    final wallet = await getWallet(userId);

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
      'description': 'Deposit held for lobby',
    });

    await _client
        .from('lobby_participants')
        .update({'deposit_held': true})
        .eq('lobby_id', lobbyId)
        .eq('user_id', userId);
  }

  @override
  Future<void> releaseDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    final wallet = await getWallet(userId);
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
      'description': 'Deposit released from lobby',
    });
  }

  @override
  Future<void> forfeitDeposit({
    required String userId,
    required String lobbyId,
    required double amount,
  }) async {
    final wallet = await getWallet(userId);
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
      'description': 'Deposit forfeited (no-show/penalty)',
    });
  }

  @override
  Future<void> withdraw({
    required String userId,
    required double amount,
  }) async {
    final wallet = await getWallet(userId);

    if (wallet.available < amount) {
      throw Exception('Insufficient available balance for withdrawal.');
    }

    final newBalance = wallet.balance - amount;

    await _client
        .from('credit_wallets')
        .update({'balance': newBalance}).eq('user_id', userId);

    await _client.from('credit_transactions').insert({
      'user_id': userId,
      'type': 'withdrawal',
      'amount': amount,
      'balance_after': newBalance,
      'description': 'Withdrawal Rp${amount.toStringAsFixed(0)}',
    });
  }
}
