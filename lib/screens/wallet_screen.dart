import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      appBar: AppBar(title: Text('My Wallet', style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Top-up of Rp${state.amount.toStringAsFixed(0)} successful!'), backgroundColor: AppColors.neonGreen),
            );
          }
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Withdrawal of Rp${state.amount.toStringAsFixed(0)} successful!'), backgroundColor: AppColors.neonGreen),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const ShimmerProfileHeader(),
                  const SizedBox(height: 32),
                  ShimmerListView.transactions(count: 4),
                ],
              ),
            );
          }
          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.mute),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 18),
                  SizedBox(height: 48, child: ElevatedButton(onPressed: _loadWallet, child: const Text('Retry'))),
                ],
              ),
            );
          }
          if (state is WalletLoaded) {
            final wallet = state.wallet;
            return RefreshIndicator(
              color: AppColors.neonGreen,
              onRefresh: () async => _loadWallet(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                children: [
                  _BalanceSection(balance: wallet.balance, available: wallet.available, held: wallet.held)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 48),
                  Text('Recent Transactions', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.charcoal))
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 350.ms),
                  const SizedBox(height: 18),
                  if (state.transactions.isEmpty)
                    const EmptyTransactions()
                  else
                    ...state.transactions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final t = entry.value;
                      return _TransactionTile(transaction: t)
                          .animate()
                          .fadeIn(delay: (200 + 60 * index).ms, duration: 350.ms, curve: Curves.easeOutCubic)
                          .slideX(begin: 0.05, delay: (200 + 60 * index).ms, duration: 350.ms, curve: Curves.easeOutCubic);
                    }),
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

  const _BalanceSection({required this.balance, required this.available, required this.held});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text('Total Balance', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mute)),
        const SizedBox(height: 8),
        Text('Rp ${balance.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w500, color: AppColors.neonGreen, height: 1.2)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/wallet/topup');
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text('Top Up', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/wallet/withdraw');
                  },
                  icon: const Icon(Icons.arrow_circle_down_outlined, size: 20),
                  label: Text('Withdraw', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(color: AppColors.softCloud, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceDetail(label: 'Available', value: available),
              Container(height: 36, width: 1, color: AppColors.hairline),
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

  const _BalanceDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('Rp ${value.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
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
    final amountColor = isCredit ? AppColors.neonGreen : AppColors.charcoal;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Row(
        children: [
          Icon(transaction.type.icon, size: 22, color: AppColors.neonGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.type.label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(transaction.description, style: GoogleFonts.inter(fontSize: 14, color: AppColors.mute), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign Rp ${transaction.amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: amountColor)),
              const SizedBox(height: 2),
              Text(_formatDateTime(transaction.createdAt), style: GoogleFonts.inter(fontSize: 12, color: AppColors.mute)),
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
