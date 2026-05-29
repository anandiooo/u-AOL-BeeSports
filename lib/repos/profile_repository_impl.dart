import 'dart:typed_data';

import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<Result<ProfileEntity?>> getProfile(String userId) async {
    return withRetry(() async {
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data == null) return null;
        return ProfileEntity.fromMap(data);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<Result<void>> updateProfile(ProfileEntity profile) async {
    return withRetry(() async {
      await _client
          .from('profiles')
          .update(profile.toMap())
          .eq('id', profile.id);
    });
  }

  @override
  Future<Result<String?>> uploadProfileAvatar(
    String userId,
    List<int> imageBytes,
    String fileName,
  ) async {
    return withRetry(() async {
      final fullPath = '$userId/$fileName';

      await _client.storage
          .from('avatars')
          .uploadBinary(fullPath, Uint8List.fromList(imageBytes));

      final url = _client.storage.from('avatars').getPublicUrl(fullPath);
      return url;
    });
  }

  @override
  Future<Result<void>> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  }) async {
    return withRetry(() async {
      await _client.from('profiles').update({
        'nim': nim,
        'campus': campus,
        'sport_preferences': sportPreferences,
        'skill_levels': skillLevels,
        'is_onboarded': true,
      }).eq('id', userId);
    });
  }
}
