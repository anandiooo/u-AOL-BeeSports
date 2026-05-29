import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Withdraw',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            FeedbackService.showSuccess(
                context, 'Rp${state.amount.toStringAsFixed(0)} withdrawn!');
            context.pop();
          }
          if (state is WalletError) {
            FeedbackService.showError(context, state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Select Amount',
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neonGreen)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((amount) {
                final sel = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedAmount = amount;
                    _customController.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.neonGreen : AppColors.background,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: sel ? AppColors.neonGreen : AppColors.border),
                    ),
                    child: Text('Rp${_formatNumber(amount)}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: sel
                                ? AppColors.onAccent
                                : AppColors.neonGreen)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Or enter custom amount',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _RupiahInputFormatter(),
              ],
              decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.edit)),
              style: GoogleFonts.inter(color: AppColors.neonGreen),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final clean = v.replaceAll('.', '');
                setState(() => _selectedAmount = double.tryParse(clean));
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceVariant,
              child: Row(children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'This is a simulated withdrawal for testing. No real payout will be processed.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedAmount != null && _selectedAmount! > 0
                    ? _submit
                    : null,
                child: Text(_selectedAmount != null && _selectedAmount! > 0
                    ? 'Withdraw'
                    : 'Select an amount'),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated || _selectedAmount == null) return;
    context.read<WalletBloc>().add(
        WithdrawRequested(userId: authState.user.id, amount: _selectedAmount!));
  }

  String _formatNumber(double n) {
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
}

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final double? value = double.tryParse(cleanText);

    if (value == null) {
      return oldValue;
    }

    final clean = cleanText.split('.')[0];
    final buffer = StringBuffer();
    final len = clean.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(clean[i]);
    }

    final String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
