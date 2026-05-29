import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/core/result.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity?>> getProfile(String userId);

  Future<Result<void>> updateProfile(ProfileEntity profile);

  Future<Result<String?>> uploadProfileAvatar(
    String userId,
    List<int> imageBytes,
    String fileName,
  );

  Future<Result<void>> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  });
}
