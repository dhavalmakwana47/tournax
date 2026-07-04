// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  username: json['username'] as String?,
  email: json['email'] as String,
  role: json['role'] as String,
  emailVerifiedAt: _timestampToString(json['email_verified_at']),
  status: _timestampToString(json['status']),
  lastLoginAt: _timestampToString(json['last_login_at']),
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'email_verified_at': instance.emailVerifiedAt,
      'status': instance.status,
      'last_login_at': instance.lastLoginAt,
    };
