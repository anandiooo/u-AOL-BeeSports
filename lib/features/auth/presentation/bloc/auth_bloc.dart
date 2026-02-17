import 'package:beesports/features/auth/domain/entities/user_entity.dart';
import 'package:beesports/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
  @override
  List<Object?> get props => [email, password, fullName];
}

class OtpVerificationRequested extends AuthEvent {
  final String email;
  final String token;
  const OtpVerificationRequested({required this.email, required this.token});
  @override
  List<Object?> get props => [email, token];
}

class SignOutRequested extends AuthEvent {}

class OnboardingCompleted extends AuthEvent {
  final UserEntity user;
  const OnboardingCompleted(this.user);
  @override
  List<Object?> get props => [user];
}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class NeedsOnboarding extends AuthState {
  final UserEntity user;
  const NeedsOnboarding(this.user);
  @override
  List<Object?> get props => [user];
}

class NeedsOtpVerification extends AuthState {
  final String email;
  const NeedsOtpVerification(this.email);
  @override
  List<Object?> get props => [email];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<OtpVerificationRequested>(_onOtpVerification);
    on<SignOutRequested>(_onSignOut);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(Unauthenticated());
      } else if (!user.isOnboarded) {
        emit(NeedsOnboarding(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (!user.isOnboarded) {
        emit(NeedsOnboarding(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (e, st) {
      debugPrint('AuthBloc._onSignIn error: $e');
      debugPrint('$st');
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignUp(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      emit(NeedsOtpVerification(event.email));
    } catch (e, st) {
      debugPrint('AuthBloc._onSignUp error: $e');
      debugPrint('$st');
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onOtpVerification(
    OtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyOtp(
        email: event.email,
        token: event.token,
      );
      emit(NeedsOnboarding(user));
    } catch (e, st) {
      debugPrint('AuthBloc._onOtpVerification error: $e');
      debugPrint('$st');
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.saveUserProfile(event.user);
      emit(Authenticated(event.user));
    } catch (e, st) {
      debugPrint('AuthBloc._onOnboardingCompleted error: $e');
      debugPrint('$st');
      emit(AuthError(_friendlyError(e)));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('binus.ac.id')) {
      return 'Only @binus.ac.id emails are allowed.';
    }
    if (msg.contains('Invalid login')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Please verify your email first.';
    }
    if (msg.contains('already registered')) {
      return 'This email is already registered. Try signing in.';
    }
    return 'Something went wrong. Please try again.';
  }
}
