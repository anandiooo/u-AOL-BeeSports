import 'package:beesports/models/profile_entity.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileEntity profile;
  const ProfileUpdateRequested(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final String userId;
  final List<int> imageBytes;
  final String fileName;
  final ProfileEntity currentProfile;
  const ProfileAvatarUploadRequested(
    this.userId,
    this.imageBytes,
    this.fileName,
    this.currentProfile,
  );
  @override
  List<Object?> get props => [userId, imageBytes, fileName, currentProfile];
}

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntity profile;
  const ProfileUpdateSuccess(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileAvatarUploadRequested>(_onAvatarUpload);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _profileRepository.getProfile(event.userId);
    result.when(
      success: (profile) {
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileError('Profile not found.'));
        }
      },
      failure: (f) {
        emit(ProfileError(f.message));
      },
    );
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _profileRepository.updateProfile(event.profile);
    result.when(
      success: (_) {
        emit(ProfileUpdateSuccess(event.profile));
      },
      failure: (f) {
        emit(ProfileError(f.message));
      },
    );
  }

  Future<void> _onAvatarUpload(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _profileRepository.uploadProfileAvatar(
      event.userId,
      event.imageBytes,
      event.fileName,
    );

    await result.when(
      success: (avatarUrl) async {
        final updated = event.currentProfile.copyWith(avatarUrl: avatarUrl);
        final updateResult = await _profileRepository.updateProfile(updated);
        updateResult.when(
          success: (_) {
            emit(ProfileUpdateSuccess(updated));
          },
          failure: (f) {
            emit(ProfileError(f.message));
          },
        );
      },
      failure: (f) async {
        emit(ProfileError(f.message));
      },
    );
  }
}
