import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/wallet_entity.dart';
import 'package:beesports/repos/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  final String userId;
  const LoadWallet(this.userId);
  @override
  List<Object?> get props => [userId];
}

class TopUpRequested extends WalletEvent {
  final String userId;
  final double amount;
  const TopUpRequested({required this.userId, required this.amount});
  @override
  List<Object?> get props => [userId, amount];
}

class WithdrawRequested extends WalletEvent {
  final String userId;
  final double amount;
  const WithdrawRequested({required this.userId, required this.amount});
  @override
  List<Object?> get props => [userId, amount];
}

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final List<CreditTransactionEntity> transactions;
  const WalletLoaded({required this.wallet, required this.transactions});
  @override
  List<Object?> get props => [wallet, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

class TopUpSuccess extends WalletState {
  final double amount;
  const TopUpSuccess(this.amount);
  @override
  List<Object?> get props => [amount];
}

class WithdrawSuccess extends WalletState {
  final double amount;
  const WithdrawSuccess(this.amount);
  @override
  List<Object?> get props => [amount];
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletInitial()) {
    on<LoadWallet>(_onLoad);
    on<TopUpRequested>(_onTopUp);
    on<WithdrawRequested>(_onWithdraw);
  }

  Future<void> _onLoad(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final wallet = await _walletRepository.getWallet(event.userId);
      final transactions =
          await _walletRepository.getTransactions(event.userId);
      emit(WalletLoaded(wallet: wallet, transactions: transactions));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onTopUp(
    TopUpRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await _walletRepository.topUp(
        userId: event.userId,
        amount: event.amount,
      );
      emit(TopUpSuccess(event.amount));
      add(LoadWallet(event.userId));
    } catch (e, st) {
      debugPrint('WalletBloc._onTopUp error: $e\n$st');
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onWithdraw(
    WithdrawRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await _walletRepository.withdraw(
        userId: event.userId,
        amount: event.amount,
      );
      emit(WithdrawSuccess(event.amount));
      add(LoadWallet(event.userId));
    } catch (e, st) {
      debugPrint('WalletBloc._onWithdraw error: $e\n$st');
      emit(WalletError(e.toString()));
    }
  }
}
