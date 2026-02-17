import 'dart:async';

import 'package:beesports/features/auth/domain/entities/user_entity.dart';
import 'package:beesports/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  static const _allowedDomain = 'binus.ac.id';

  AuthRepositoryImpl(this._client);

  void _validateDomain(String email) {
    final domain = email.split('@').last.toLowerCase();
    if (domain != _allowedDomain) {
      throw const AuthException('Only @$_allowedDomain emails are allowed.');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _validateDomain(email);
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } catch (e, st) {
      print('AuthRepositoryImpl.signUp error: $e');
      print('$st');
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String email,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('OTP verification failed.');
    }

    final userEntity = UserEntity(
      id: user.id,
      email: user.email ?? email,
      fullName: user.userMetadata?['full_name'] as String?,
    );

    await _upsertProfile(userEntity);
    return userEntity;
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    _validateDomain(email);

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign-in failed.');
    }

    return await _fetchProfile(user.id) ??
        UserEntity(
          id: user.id,
          email: user.email ?? email,
          fullName: user.userMetadata?['full_name'] as String?,
        );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return await _fetchProfile(user.id);
  }

  @override
  Future<void> saveUserProfile(UserEntity user) async {
    await _upsertProfile(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      return await _fetchProfile(user.id);
    });
  }

  Future<UserEntity?> _fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserEntity.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _upsertProfile(UserEntity user) async {
    await _client.from('profiles').upsert(user.toMap());
  }
}
