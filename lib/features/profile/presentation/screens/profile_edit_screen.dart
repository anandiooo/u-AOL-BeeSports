import 'package:beesports/core/theme/app_colors.dart';
import 'package:beesports/features/profile/domain/entities/profile_entity.dart';
import 'package:beesports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:beesports/shared/models/skill_level.dart';
import 'package:beesports/shared/models/sport_type.dart';
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
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
          ProfileEntity? profile;
          if (state is ProfileLoaded) profile = state.profile;
          if (state is ProfileUpdateSuccess) profile = state.profile;

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _initFromProfile(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: const InputDecoration(
                    hintText: 'Tell others about yourself...',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sport Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SportType.values.map((sport) {
                    final isSelected = _selectedSports.contains(sport);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(sport.label),
                      avatar: Icon(sport.icon,
                          size: 18,
                          color: isSelected ? sport.color : Colors.white54),
                      selectedColor: sport.color.withValues(alpha: 0.2),
                      checkmarkColor: sport.color,
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
                const SizedBox(height: 24),
                if (_selectedSports.isNotEmpty) ...[
                  const Text(
                    'Skill Levels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedSports.map((sport) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(sport.icon, color: sport.color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                sport.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                        horizontal: 3),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? sport.color.withValues(alpha: 0.2)
                                          : AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isActive
                                            ? sport.color
                                            : Colors.white
                                                .withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${level.emoji} ${level.label}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: isActive
                                              ? sport.color
                                              : Colors.white54,
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (profile != null) _onSave(profile);
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
