import 'package:beesports/models/user_entity.dart';
import 'package:beesports/repos/auth_repository.dart';
import 'package:equatable/equatable.dart';
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
    on<SignOutRequested>(_onSignOut);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.getCurrentUser();
    result.when(
      success: (user) {
        if (user == null) {
          emit(Unauthenticated());
        } else if (!user.isOnboarded) {
          emit(NeedsOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
      failure: (_) {
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onSignIn(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    result.when(
      success: (user) {
        if (!user.isOnboarded) {
          emit(NeedsOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
      failure: (f) {
        emit(AuthError(f.message));
      },
    );
  }

  Future<void> _onSignUp(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signUp(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );
    result.when(
      success: (user) {
        if (!user.isOnboarded) {
          emit(NeedsOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
      failure: (f) {
        emit(AuthError(f.message));
      },
    );
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
    emit(Authenticated(event.user));
  }
}
