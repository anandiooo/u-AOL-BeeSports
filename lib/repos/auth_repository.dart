import 'package:beesports/models/user_entity.dart';
import 'package:beesports/core/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<UserEntity>> verifyOtp({
    required String email,
    required String token,
  });

  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<void>> saveUserProfile(UserEntity user);

  Stream<UserEntity?> get authStateChanges;
}
