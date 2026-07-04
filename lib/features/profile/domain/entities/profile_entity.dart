import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.emailVerifiedAt,
    this.status,
    this.lastLoginAt,
  });

  final int id;
  final String name;
  final String? username;
  final String email;
  final String role;
  final String? emailVerifiedAt;
  final String? status;
  final String? lastLoginAt;

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        role,
        emailVerifiedAt,
        status,
        lastLoginAt,
      ];
}
