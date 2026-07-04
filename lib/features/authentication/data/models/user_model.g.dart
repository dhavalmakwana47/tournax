// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  role: json['role'] as String,
  avatar: json['avatar'] as String?,
  permissions: json['permissions'] as List<dynamic>? ?? const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'role': instance.role,
  'avatar': instance.avatar,
  'permissions': instance.permissions,
};
