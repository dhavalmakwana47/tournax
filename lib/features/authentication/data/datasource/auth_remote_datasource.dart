import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/verify_otp_response_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<VerifyOtpResponseModel> verifyEmailOtp(VerifyOtpRequestModel request);
  Future<void> resendEmailOtp(String email);
  Future<void> forgotPassword(String email);
  Future<String> verifyForgotPasswordOtp({required String email, required String otp});
  Future<void> resetPassword({required String resetToken, required String password, required String passwordConfirmation});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final formData = FormData.fromMap({
        'email_or_username': request.emailOrUsername,
        'password': request.password,
      });

      final response = await _apiClient.post(
        ApiConstants.login,
        data: formData,
      );

      appLogger.d('Login raw response: $response');

      final data = response['data'] as Map<String, dynamic>?;
      appLogger.d('User raw data: ${data?["user"]}');

      final model = LoginResponseModel.fromJson(response);

      if (!model.success) {
        throw ApiException(message: model.message);
      }

      return model;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Login parse error', error: e, stackTrace: st);
      throw ApiException(message: 'Failed to parse login response.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Logout error', error: e, stackTrace: st);
      throw ApiException(message: 'Logout failed.');
    }
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      final model = RegisterResponseModel.fromJson(response);
      if (!model.success) throw ApiException(message: model.message);
      return model;
    } on ApiException catch (e) {
      appLogger.e('Register failed: ${e.message} | fieldErrors: ${e.fieldErrors}', error: e);
      rethrow;
    } catch (e, st) {
      appLogger.e('Register error', error: e, stackTrace: st);
      throw ApiException(message: 'Registration failed.');
    }
  }

  @override
  Future<VerifyOtpResponseModel> verifyEmailOtp(VerifyOtpRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyEmailOtp,
        data: request.toJson(),
      );
      final model = VerifyOtpResponseModel.fromJson(response);
      if (!model.success) throw ApiException(message: model.message);
      return model;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Verify OTP error', error: e, stackTrace: st);
      throw ApiException(message: 'OTP verification failed.');
    }
  }

  @override
  Future<void> resendEmailOtp(String email) async {
    try {
      await _apiClient.post(
        ApiConstants.resendEmailOtp,
        data: {'email': email},
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Resend OTP error', error: e, stackTrace: st);
      throw ApiException(message: 'Failed to resend OTP.');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Forgot password error', error: e, stackTrace: st);
      throw ApiException(message: 'Failed to send reset OTP.');
    }
  }

  @override
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyForgotPasswordOtp,
        data: {'email': email, 'otp': otp},
      );
      final resetToken = response['reset_token'] as String?;
      if (resetToken == null || resetToken.isEmpty) {
        throw const ApiException(message: 'Reset token missing from response.');
      }
      return resetToken;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Verify forgot OTP error', error: e, stackTrace: st);
      throw ApiException(message: 'OTP verification failed.');
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Reset password error', error: e, stackTrace: st);
      throw ApiException(message: 'Password reset failed.');
    }
  }
}
