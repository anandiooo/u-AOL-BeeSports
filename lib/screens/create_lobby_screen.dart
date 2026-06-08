import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/create_lobby_bloc.dart';
import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  Step definitions
// ─────────────────────────────────────────────

enum _Step {
  sport,
  details,
  schedule,
  players;

  String get label => switch (this) {
        sport => 'Sport',
        details => 'Details',
        schedule => 'Schedule',
        players => 'Players',
      };

  IconData get icon => switch (this) {
        sport => Icons.sports,
        details => Icons.info_outline,
        schedule => Icons.calendar_today,
        players => Icons.group_outlined,
      };
}

// ─────────────────────────────────────────────
//  Shared constants
// ─────────────────────────────────────────────

/// Vertical padding that makes every tappable row the same height
/// as a standard TextFormField (approx 48 logical px content area).
const double _inputVerticalPadding = 14.0;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────

class CreateLobbyScreen extends StatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen>
    with SingleTickerProviderStateMixin {
  int _stepIndex = 0;
  final _steps = _Step.values;

  final _detailsFormKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _depositController = TextEditingController();
  final _minEloController = TextEditingController();
  final _maxEloController = TextEditingController();

  SportType _selectedSport = SportType.futsal;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  int _duration = 60;
  int _minPlayers = 2;
  int _maxPlayers = 10;
  double? _latitude;
  double? _longitude;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _depositController.dispose();
    _minEloController.dispose();
    _maxEloController.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────

  void _goTo(int index) {
    setState(() => _stepIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    if (_steps[_stepIndex] == _Step.details) {
      return _detailsFormKey.currentState?.validate() ?? false;
    }
    if (_steps[_stepIndex] == _Step.players) {
      final depText = _depositController.text.replaceAll('.', '').trim();
      final depVal = double.tryParse(depText) ?? 0;
      if (depVal <= 0) {
        FeedbackService.showError(context, 'Deposit is required and must be greater than 0');
        return false;
      }
    }
    return true;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_stepIndex < _steps.length - 1) {
      _goTo(_stepIndex + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_stepIndex > 0) _goTo(_stepIndex - 1);
  }

  // ── Submit ───────────────────────────────────

  void _submit() {
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
          depositAmount: double.tryParse(
                  _depositController.text.replaceAll('.', '').trim()) ??
              0,
          minElo: int.tryParse(_minEloController.text.trim()),
          maxElo: int.tryParse(_maxEloController.text.trim()),
          latitude: _latitude,
          longitude: _longitude,
        ));
  }

  // ── Build ────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateLobbyBloc, CreateLobbyState>(
      listener: (context, state) {
        if (state is CreateLobbySuccess) {
          FeedbackService.showSuccess(context, 'Lobby created successfully!');
          context.go('/lobbies/${state.lobby.id}');
        }
        if (state is CreateLobbyError) {
          FeedbackService.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateLobbyLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Create Lobby', style: AppTextStyles.sectionTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.neonGreen),
          ),
          body: Column(
            children: [
              _StepProgressBar(
                steps: _steps,
                currentIndex: _stepIndex,
                onStepTapped: (i) {
                  if (i < _stepIndex) _goTo(i);
                },
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _SportStep(
                      selected: _selectedSport,
                      onChanged: (s) => setState(() => _selectedSport = s),
                    ),
                    _DetailsStep(
                      formKey: _detailsFormKey,
                      titleController: _titleController,
                      descController: _descController,
                      latitude: _latitude,
                      longitude: _longitude,
                      onLocationPicked: (lat, lng) => setState(() {
                        _latitude = lat;
                        _longitude = lng;
                      }),
                    ),
                    _ScheduleStep(
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      duration: _duration,
                      onDateChanged: (d) => setState(() => _selectedDate = d),
                      onTimeChanged: (t) => setState(() => _selectedTime = t),
                      onDurationChanged: (d) => setState(() => _duration = d),
                    ),
                    _PlayersStep(
                      minPlayers: _minPlayers,
                      maxPlayers: _maxPlayers,
                      depositController: _depositController,
                      minEloController: _minEloController,
                      maxEloController: _maxEloController,
                      onMinChanged: (v) => setState(() => _minPlayers = v),
                      onMaxChanged: (v) => setState(() => _maxPlayers = v),
                    ),
                  ],
                ),
              ),
              _BottomNavBar(
                stepIndex: _stepIndex,
                totalSteps: _steps.length,
                isLoading: isLoading,
                isLastStep: _stepIndex == _steps.length - 1,
                onBack: _back,
                onNext: _next,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Step Progress Bar  (BIGGER)
// ─────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final List<_Step> steps;
  final int currentIndex;
  final ValueChanged<int> onStepTapped;

  const _StepProgressBar({
    required this.steps,
    required this.currentIndex,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignConfig.spacingXl,
        DesignConfig.spacingMd,
        DesignConfig.spacingXl,
        DesignConfig.spacingLg,
      ),
      child: Column(
        children: [
          // Circles + connector lines
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final leftStepIndex = i ~/ 2;
                final passed = currentIndex > leftStepIndex;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: passed ? AppColors.neonGreen : AppColors.divider,
                  ),
                );
              }
              final si = i ~/ 2;
              final step = steps[si];
              final isDone = currentIndex > si;
              final isCurrent = currentIndex == si;
              return GestureDetector(
                onTap: () => onStepTapped(si),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // ← bigger circle: 44px
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isCurrent
                        ? AppColors.neonGreen
                        : AppColors.surface,
                    border: Border.all(
                      color: isDone || isCurrent
                          ? AppColors.neonGreen
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check,
                            size: 20, color: AppColors.onAccent)
                        : Icon(step.icon,
                            size: 20,
                            color: isCurrent
                                ? AppColors.onAccent
                                : AppColors.textSecondary),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: DesignConfig.spacingMd),
          // Labels — aligned under each circle (44px wide)
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) return const Expanded(child: SizedBox());
              final si = i ~/ 2;
              final step = steps[si];
              final isDone = currentIndex > si;
              final isCurrent = currentIndex == si;
              return SizedBox(
                width: 44,
                height: 16,
                child: OverflowBox(
                  minWidth: 0,
                  maxWidth: 120,
                  alignment: Alignment.center,
                  child: Text(
                    step.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyles.bodySecondaryStrong.copyWith(
                        // ← bigger label: 11px, bold when active/done
                        fontSize: 11,
                        fontWeight:
                            isCurrent || isDone ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent
                            ? AppColors.neonGreen
                            : isDone
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Bottom Navigation Bar
// ─────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final bool isLoading;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNavBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.isLoading,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignConfig.spacingXl,
        DesignConfig.spacingMd,
        DesignConfig.spacingXl,
        DesignConfig.spacingMd + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          if (stepIndex > 0) ...[
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignConfig.rounded2xl),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignConfig.spacingMd),
          ],
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : onNext,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.onAccent),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLastStep ? 'Create Lobby' : 'Continue'),
                          if (!isLastStep) ...[
                            const SizedBox(width: DesignConfig.spacingMd),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 1: Sport  (COMPACT cards)
// ─────────────────────────────────────────────

class _SportStep extends StatelessWidget {
  final SportType selected;
  final ValueChanged<SportType> onChanged;

  const _SportStep({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What sport are you playing?',
              style: AppTextStyles.sectionTitle),
          const SizedBox(height: DesignConfig.spacingXl),
          ...SportType.values.map((sport) {
            final sel = selected == sport;
            return GestureDetector(
              onTap: () => onChanged(sport),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                // ← smaller: reduced margin + vertical padding
                margin: const EdgeInsets.only(bottom: DesignConfig.spacingMd),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignConfig.spacingMd,
                  vertical: DesignConfig.spacingMd, // was spacingMd+4
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.neonGreen.withOpacity(0.08)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
                  border: Border.all(
                    color: sel ? AppColors.neonGreen : AppColors.hairline,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // ← smaller icon box: 36×36 (was 44×44)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: sel ? AppColors.neonGreen : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(DesignConfig.roundedMd),
                      ),
                      child: Icon(sport.icon,
                          size: 18, // was 22
                          color: sel
                              ? AppColors.onAccent
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: DesignConfig.spacingMd),
                    Text(sport.label, style: AppTextStyles.inputText),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check_circle,
                          color: AppColors.neonGreen, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 2: Details  (wrapped in card)
// ─────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descController;
  final double? latitude;
  final double? longitude;
  final void Function(double lat, double lng) onLocationPicked;

  const _DetailsStep({
    required this.formKey,
    required this.titleController,
    required this.descController,
    required this.latitude,
    required this.longitude,
    required this.onLocationPicked,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lobby details', style: AppTextStyles.sectionTitle),
            const SizedBox(height: DesignConfig.spacingXl),
            // ── Card container ──
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FormLabel('Title'),
                  const SizedBox(height: DesignConfig.spacingSm),
                  TextFormField(
                    controller: titleController,
                    style: AppTextStyles.accentLabel,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Friendly Futsal Match',
                      prefixIcon: Icon(Icons.title),
                      fillColor: AppColors.background,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: DesignConfig.spacingLg),
                  const _FormLabel('Description (Optional)'),
                  const SizedBox(height: DesignConfig.spacingSm),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    style: AppTextStyles.accentLabel,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Any extra info for players…',
                      prefixIcon: Icon(Icons.description),
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: DesignConfig.spacingLg),
                  const _FormLabel('Location'),
                  const SizedBox(height: DesignConfig.spacingSm),
                  GestureDetector(
                    onTap: () async {
                      final result = await context
                          .push<Map<String, dynamic>>('/map-picker', extra: {
                        if (latitude != null) 'lat': latitude,
                        if (longitude != null) 'lng': longitude,
                      });
                      if (result != null) {
                        final lat = result['lat'] as double?;
                        final lng = result['lng'] as double?;
                        if (lat != null && lng != null) {
                          onLocationPicked(lat, lng);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignConfig.spacingMd,
                        vertical: _inputVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(DesignConfig.roundedXl),
                        border: Border.all(
                          color: latitude != null
                              ? AppColors.neonGreen
                              : AppColors.hairline,
                        ),
                      ),
                      child: Row(children: [
                        Icon(Icons.location_on,
                            color: latitude != null
                                ? AppColors.neonGreen
                                : AppColors.textSecondary,
                            size: 20),
                        const SizedBox(width: DesignConfig.spacingMd),
                        Expanded(
                          child: Text(
                            latitude != null && longitude != null
                                ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
                                : 'Tap to pick a location',
                            style: AppTextStyles.accentLabel.copyWith(
                                color: latitude != null
                                    ? AppColors.neonGreen
                                    : AppColors.textSecondary),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary, size: 18),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 3: Schedule  (wrapped in card)
// ─────────────────────────────────────────────

class _ScheduleStep extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int duration;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<int> onDurationChanged;

  const _ScheduleStep({
    required this.selectedDate,
    required this.selectedTime,
    required this.duration,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When is it?', style: AppTextStyles.sectionTitle),
          const SizedBox(height: DesignConfig.spacingXl),
          // ── Card container ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Date',
                      value:
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      icon: Icons.calendar_today,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) onDateChanged(date);
                      },
                    ),
                  ),
                  const SizedBox(width: DesignConfig.spacingSm),
                  Expanded(
                    child: _PickerField(
                      label: 'Time',
                      value: selectedTime.format(context),
                      icon: Icons.access_time,
                      onTap: () async {
                        final time = await showTimePicker(
                            context: context, initialTime: selectedTime);
                        if (time != null) onTimeChanged(time);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: DesignConfig.spacingLg),
                const _FormLabel('Duration'),
                const SizedBox(height: DesignConfig.spacingSm),
                Row(
                  children: [30, 60, 90, 120].map((d) {
                    final sel = duration == d;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onDurationChanged(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              horizontal: DesignConfig.spacingMd / 2),
                          padding: const EdgeInsets.symmetric(
                              vertical: _inputVerticalPadding),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.neonGreen
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(DesignConfig.rounded2xl),
                            border: Border.all(
                                color: sel
                                    ? AppColors.neonGreen
                                    : AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              '${d}m',
                              style:
                                  AppTextStyles.selectionLabel(selected: sel),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: DesignConfig.spacingXl),
                _ScheduleSummaryCard(
                  date: selectedDate,
                  time: selectedTime,
                  duration: duration,
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final int duration;
  final BuildContext context;

  const _ScheduleSummaryCard({
    required this.date,
    required this.time,
    required this.duration,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    final endMinutes = time.hour * 60 + time.minute + duration;
    final endTime =
        TimeOfDay(hour: endMinutes ~/ 60 % 24, minute: endMinutes % 60);
    return Container(
      padding: const EdgeInsets.all(DesignConfig.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.event_available, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: DesignConfig.spacingMd),
        Expanded(
          child: Text(
            '${date.day}/${date.month}/${date.year}  ·  ${time.format(context)} → ${endTime.format(context)}',
            style:
                AppTextStyles.accentLabel.copyWith(color: AppColors.neonGreen),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Step 4: Players & Requirements  (wrapped in card)
// ─────────────────────────────────────────────

class _PlayersStep extends StatelessWidget {
  final int minPlayers;
  final int maxPlayers;
  final TextEditingController depositController;
  final TextEditingController minEloController;
  final TextEditingController maxEloController;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;

  const _PlayersStep({
    required this.minPlayers,
    required this.maxPlayers,
    required this.depositController,
    required this.minEloController,
    required this.maxEloController,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Players & requirements', style: AppTextStyles.sectionTitle),
          const SizedBox(height: DesignConfig.spacingXl),
          // ── Card container ──
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FormLabel('Player Count'),
                const SizedBox(height: DesignConfig.spacingMd),
                Row(children: [
                  Expanded(
                      child: _CounterField(
                          label: 'Minimum',
                          value: minPlayers,
                          min: 2,
                          max: maxPlayers,
                          onChanged: onMinChanged)),
                  const SizedBox(width: DesignConfig.spacingMd),
                  Expanded(
                      child: _CounterField(
                          label: 'Maximum',
                          value: maxPlayers,
                          min: minPlayers,
                          max: 30,
                          onChanged: onMaxChanged)),
                ]),
                const SizedBox(height: DesignConfig.spacingLg),
                const _FormLabel('Deposit (Rp)'),
                const SizedBox(height: DesignConfig.spacingSm),
                TextFormField(
                  controller: depositController,
                  style: AppTextStyles.accentLabel,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RupiahInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                      hintText: 'Enter deposit amount (required)',
                      prefixIcon: Icon(Icons.monetization_on),
                      fillColor: AppColors.background),
                ),
                const SizedBox(height: DesignConfig.spacingLg),
                const _FormLabel('Elo Range (Optional)'),
                const SizedBox(height: DesignConfig.spacingSm),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: minEloController,
                      style: AppTextStyles.accentLabel,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Min Elo',
                          prefixIcon: Icon(Icons.arrow_downward),
                          fillColor: AppColors.background),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignConfig.spacingMd),
                      child: Text('—',
                          style: AppTextStyles.displayStat
                              .copyWith(color: AppColors.textSecondary))),
                  Expanded(
                    child: TextFormField(
                      controller: maxEloController,
                      style: AppTextStyles.accentLabel,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Max Elo',
                          prefixIcon: Icon(Icons.arrow_upward),
                          fillColor: AppColors.background),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shared: Section card wrapper
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.bodySecondaryStrong);
  }
}

/// Tappable picker row — height matches TextFormField via [_inputVerticalPadding].
class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.bodySecondaryStrong),
      const SizedBox(height: DesignConfig.spacingMd),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConfig.spacingMd,
            vertical: _inputVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(children: [
            Icon(icon, color: AppColors.neonGreen, size: 18),
            const SizedBox(width: DesignConfig.spacingMd),
            Expanded(child: Text(value, style: AppTextStyles.accentLabel)),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 16),
          ]),
        ),
      ),
    ]);
  }
}

/// Counter +/− row — height matches TextFormField via [_inputVerticalPadding].
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.bodySecondaryStrong),
      const SizedBox(height: DesignConfig.spacingMd),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConfig.spacingLg,
          vertical: DesignConfig.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
          border: Border.all(color: AppColors.hairline),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _RoundButton(
              icon: Icons.remove,
              enabled: value > min,
              onTap: () => onChanged(value - 1)),
          Text('$value',
              style: AppTextStyles.emptyTitle
                  .copyWith(color: AppColors.neonGreen)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.neonGreen : AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? AppColors.onAccent : AppColors.textSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Rupiah formatter (unchanged)
// ─────────────────────────────────────────────

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    final String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final double? value = double.tryParse(cleanText);
    if (value == null) return oldValue;

    final clean = cleanText.split('.')[0];
    final buffer = StringBuffer();
    final len = clean.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(clean[i]);
    }

    final String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
