import 'package:beesports/models/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Future<void> updateProfile(ProfileEntity profile);

  Future<String?> uploadProfileAvatar(
    String userId,
    List<int> imageBytes,
    String fileName,
  );

  Future<void> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  });
}
