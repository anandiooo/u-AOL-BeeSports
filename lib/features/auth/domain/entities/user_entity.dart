import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? nim;
  final String? campus;
  final String role;
  final String? avatarUrl;
  final bool isOnboarded;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.nim,
    this.campus,
    this.role = 'player',
    this.avatarUrl,
    this.isOnboarded = false,
    this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nim,
    String? campus,
    String? role,
    String? avatarUrl,
    bool? isOnboarded,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nim: nim ?? this.nim,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      nim: map['nim'] as String?,
      campus: map['campus'] as String?,
      role: (map['role'] as String?) ?? 'player',
      avatarUrl: map['avatar_url'] as String?,
      isOnboarded: (map['is_onboarded'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'nim': nim,
      'campus': campus,
      'role': role,
      'avatar_url': avatarUrl,
      'is_onboarded': isOnboarded,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        nim,
        campus,
        role,
        avatarUrl,
        isOnboarded,
        createdAt,
      ];
}
