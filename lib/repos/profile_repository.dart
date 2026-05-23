import 'dart:io';
import 'package:beesports/models/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Future<void> updateProfile(ProfileEntity profile);

  Future<void> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  });

  Future<String?> uploadAvatar(String userId, File imageFile);
}
