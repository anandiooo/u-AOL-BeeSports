import 'dart:io';
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

  @override
  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'public/$fileName';
      
      await _client.storage.from('avatars').upload(path, imageFile);
      
      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
