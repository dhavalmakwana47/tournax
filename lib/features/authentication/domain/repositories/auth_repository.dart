import '../entities/login_result.dart';

abstract interface class AuthRepository {
  Future<LoginResult> login({
    required String emailOrUsername,
    required String password,
  });

  Future<void> logout();

  Future<void> register({
    required String role,
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<LoginResult> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<void> resendEmailOtp(String email);
  Future<void> forgotPassword(String email);
  Future<String> verifyForgotPasswordOtp({required String email, required String otp});
  Future<void> resetPassword({required String resetToken, required String password, required String passwordConfirmation});
}
