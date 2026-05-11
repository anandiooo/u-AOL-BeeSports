import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/models/skill_level.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _bioController = TextEditingController();
  final Set<SportType> _selectedSports = {};
  final Map<SportType, SkillLevel> _skillLevels = {};
  bool _initialized = false;
  ProfileEntity? _currentProfile;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _initFromProfile(ProfileEntity profile) {
    if (_initialized) return;
    _initialized = true;
    _bioController.text = profile.bio;
    _selectedSports.addAll(profile.sportPreferences);
    _skillLevels.addAll(profile.skillLevels);
  }

  void _onSave(ProfileEntity current) {
    final updated = current.copyWith(
      bio: _bioController.text.trim(),
      sportPreferences: _selectedSports.toList(),
      skillLevels: Map.from(_skillLevels),
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          if (state is ProfileLoaded) _currentProfile = state.profile;
          if (state is ProfileUpdateSuccess) _currentProfile = state.profile;

          if (_currentProfile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          _initFromProfile(_currentProfile!);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // avatar header
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (_currentProfile!.fullName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentProfile!.fullName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  _currentProfile!.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimaryDark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // form section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textPrimaryDark.withValues(alpha: 0.05),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 150,
                    style: const TextStyle(color: AppColors.textPrimaryDark),
                    decoration: InputDecoration(
                      hintText:
                          'Tell others about yourself and your play style...',
                      hintStyle: TextStyle(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.3),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterStyle: TextStyle(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sport Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: SportType.values.map((sport) {
                    final isSelected = _selectedSports.contains(sport);
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
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSports.add(sport);
                          } else {
                            _selectedSports.remove(sport);
                            _skillLevels.remove(sport);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                if (_selectedSports.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skill Levels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._selectedSports.map((sport) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: sport.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(sport.icon,
                                    color: sport.color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                sport.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: SkillLevel.values.map((level) {
                              final isActive = _skillLevels[sport] == level;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _skillLevels[sport] = level);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? sport.color
                                          : AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? sport.color
                                            : AppColors.textPrimaryDark
                                                .withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${level.emoji} ${level.label}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isActive
                                              ? AppColors.backgroundDark
                                              : AppColors.textPrimaryDark
                                                  .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_currentProfile != null) {
                              _onSave(_currentProfile!);
                            }
                          },
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
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
