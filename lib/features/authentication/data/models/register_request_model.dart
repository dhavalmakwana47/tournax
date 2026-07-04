import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.role,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  final String role;
  final String name;
  final String username;
  final String email;
  final String password;

  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);
}
