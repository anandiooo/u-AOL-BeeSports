import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});
  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _customController = TextEditingController();
  double? _selectedAmount;
  static const _presets = [10000.0, 25000.0, 50000.0, 100000.0, 200000.0, 500000.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text('Top Up',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.primary)),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Rp${state.amount.toStringAsFixed(0)} added!'),
                backgroundColor: AppColors.secondary));
            context.pop();
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.tersierDark));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Select Amount',
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w500,
                    color: AppColors.primary)),
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
                      color: sel ? AppColors.primary : AppColors.foursier,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.foursierDark),
                    ),
                    child: Text('Rp${_formatNumber(amount)}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: sel ? AppColors.foursierLight : AppColors.primary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Or enter custom amount',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.primaryLight)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customController,
              decoration: const InputDecoration(
                  prefixText: 'Rp ', hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.edit)),
              style: GoogleFonts.inter(color: AppColors.primary),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  setState(() => _selectedAmount = double.tryParse(v)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.secondaryLight,
              child: Row(children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'This is a simulated top-up for testing. No real payment will be processed.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.primaryLight)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedAmount != null && _selectedAmount! > 0
                    ? _submit : null,
                child: Text(_selectedAmount != null && _selectedAmount! > 0
                    ? 'Top Up Rp${_formatNumber(_selectedAmount!)}'
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
    context.read<WalletBloc>().add(TopUpRequested(
        userId: authState.user.id, amount: _selectedAmount!));
  }

  String _formatNumber(double n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}K' : n.toStringAsFixed(0);
}
