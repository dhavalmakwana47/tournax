import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

String? _timestampToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class ProfileModel {
  const ProfileModel({
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

  @JsonKey(name: 'email_verified_at', fromJson: _timestampToString)
  final String? emailVerifiedAt;

  @JsonKey(fromJson: _timestampToString)
  final String? status;

  @JsonKey(name: 'last_login_at', fromJson: _timestampToString)
  final String? lastLoginAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
