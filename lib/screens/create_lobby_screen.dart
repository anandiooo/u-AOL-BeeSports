import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/create_lobby_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text('Create Lobby',
            style: GoogleFonts.inter(
                color: AppColors.primary, fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: BlocConsumer<CreateLobbyBloc, CreateLobbyState>(
        listener: (context, state) {
          if (state is CreateLobbySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Lobby created successfully!'),
                backgroundColor: AppColors.secondary));
            context.go('/lobbies/${state.lobby.id}');
          }
          if (state is CreateLobbyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.tersierDark));
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
                  Text('Select Sport',
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SportType.values.map((sport) {
                      final sel = _selectedSport == sport;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSport = sport),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.foursier,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.foursierDark),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(sport.icon,
                                size: 18,
                                color: sel
                                    ? AppColors.foursierLight
                                    : AppColors.primary),
                            const SizedBox(width: 8),
                            Text(sport.label,
                                style: GoogleFonts.inter(
                                    color: sel
                                        ? AppColors.foursierLight
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  Text('Lobby Details',
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.secondaryLight,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Title',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryLight)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: GoogleFonts.inter(color: AppColors.primary),
                            decoration: const InputDecoration(
                                hintText: 'e.g. Friendly Futsal Match',
                                prefixIcon: Icon(Icons.title),
                                fillColor: AppColors.foursier),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text('Description (Optional)',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryLight)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            style: GoogleFonts.inter(color: AppColors.primary),
                            decoration: const InputDecoration(
                                hintText: 'Any extra info for players...',
                                prefixIcon: Icon(Icons.description),
                                fillColor: AppColors.foursier),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 48),
                  Text('Schedule & Duration',
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.secondaryLight,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: _PickerField(
                                    label: 'Date',
                                    value:
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    icon: Icons.calendar_today,
                                    onTap: _pickDate)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _PickerField(
                                    label: 'Time',
                                    value: _selectedTime.format(context),
                                    icon: Icons.access_time,
                                    onTap: _pickTime)),
                          ]),
                          const SizedBox(height: 20),
                          Text('Duration',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryLight)),
                          const SizedBox(height: 12),
                          Row(
                            children: [30, 60, 90, 120].map((d) {
                              final sel = _duration == d;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _duration = d),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? AppColors.primary
                                          : AppColors.foursier,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: sel
                                              ? AppColors.primary
                                              : AppColors.foursierDark),
                                    ),
                                    child: Center(
                                      child: Text('${d}m',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              color: sel
                                                  ? AppColors.foursierLight
                                                  : AppColors.primary)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 48),
                  Text('Players & Requirements',
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.secondaryLight,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: _CounterField(
                                    label: 'Min Players',
                                    value: _minPlayers,
                                    min: 2,
                                    max: _maxPlayers,
                                    onChanged: (v) =>
                                        setState(() => _minPlayers = v))),
                            const SizedBox(width: 24),
                            Expanded(
                                child: _CounterField(
                                    label: 'Max Players',
                                    value: _maxPlayers,
                                    min: _minPlayers,
                                    max: 30,
                                    onChanged: (v) =>
                                        setState(() => _maxPlayers = v))),
                          ]),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(
                                  height: 1, color: AppColors.tersierLight)),
                          Text('Deposit (Rp)',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryLight)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _depositController,
                            style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _RupiahInputFormatter(),
                            ],
                            decoration: const InputDecoration(
                                hintText: '0 for no deposit',
                                prefixIcon: Icon(Icons.monetization_on),
                                fillColor: AppColors.foursier),
                          ),
                          const SizedBox(height: 20),
                          Text('Elo Range',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryLight)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minEloController,
                                style:
                                    GoogleFonts.inter(color: AppColors.primary),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Min',
                                    prefixIcon: Icon(Icons.arrow_downward),
                                    fillColor: AppColors.foursier),
                              ),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('—',
                                    style: GoogleFonts.inter(
                                        color: AppColors.primaryLight,
                                        fontSize: 18))),
                            Expanded(
                              child: TextFormField(
                                controller: _maxEloController,
                                style:
                                    GoogleFonts.inter(color: AppColors.primary),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Max',
                                    prefixIcon: Icon(Icons.arrow_upward),
                                    fillColor: AppColors.foursier),
                              ),
                            ),
                          ]),
                        ]),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.foursierLight))
                          : const Text('Create Lobby'),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
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
    final time =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final scheduledAt = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    context.read<CreateLobbyBloc>().add(SubmitLobby(
          hostId: authState.user.id,
          title: _titleController.text.trim(),
          sport: _selectedSport,
          description: _descController.text.trim(),
          scheduledAt: scheduledAt,
          durationMinutes: _duration,
          minPlayers: _minPlayers,
          maxPlayers: _maxPlayers,
          depositAmount: double.tryParse(_depositController.text.replaceAll('.', '').trim()) ?? 0,
          minElo: int.tryParse(_minEloController.text.trim()),
          maxElo: int.tryParse(_maxEloController.text.trim()),
        ));
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerField(
      {required this.label,
      required this.value,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryLight)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.foursier,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Text(value,
                style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14)),
          ]),
        ),
      ),
    ]);
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _CounterField(
      {required this.label,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryLight)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.foursier,
          borderRadius: BorderRadius.circular(30),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _RoundButton(
              icon: Icons.remove,
              enabled: value > min,
              onTap: () => onChanged(value - 1)),
          Text('$value',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary)),
          _RoundButton(
              icon: Icons.add,
              enabled: value < max,
              onTap: () => onChanged(value + 1)),
        ]),
      ),
    ]);
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _RoundButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.tersierLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? AppColors.foursierLight : AppColors.primaryLight),
      ),
    );
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
