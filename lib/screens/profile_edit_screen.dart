import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/models/skill_level.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _bioController = TextEditingController();
  final _nameController = TextEditingController();
  final Set<SportType> _selectedSports = {};
  final Map<SportType, SkillLevel> _skillLevels = {};
  bool _initialized = false;
  bool _attemptedSave = false;
  ProfileEntity? _currentProfile;

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _initFromProfile(ProfileEntity profile) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = profile.fullName ?? '';
    _bioController.text = profile.bio;
    _selectedSports.addAll(profile.sportPreferences);
    _skillLevels.addAll(profile.skillLevels);
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && _currentProfile != null) {
        // Read bytes from XFile (works on both web and mobile)
        final bytes = await image.readAsBytes();
        // Generate filename with extension
        final extension =
            image.name.contains('.') ? image.name.split('.').last : 'jpg';
        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

        if (mounted) {
          context.read<ProfileBloc>().add(
                ProfileAvatarUploadRequested(
                  _currentProfile!.id,
                  bytes,
                  fileName,
                  _currentProfile!,
                ),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onSave(ProfileEntity current) {
    setState(() => _attemptedSave = true);

    // Validate: every selected sport must have a skill level
    final missingSports = _selectedSports
        .where((sport) => !_skillLevels.containsKey(sport))
        .toList();

    if (missingSports.isNotEmpty) {
      final names = missingSports.map((s) => s.label).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a skill level for: $names',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.sale,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final updated = current.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      bio: _bioController.text.trim(),
      sportPreferences: _selectedSports.toList(),
      skillLevels: Map.from(_skillLevels),
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            FeedbackService.showSuccess(
                context, 'Profile updated successfully');
            context.pop();
          }
          if (state is ProfileError) {
            FeedbackService.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          if (state is ProfileLoaded) _currentProfile = state.profile;
          if (state is ProfileUpdateSuccess) _currentProfile = state.profile;
          if (_currentProfile == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen));
          }
          _initFromProfile(_currentProfile!);

          return Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(children: [
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                  color: AppColors.neonGreen,
                                  shape: BoxShape.circle),
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: _currentProfile!.avatarUrl != null &&
                                            _currentProfile!
                                                .avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            _currentProfile!.avatarUrl!,
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  (_nameController.text
                                                              .trim()
                                                              .isEmpty
                                                          ? _currentProfile!
                                                                  .fullName ??
                                                              'U'
                                                          : _nameController.text
                                                              .trim())[0]
                                                      .toUpperCase(),
                                                  style: GoogleFonts.bebasNeue(
                                                    fontSize: 32,
                                                    color: AppColors.onAccent,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Text(
                                              (_nameController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? _currentProfile!
                                                              .fullName ??
                                                          'U'
                                                      : _nameController.text
                                                          .trim())[0]
                                                  .toUpperCase(),
                                              style: GoogleFonts.bebasNeue(
                                                fontSize: 32,
                                                color: AppColors.onAccent,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.24),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            style: GoogleFonts.inter(
                                color: AppColors.neonGreen, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Display name',
                              hintText: 'Enter your username',
                              labelStyle: GoogleFonts.inter(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Click on the profile picture to change your avatar',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.3)),
                          const SizedBox(height: 12),
                          Text(_currentProfile!.email,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                      ),
                      const SizedBox(height: 32),
                      Text('Bio',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                        style: GoogleFonts.inter(
                            color: AppColors.neonGreen, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Write a short bio here',
                          counterStyle: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text('Sports Preferences',
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neonGreen)),
                      const SizedBox(height: 8),
                      Text('Select the sports you want to play',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SportType.values.map((sport) {
                          final sel = _selectedSports.contains(sport);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel) {
                                _selectedSports.remove(sport);
                                _skillLevels.remove(sport);
                              } else {
                                _selectedSports.add(sport);
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
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
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(sport.icon,
                                        size: 14,
                                        color: sel
                                            ? AppColors.onAccent
                                            : AppColors.neonGreen),
                                    const SizedBox(width: 6),
                                    Text(sport.label,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: sel
                                                ? AppColors.onAccent
                                                : AppColors.neonGreen)),
                                  ]),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48),
                      if (_selectedSports.isNotEmpty) ...[
                        Text('Skill Levels',
                            style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neonGreen)),
                        const SizedBox(height: 8),
                        Text('Set your experience level for each sport',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 18),
                        ..._selectedSports.map((sport) {
                          final isMissing = _attemptedSave &&
                              !_skillLevels.containsKey(sport);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              border: isMissing
                                  ? Border.all(
                                      color: AppColors.sale, width: 1.5)
                                  : null,
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(sport.icon,
                                        color: isMissing
                                            ? AppColors.sale
                                            : AppColors.neonGreen,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(sport.label,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: isMissing
                                                ? AppColors.sale
                                                : AppColors.neonGreen)),
                                    if (isMissing) ...[
                                      const Spacer(),
                                      Text('Required',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.sale)),
                                    ],
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(
                                      children: SkillLevel.values.map((level) {
                                    final active = _skillLevels[sport] == level;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _skillLevels[sport] = level),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? AppColors.neonGreen
                                                : AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                                color: active
                                                    ? AppColors.neonGreen
                                                    : AppColors.border),
                                          ),
                                          child: Center(
                                            child: Text(
                                                '${level.emoji} ${level.label.substring(0, 3)}.',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: active
                                                        ? FontWeight.w500
                                                        : FontWeight.w400,
                                                    color: active
                                                        ? AppColors.onPrimary
                                                        : AppColors
                                                            .textSecondary)),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList()),
                                  if (isMissing) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please select your skill level for ${sport.label}',
                                      style: GoogleFonts.inter(
                                          fontSize: 11, color: AppColors.sale),
                                    ),
                                  ],
                                ]),
                          );
                        }),
                      ],
                    ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_currentProfile != null) {
                              _onSave(_currentProfile!);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.onAccent))
                        : const Text('Save Changes'),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
