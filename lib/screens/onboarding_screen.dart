import 'package:beesports/app/app_theme.dart';
import 'package:beesports/app/di.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/models/campus.dart';
import 'package:beesports/models/skill_level.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:beesports/models/user_entity.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(children: [
            Row(
              children: List.generate(
                  3,
                  (i) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: DesignConfig.spacingXs),
                          color: i <= _currentPage
                              ? AppColors.neonGreen
                              : AppColors.divider,
                        ),
                      )),
            ),
            const SizedBox(height: DesignConfig.spacingXl),
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
      ),
    );
  }

  Widget _nimPage() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Spacer(),
        Text('ENTER YOUR NIM',
            style: AppTextStyles.bebas(DesignConfig.displayLg, height: 0.9)),
        const SizedBox(height: DesignConfig.spacingMd),
        Text("We'll auto-detect your campus",
            style: AppTextStyles.bodySecondary),
        const SizedBox(height: DesignConfig.spacing2xl),
        TextFormField(
          controller: _nimController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          style: AppTextStyles.sectionTitleSpaced,
          decoration: const InputDecoration(
              hintText: '2502000000',
              counterText: '',
              prefixIcon: Icon(Icons.badge_outlined)),
          onChanged: _onNimChanged,
        ),
        const SizedBox(height: DesignConfig.spacingLg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _detectedCampus != Campus.unknown
              ? Container(
                  key: ValueKey(_detectedCampus),
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignConfig.spacingLg,
                      vertical: DesignConfig.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignConfig.roundedLg),
                  ),
                  child: Row(children: [
                    const Icon(Icons.location_on,
                        color: AppColors.neonGreen, size: 20),
                    const SizedBox(width: DesignConfig.spacingSm),
                    Text('${_detectedCampus.label} — ${_detectedCampus.city}',
                        style: AppTextStyles.sectionTitle),
                  ]))
              : const SizedBox.shrink(),
        ),
        const Spacer(flex: 2),
        SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
                onPressed: _nextPage, child: const Text('Continue'))),
        const SizedBox(height: DesignConfig.spacingXl),
      ]);

  Widget _sportPage() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: DesignConfig.spacingLg),
        Text('WHAT DO YOU PLAY?',
            style: AppTextStyles.bebas(DesignConfig.displayLg, height: 0.9)),
        const SizedBox(height: DesignConfig.spacingMd),
        Text('Select one or more sports', style: AppTextStyles.bodySecondary),
        const SizedBox(height: DesignConfig.spacingXl),
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
                            color:
                                sel ? AppColors.onAccent : AppColors.neonGreen),
                        const SizedBox(height: DesignConfig.spacingSm),
                        Text(sport.label,
                            style: AppTextStyles.selectionLabel(selected: sel)),
                      ]),
                ),
              );
            },
          ),
        ),
        Row(children: [
          TextButton(
              onPressed: _prevPage,
              child: Text('Back', style: AppTextStyles.linkUnderlined)),
          const Spacer(),
          SizedBox(
              height: 48,
              child: ElevatedButton(
                  onPressed: _selectedSports.isNotEmpty ? _nextPage : null,
                  child: const Text('Continue'))),
        ]),
        const SizedBox(height: DesignConfig.spacingXl),
      ]);

  Widget _skillPage() {
    final sports = _selectedSports.toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: DesignConfig.spacingLg),
      Text('RATE YOUR SKILLS',
          style: AppTextStyles.bebas(DesignConfig.displayLg, height: 0.9)),
      const SizedBox(height: DesignConfig.spacingMd),
      Text('Be honest — this helps with fair matchmaking!',
          style: AppTextStyles.bodySecondary),
      const SizedBox(height: DesignConfig.spacingXl),
      Expanded(
        child: ListView.separated(
          itemCount: sports.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: DesignConfig.spacingSm),
          itemBuilder: (context, index) {
            final sport = sports[index];
            final cur = _skillLevels[sport];
            return Container(
              padding: const EdgeInsets.all(DesignConfig.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(sport.icon, color: AppColors.neonGreen, size: 22),
                      const SizedBox(width: DesignConfig.spacingSm),
                      Text(sport.label, style: AppTextStyles.accentBody),
                    ]),
                    const SizedBox(height: DesignConfig.spacingMd),
                    Row(
                        children: SkillLevel.values.map((level) {
                      final sel = cur == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _skillLevels[sport] = level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                                horizontal: DesignConfig.spacingXs),
                            padding: const EdgeInsets.symmetric(
                                vertical: DesignConfig.spacingMd),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.neonGreen
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(
                                  DesignConfig.rounded2xl),
                              border: Border.all(
                                  color: sel
                                      ? AppColors.neonGreen
                                      : AppColors.border),
                            ),
                            child: Column(children: [
                              Icon(
                                level.icon,
                                size: 24,
                                color: sel
                                    ? AppColors.onAccent
                                    : AppColors.neonGreen,
                              ),
                              const SizedBox(height: DesignConfig.spacingXs),
                              Text(
                                level.label,
                                style: AppTextStyles.chatMeta.copyWith(
                                  color: sel
                                      ? AppColors.onAccent
                                      : AppColors.textSecondary,
                                ),
                              ),
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
            child: Text('Back', style: AppTextStyles.linkUnderlined)),
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
      const SizedBox(height: DesignConfig.spacingXl),
    ]);
  }
}
