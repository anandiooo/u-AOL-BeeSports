import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/create_lobby_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateLobbyScreen extends StatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _depositController = TextEditingController(text: '0');
  final _minEloController = TextEditingController();
  final _maxEloController = TextEditingController();

  SportType _selectedSport = SportType.futsal;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  int _duration = 60;
  int _minPlayers = 2;
  int _maxPlayers = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _depositController.dispose();
    _minEloController.dispose();
    _maxEloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Create Lobby',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: BlocConsumer<CreateLobbyBloc, CreateLobbyState>(
        listener: (context, state) {
          if (state is CreateLobbySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lobby created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/lobbies/${state.lobby.id}');
          }
          if (state is CreateLobbyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateLobbyLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // sport section
                  const Text(
                    'Select Sport',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: SportType.values.map((sport) {
                      final isSelected = _selectedSport == sport;
                      return ChoiceChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sport.icon,
                              size: 18,
                              color: isSelected
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryDark
                                      .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sport.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryDark
                                        .withValues(alpha: 0.6),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.cardDark,
                        selectedColor: sport.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? sport.color
                                : AppColors.textPrimaryDark
                                    .withValues(alpha: 0.05),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedSport = sport),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // details section
                  const Text(
                    'Lobby Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            AppColors.textPrimaryDark.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          style:
                              const TextStyle(color: AppColors.textPrimaryDark),
                          decoration: _inputDecoration(
                            hintText: 'e.g. Friendly Futsal Match',
                            icon: Icons.title,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          style:
                              const TextStyle(color: AppColors.textPrimaryDark),
                          decoration: _inputDecoration(
                            hintText: 'Any extra info for players...',
                            icon: Icons.description,
                          ).copyWith(
                              alignLabelWithHint: true,
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 48, minHeight: 80)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // schedule & location section
                  const Text(
                    'Schedule & Duration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            AppColors.textPrimaryDark.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'Date',
                                value:
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DatePickerField(
                                label: 'Time',
                                value: _selectedTime.format(context),
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [30, 60, 90, 120].map((d) {
                            final isSelected = _duration == d;
                            return ChoiceChip(
                              label: Text(
                                '${d}m',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              showCheckmark: false,
                              selected: isSelected,
                              backgroundColor: AppColors.surfaceDark,
                              selectedColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondaryDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimaryDark
                                          .withValues(alpha: 0.05),
                                ),
                              ),
                              onSelected: (_) => setState(() => _duration = d),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // rules & players section
                  const Text(
                    'Players & Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            AppColors.textPrimaryDark.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _CounterField(
                                label: 'Min Players',
                                value: _minPlayers,
                                min: 2,
                                max: _maxPlayers,
                                onChanged: (v) =>
                                    setState(() => _minPlayers = v),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _CounterField(
                                label: 'Max Players',
                                value: _maxPlayers,
                                min: _minPlayers,
                                max: 30,
                                onChanged: (v) =>
                                    setState(() => _maxPlayers = v),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: AppColors.surfaceDark),
                        ),
                        const Text(
                          'Deposit (Rp)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _depositController,
                          style: const TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hintText: '0 for no deposit',
                            icon: Icons.monetization_on,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Elo Range',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minEloController,
                                style: const TextStyle(
                                    color: AppColors.textPrimaryDark),
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  hintText: 'Min Elo',
                                  icon: Icons.arrow_downward,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '-',
                              style: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxEloController,
                                style: const TextStyle(
                                    color: AppColors.textPrimaryDark),
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  hintText: 'Max Elo',
                                  icon: Icons.arrow_upward,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.backgroundDark,
                              ),
                            )
                          : const Text(
                              'Create Lobby',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textPrimaryDark.withValues(alpha: 0.3),
        fontWeight: FontWeight.normal,
      ),
      prefixIcon:
          Icon(icon, color: AppColors.textPrimaryDark.withValues(alpha: 0.4)),
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    context.read<CreateLobbyBloc>().add(SubmitLobby(
          hostId: authState.user.id,
          title: _titleController.text.trim(),
          sport: _selectedSport,
          description: _descController.text.trim(),
          scheduledAt: scheduledAt,
          durationMinutes: _duration,
          minPlayers: _minPlayers,
          maxPlayers: _maxPlayers,
          depositAmount: double.tryParse(_depositController.text.trim()) ?? 0,
          minElo: int.tryParse(_minEloController.text.trim()),
          maxElo: int.tryParse(_maxEloController.text.trim()),
        ));
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  label == 'Date' ? Icons.calendar_today : Icons.access_time,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: value > min
                      ? AppColors.cardDark
                      : AppColors.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  color: AppColors.textPrimaryDark,
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: value < max
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  color: value < max
                      ? AppColors.primary
                      : AppColors.textSecondaryDark,
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
