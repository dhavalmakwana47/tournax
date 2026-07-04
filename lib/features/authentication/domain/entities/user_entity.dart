import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.avatar,
    this.permissions = const [],
  });

  final int id;
  final String name;
  final String email;
  final String username;
  final String role;
  final String? avatar;
  final List<dynamic> permissions;

  @override
  List<Object?> get props => [id, name, email, username, role, avatar, permissions];
}
