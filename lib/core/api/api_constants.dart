abstract final class ApiConstants {
  static const String baseUrl = 'http://10.156.114.115:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  static const String verifyEmailOtp = '/verify-email-otp';
  static const String resendEmailOtp = '/resend-email-otp';
  static const String profile = '/profile';

  static const String forgotPassword = '/forgot-password';
  static const String verifyForgotPasswordOtp = '/verify-forgot-password-otp';
  static const String resetPassword = '/reset-password';
}
