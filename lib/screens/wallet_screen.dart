import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  void _loadWallet() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<WalletBloc>().add(LoadWallet(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('My Wallet',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Top-up of Rp${state.amount.toStringAsFixed(0)} successful!',
                    style: const TextStyle(color: AppColors.textPrimaryDark)),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Withdrawal of Rp${state.amount.toStringAsFixed(0)} successful!',
                    style: const TextStyle(color: AppColors.textPrimaryDark)),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: _loadWallet,
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.backgroundDark)),
                  ),
                ],
              ),
            );
          }
          if (state is WalletLoaded) {
            final wallet = state.wallet;
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardDark,
              onRefresh: () async => _loadWallet(),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _BalanceSection(
                    balance: wallet.balance,
                    available: wallet.available,
                    held: wallet.held,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 48,
                              color: AppColors.textPrimaryDark
                                  .withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: AppColors.textPrimaryDark
                                  .withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.transactions
                        .map((t) => _TransactionTile(transaction: t)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final double balance;
  final double available;
  final double held;

  const _BalanceSection({
    required this.balance,
    required this.available,
    required this.held,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          'Total Balance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryDark.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rp ${balance.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.push('/wallet/topup'),
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text(
                  'Top Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: AppColors.textPrimaryDark.withValues(alpha: 0.2),
                  ),
                ),
                onPressed: () => context.push('/wallet/withdraw'),
                icon: const Icon(Icons.arrow_circle_down_outlined, size: 22),
                label: const Text(
                  'Withdraw',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceDetail(
                label: 'Available',
                value: available,
                color: AppColors.primaryLight,
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.textPrimaryDark.withValues(alpha: 0.1),
              ),
              _BalanceDetail(
                label: 'On Hold',
                value: held,
                color: AppColors.textPrimaryDark.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceDetail extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BalanceDetail({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimaryDark.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final CreditTransactionEntity transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final sign = isCredit ? '+' : '-';
    // color based on value
    final amountColor =
        isCredit ? AppColors.primary : AppColors.textPrimaryDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.textPrimaryDark.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.textPrimaryDark.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.type.icon,
              size: 24,
              color: isCredit
                  ? AppColors.primary
                  : AppColors.textPrimaryDark.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign Rp ${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(transaction.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
