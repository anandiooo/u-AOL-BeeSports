import 'package:beesports/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserEntity> verifyOtp({
    required String email,
    required String token,
  });

  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<void> saveUserProfile(UserEntity user);

  Stream<UserEntity?> get authStateChanges;
}
