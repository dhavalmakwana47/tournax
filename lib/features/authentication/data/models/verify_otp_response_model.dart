import 'user_model.dart';

class VerifyOtpResponseModel {
  const VerifyOtpResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return VerifyOtpResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: data?['access_token'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
