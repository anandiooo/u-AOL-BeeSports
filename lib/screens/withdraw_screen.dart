import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _customController = TextEditingController();
  double? _selectedAmount;

  static const _presets = [
    10000.0,
    25000.0,
    50000.0,
    100000.0,
    200000.0,
    500000.0,
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Withdraw',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Rp${state.amount.toStringAsFixed(0)} withdrawn successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presets.map((amount) {
                  final selected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAmount = amount;
                        _customController.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.error
                              : Colors.white.withValues(alpha: 0.1),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        'Rp${_formatNumber(amount)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppColors.error
                              : AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Or enter custom amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _customController,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.edit),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimaryDark),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  setState(() {
                    _selectedAmount = val;
                  });
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This is a simulated withdrawal for testing. No real payout will be processed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textPrimaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _selectedAmount != null && _selectedAmount! > 0
                      ? _submit
                      : null,
                  child: Text(
                    _selectedAmount != null && _selectedAmount! > 0
                        ? 'Withdraw Rp${_formatNumber(_selectedAmount!)}'
                        : 'Select an amount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated || _selectedAmount == null) return;

    context.read<WalletBloc>().add(WithdrawRequested(
          userId: authState.user.id,
          amount: _selectedAmount!,
        ));
  }

  String _formatNumber(double n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}K';
    }
    return n.toStringAsFixed(0);
  }
}
