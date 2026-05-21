import 'dart:typed_data';

import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
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
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await _client.from('profiles').update(profile.toMap()).eq('id', profile.id);
  }

  @override
  Future<String?> uploadProfileAvatar(
    String userId,
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      // RLS policy requires filename to start with userId as folder
      final fullPath = '$userId/$fileName';

      // Upload using uploadBinary for web and mobile compatibility
      await _client.storage
          .from('avatars')
          .uploadBinary(fullPath, Uint8List.fromList(imageBytes));

      // Return the public URL for the uploaded file.
      final url = _client.storage.from('avatars').getPublicUrl(fullPath);
      return url;
    } catch (e, st) {
      // Log full details and rethrow so BLoC can show the actual error.
      print('Avatar upload error: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  @override
  Future<void> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  }) async {
    await _client.from('profiles').update({
      'nim': nim,
      'campus': campus,
      'sport_preferences': sportPreferences,
      'skill_levels': skillLevels,
      'is_onboarded': true,
    }).eq('id', userId);
  }
}
