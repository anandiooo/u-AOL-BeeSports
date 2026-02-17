import 'package:beesports/core/di/injection_container.dart';
import 'package:beesports/core/theme/app_colors.dart';
import 'package:beesports/features/auth/domain/entities/campus.dart';
import 'package:beesports/features/auth/domain/entities/user_entity.dart';
import 'package:beesports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:beesports/features/profile/domain/repositories/profile_repository.dart';
import 'package:beesports/shared/models/skill_level.dart';
import 'package:beesports/shared/models/sport_type.dart';
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

  void _onNimChanged(String nim) {
    setState(() {
      _detectedCampus = Campus.fromNim(nim);
    });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_nimController.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid 10-digit NIM')),
        );
        return;
      }
    }
    if (_currentPage == 1) {
      if (_selectedSports.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one sport')),
        );
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onSubmit() async {
    for (final sport in _selectedSports) {
      if (!_skillLevels.containsKey(sport)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Set skill level for ${sport.label}')),
        );
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
        skillLevels: _skillLevels.map(
          (sport, level) => MapEntry(sport.name, level.name),
        ),
      );

      if (mounted) {
        context.read<AuthBloc>().add(OnboardingCompleted(
              widget.user.copyWith(
                nim: _nimController.text.trim(),
                campus: _detectedCampus.label,
                isOnboarded: true,
              ),
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _currentPage
                            ? AppColors.primary
                            : AppColors.cardDark,
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildNimPage(),
                  _buildSportPage(),
                  _buildSkillPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNimPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          const Text(
            'Enter Your NIM',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll auto-detect your campus',
            style: TextStyle(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nimController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
            decoration: const InputDecoration(
              hintText: '2502000000',
              counterText: '',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onChanged: _onNimChanged,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _detectedCampus != Campus.unknown
                ? Container(
                    key: ValueKey(_detectedCampus),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_detectedCampus.label} — ${_detectedCampus.city}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSportPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'What Do You Play?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more sports',
            style: TextStyle(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: SportType.values.length,
              itemBuilder: (context, index) {
                final sport = SportType.values[index];
                final isSelected = _selectedSports.contains(sport);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSports.remove(sport);
                        _skillLevels.remove(sport);
                      } else {
                        _selectedSports.add(sport);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? sport.color.withValues(alpha: 0.15)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? sport.color
                            : Colors.white.withValues(alpha: 0.05),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sport.icon,
                          size: 32,
                          color: isSelected ? sport.color : Colors.white54,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sport.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? sport.color : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _prevPage,
                child: const Text('Back'),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedSports.isNotEmpty ? _nextPage : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSkillPage() {
    final sports = _selectedSports.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Rate Your Skills',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Be honest — this helps with fair matchmaking!',
            style: TextStyle(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: sports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final sport = sports[index];
                final currentLevel = _skillLevels[sport];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(sport.icon, color: sport.color, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            sport.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: SkillLevel.values.map((level) {
                          final isSelected = currentLevel == level;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _skillLevels[sport] = level);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? sport.color.withValues(alpha: 0.2)
                                      : AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? sport.color
                                        : Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(level.emoji,
                                        style: const TextStyle(fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(
                                      level.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? sport.color
                                            : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _prevPage,
                child: const Text('Back'),
              ),
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
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text("Let's Go! 🐝"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
