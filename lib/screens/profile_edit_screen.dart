import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/models/skill_level.dart';
import 'dart:io';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _bioController = TextEditingController();
  final _nameController = TextEditingController();
  final Set<SportType> _selectedSports = {};
  File? _avatarFile;
  final _imagePicker = ImagePicker();
  final Map<SportType, SkillLevel> _skillLevels = {};
  bool _initialized = false;
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
    _bioController.text = profile.bio;
    _nameController.text = profile.fullName ?? '';
    _selectedSports.addAll(profile.sportPreferences);
    _skillLevels.addAll(profile.skillLevels);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  void _onSave(ProfileEntity current) {
    final updated = current.copyWith(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      sportPreferences: _selectedSports.toList(),
      skillLevels: Map.from(_skillLevels),
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated, avatarFile: _avatarFile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foursier,
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.primary)),
        backgroundColor: AppColors.foursier,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.secondary));
            context.pop();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.tersierDark));
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          if (state is ProfileLoaded) _currentProfile = state.profile;
          if (state is ProfileUpdateSuccess) _currentProfile = state.profile;
          if (_currentProfile == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          _initFromProfile(_currentProfile!);

          return Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Column(children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      image: _avatarFile != null
                                          ? DecorationImage(
                                              image: FileImage(_avatarFile!),
                                              fit: BoxFit.cover,
                                            )
                                          : _currentProfile!.avatarUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(_currentProfile!.avatarUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                      ),
                                  child: (_avatarFile == null && _currentProfile!.avatarUrl == null)
                                      ? Center(
                                          child: Text(
                                              (_currentProfile!.fullName ?? 'U').isNotEmpty ? (_currentProfile!.fullName ?? 'U')[0].toUpperCase() : 'U',
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 32,
                                                  color: AppColors.foursierLight)),
                                        )
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(_currentProfile!.email,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.primaryLight)),
                        ]),
                      ),
                      const SizedBox(height: 32),

                      Text('Full Name',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryLight)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(
                            color: AppColors.primary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Bio',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryLight)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                        style: GoogleFonts.inter(
                            color: AppColors.primary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Write a short bio here',
                          counterStyle: GoogleFonts.inter(
                              color: AppColors.primaryLight, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Text('Sports Preferences',
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Text('Select the sports you want to play',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.primaryLight)),
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
                                    ? AppColors.primary
                                    : AppColors.foursier,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.foursierDark),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(sport.icon,
                                        size: 14,
                                        color: sel
                                            ? AppColors.foursierLight
                                            : AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(sport.label,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: sel
                                                ? AppColors.foursierLight
                                                : AppColors.primary)),
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
                                color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text('Set your experience level for each sport',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.primaryLight)),
                        const SizedBox(height: 18),
                        ..._selectedSports.map((sport) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            color: AppColors.secondaryLight,
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(sport.icon,
                                        color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(sport.label,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: AppColors.primary)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(
                                      children:
                                          SkillLevel.values.map((level) {
                                    final active =
                                        _skillLevels[sport] == level;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() =>
                                            _skillLevels[sport] = level),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          margin: const EdgeInsets
                                              .symmetric(horizontal: 3),
                                          padding: const EdgeInsets
                                              .symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? AppColors.primary
                                                : AppColors.foursier,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                                color: active
                                                    ? AppColors.primary
                                                    : AppColors.foursierDark),
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
                                                        ? AppColors
                                                            .onPrimary
                                                        : AppColors.primaryLight)),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList()),
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
                color: AppColors.foursier,
                border: Border(
                    top: BorderSide(color: AppColors.tersierLight)),
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
                                strokeWidth: 2,
                                color: AppColors.foursierLight))
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
