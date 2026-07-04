import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: data?['access_token'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
