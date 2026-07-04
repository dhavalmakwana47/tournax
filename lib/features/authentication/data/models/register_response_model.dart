class RegisterResponseModel {
  const RegisterResponseModel({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}
