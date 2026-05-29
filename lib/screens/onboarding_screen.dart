import 'package:beesports/app/di.dart';
import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/campus.dart';
import 'package:beesports/models/user_entity.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:beesports/models/skill_level.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  final UserEntity user;
  const OnboardingScreen({super.key, required this.user});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nimController = TextEditingController();
  final _pageController = PageController();
  int _currentPage = 0;
  Campus _detectedCampus = Campus.unknown;
  final Set<SportType> _selectedSports = {};
  final Map<SportType, SkillLevel> _skillLevels = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNimChanged(String nim) =>
      setState(() => _detectedCampus = Campus.fromNim(nim));

  void _nextPage() {
    if (_currentPage == 0 && _nimController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid 10-digit NIM')));
      return;
    }
    if (_currentPage == 1 && _selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one sport')));
      return;
    }
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prevPage() => _pageController.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  Future<void> _onSubmit() async {
    for (final sport in _selectedSports) {
      if (!_skillLevels.containsKey(sport)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Set skill level for ${sport.label}')));
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      await sl<ProfileRepository>().completeOnboarding(
        userId: widget.user.id,
        nim: _nimController.text.trim(),
        campus: _detectedCampus.label,
        sportPreferences: _selectedSports.map((s) => s.name).toList(),
        skillLevels: _skillLevels.map((s, l) => MapEntry(s.name, l.name)),
      );
      if (mounted) {
        context.read<AuthBloc>().add(OnboardingCompleted(widget.user.copyWith(
              nim: _nimController.text.trim(),
              campus: _detectedCampus.label,
              isOnboarded: true,
            )));
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: List.generate(
                  3,
                  (i) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: i <= _currentPage
                              ? AppColors.neonGreen
                              : AppColors.divider,
                        ),
                      )),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [_nimPage(), _sportPage(), _skillPage()],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _nimPage() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(),
          Text('ENTER YOUR NIM',
              style: GoogleFonts.bebasNeue(
                  fontSize: 48, height: 0.9, color: AppColors.neonGreen)),
          const SizedBox(height: 12),
          Text("We'll auto-detect your campus",
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nimController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.neonGreen,
                letterSpacing: 3),
            decoration: const InputDecoration(
                hintText: '2502000000',
                counterText: '',
                prefixIcon: Icon(Icons.badge_outlined)),
            onChanged: _onNimChanged,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _detectedCampus != Campus.unknown
                ? Container(
                    key: ValueKey(_detectedCampus),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: AppColors.surfaceVariant,
                    child: Row(children: [
                      const Icon(Icons.location_on,
                          color: AppColors.neonGreen, size: 20),
                      const SizedBox(width: 8),
                      Text('${_detectedCampus.label} — ${_detectedCampus.city}',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: AppColors.neonGreen)),
                    ]))
                : const SizedBox.shrink(),
          ),
          const Spacer(flex: 2),
          SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                  onPressed: _nextPage, child: const Text('Continue'))),
          const SizedBox(height: 24),
        ]),
      );

  Widget _sportPage() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          Text('WHAT DO\nYOU PLAY?',
              style: GoogleFonts.bebasNeue(
                  fontSize: 48, height: 0.9, color: AppColors.neonGreen)),
          const SizedBox(height: 12),
          Text('Select one or more sports',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5),
              itemCount: SportType.values.length,
              itemBuilder: (context, index) {
                final sport = SportType.values[index];
                final sel = _selectedSports.contains(sport);
                return GestureDetector(
                  onTap: () => setState(() {
                    sel
                        ? (
                            _selectedSports.remove(sport),
                            _skillLevels.remove(sport)
                          )
                        : _selectedSports.add(sport);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: sel ? AppColors.neonGreen : AppColors.surfaceVariant,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(sport.icon,
                              size: 28,
                              color: sel
                                  ? AppColors.onAccent
                                  : AppColors.neonGreen),
                          const SizedBox(height: 8),
                          Text(sport.label,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? AppColors.onAccent
                                      : AppColors.neonGreen)),
                        ]),
                  ),
                );
              },
            ),
          ),
          Row(children: [
            TextButton(
                onPressed: _prevPage,
                child: Text('Back',
                    style: GoogleFonts.inter(
                        color: AppColors.neonGreen,
                        decoration: TextDecoration.underline))),
            const Spacer(),
            SizedBox(
                height: 48,
                child: ElevatedButton(
                    onPressed: _selectedSports.isNotEmpty ? _nextPage : null,
                    child: const Text('Continue'))),
          ]),
          const SizedBox(height: 24),
        ]),
      );

  Widget _skillPage() {
    final sports = _selectedSports.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text('RATE YOUR\nSKILLS',
            style: GoogleFonts.bebasNeue(
                fontSize: 48, height: 0.9, color: AppColors.neonGreen)),
        const SizedBox(height: 12),
        Text('Be honest — this helps with fair matchmaking!',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: sports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sport = sports[index];
              final cur = _skillLevels[sport];
              return Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surfaceVariant,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(sport.icon, color: AppColors.neonGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(sport.label,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: AppColors.neonGreen)),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                          children: SkillLevel.values.map((level) {
                        final sel = cur == level;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _skillLevels[sport] = level),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.neonGreen
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: sel
                                        ? AppColors.neonGreen
                                        : AppColors.border),
                              ),
                              child: Column(children: [
                                Text(level.emoji,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(level.label,
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: sel
                                            ? AppColors.onAccent
                                            : AppColors.textSecondary)),
                              ]),
                            ),
                          ),
                        );
                      }).toList()),
                    ]),
              );
            },
          ),
        ),
        Row(children: [
          TextButton(
              onPressed: _prevPage,
              child: Text('Back',
                  style: GoogleFonts.inter(
                      color: AppColors.neonGreen,
                      decoration: TextDecoration.underline))),
          const Spacer(),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onAccent))
                  : const Text("Let's Go!"),
            ),
          ),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}
