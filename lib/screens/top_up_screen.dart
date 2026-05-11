import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _customController = TextEditingController();
  double? _selectedAmount;

  static const _presets = [
    10000.0,
    25000.0,
    50000.0,
    100000.0,
    200000.0,
    500000.0
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up')),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Rp${state.amount.toStringAsFixed(0)} added to your wallet!'),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
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
                              ? AppColors.primary
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _customController,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.edit),
                ),
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
                        'This is a simulated top-up for testing. No real payment will be processed.',
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
                  onPressed: _selectedAmount != null && _selectedAmount! > 0
                      ? _submit
                      : null,
                  child: Text(_selectedAmount != null && _selectedAmount! > 0
                      ? 'Top Up Rp${_formatNumber(_selectedAmount!)}'
                      : 'Select an amount'),
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

    context.read<WalletBloc>().add(TopUpRequested(
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
