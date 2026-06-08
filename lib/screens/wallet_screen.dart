import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/models/credit_transaction_entity.dart';
import 'package:beesports/models/transaction_type.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text('My Wallet', style: AppTextStyles.sectionTitle),
              ),
              Expanded(
                child: BlocConsumer<WalletBloc, WalletState>(
                  listener: (context, state) {
                    if (state is TopUpSuccess) {
                      FeedbackService.showSuccess(context,
                          'Top-up of Rp${_formatRupiah(state.amount)} successful!');
                    }
                    if (state is WithdrawSuccess) {
                      FeedbackService.showSuccess(context,
                          'Withdrawal of Rp${_formatRupiah(state.amount)} successful!');
                    }
                  },
                  builder: (context, state) {
                    if (state is WalletLoading) {
                      return Column(
                        children: [
                          const ShimmerProfileHeader(),
                          const SizedBox(height: DesignConfig.spacingMd),
                          ShimmerListView.transactions(count: 4),
                        ],
                      );
                    }
                    if (state is WalletError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: DesignConfig.spacingMd),
                            Text(state.message),
                            const SizedBox(height: DesignConfig.spacingMd),
                            SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                    onPressed: _loadWallet,
                                    child: const Text('Retry'))),
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
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          children: [
                            _BalanceSection(
                                    balance: wallet.balance,
                                    available: wallet.available,
                                    held: wallet.held)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(
                                    begin: -0.03,
                                    duration: 400.ms,
                                    curve: Curves.easeOutCubic),
                            const SizedBox(height: DesignConfig.spacing2xl),
                            Text('Recent Transactions',
                                    style: AppTextStyles.sectionTitle)
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 350.ms),
                            if (state.transactions.isEmpty)
                              const EmptyTransactions()
                            else
                              ...state.transactions
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final t = entry.value;
                                return _TransactionTile(transaction: t)
                                    .animate()
                                    .fadeIn(
                                        delay: (200 + 60 * index).ms,
                                        duration: 350.ms,
                                        curve: Curves.easeOutCubic)
                                    .slideX(
                                        begin: 0.05,
                                        delay: (200 + 60 * index).ms,
                                        duration: 350.ms,
                                        curve: Curves.easeOutCubic);
                              }),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final double balance;
  final double available;
  final double held;

  const _BalanceSection(
      {required this.balance, required this.available, required this.held});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: DesignConfig.spacingMd),
        Text('Total Balance', style: AppTextStyles.bodySecondaryStrong),
        const SizedBox(height: DesignConfig.spacingMd),
        Text('Rp ${_formatRupiah(balance)}',
            style: AppTextStyles.displayHero.copyWith(height: 1.2)),
        const SizedBox(height: DesignConfig.spacingLg),
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.background,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: Text('Top Up',
                      style: AppTextStyles.cardTitle
                          .copyWith(color: AppColors.background)),
                ),
              ),
            ),
            const SizedBox(width: DesignConfig.spacingMd),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/wallet/withdraw');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sale,
                    foregroundColor: AppColors.background,
                  ),
                  icon: const Icon(Icons.arrow_circle_down_outlined, size: 20),
                  label: Text('Withdraw',
                      style: AppTextStyles.cardTitle
                          .copyWith(color: AppColors.background)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignConfig.spacing2xl),
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: DesignConfig.spacingMd,
              horizontal: DesignConfig.spacingMd),
          decoration: BoxDecoration(
              color: AppColors.softCloud,
              borderRadius: BorderRadius.circular(DesignConfig.roundedXl)),
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
        Text(label, style: AppTextStyles.bodySecondaryStrong),
        const SizedBox(height: DesignConfig.spacingXs),
        Text('Rp ${_formatRupiah(value)}', style: AppTextStyles.cardTitle),
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
    final prefix = transaction.type == TransactionType.depositHold
        ? 'Rp '
        : (isCredit ? '+ Rp ' : '- Rp ');
    final amountColor = transaction.type == TransactionType.depositHold
        ? AppColors.yellow
        : (isCredit ? AppColors.neonGreen : AppColors.sale);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingXxs),
      padding: const EdgeInsets.symmetric(
          vertical: DesignConfig.spacingMd, horizontal: DesignConfig.spacingMd),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Row(
        children: [
          Icon(transaction.type.icon, size: 22, color: transaction.type.color),
          const SizedBox(width: DesignConfig.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.type.label, style: AppTextStyles.cardTitle),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$prefix${_formatRupiah(transaction.amount)}',
                  style: AppTextStyles.cardTitle.copyWith(color: amountColor)),
              const SizedBox(height: DesignConfig.spacingXs),
              Text(_formatDateTime(transaction.createdAt),
                  style: AppTextStyles.caption),
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

String _formatRupiah(double n) {
  final clean = n.toStringAsFixed(0);
  final buffer = StringBuffer();
  final len = clean.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(clean[i]);
  }
  return buffer.toString();
}
