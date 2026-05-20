import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text('My Wallet',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.primary)),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Top-up of Rp${state.amount.toStringAsFixed(0)} successful!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Withdrawal of Rp${state.amount.toStringAsFixed(0)} successful!'),
                backgroundColor: AppColors.secondary,
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
                      size: 48, color: AppColors.primaryLight),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: GoogleFonts.inter(color: AppColors.primary)),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loadWallet,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is WalletLoaded) {
            final wallet = state.wallet;
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.foursier,
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
                  const SizedBox(height: 48),
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (state.transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryLight,
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 40, color: AppColors.primaryLight),
                          const SizedBox(height: 18),
                          Text(
                            'No transactions yet',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryLight,
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
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rp ${balance.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: 42,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),

        // CTA row — primary pill + secondary pill
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.foursierLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.push('/wallet/topup'),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text(
                    'Top Up',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.push('/wallet/withdraw'),
                  icon: const Icon(Icons.arrow_circle_down_outlined, size: 20),
                  label: Text(
                    'Withdraw',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Balance detail row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.secondaryLight,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceDetail(label: 'Available', value: available),
              Container(
                height: 36,
                width: 1,
                color: AppColors.foursierDark,
              ),
              _BalanceDetail(label: 'On Hold', value: held),
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

  const _BalanceDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${value.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
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
    final amountColor = isCredit ? AppColors.secondary : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.tersierLight),
        ),
      ),
      child: Row(
        children: [
          Icon(
            transaction.type.icon,
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primaryLight,
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
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(transaction.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primaryLight,
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
