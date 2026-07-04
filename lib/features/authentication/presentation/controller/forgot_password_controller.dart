import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_forgot_password_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

enum ForgotPasswordStep { email, otp, reset }

enum ForgotPasswordStatus { idle, loading, success, error }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.status = ForgotPasswordStatus.idle,
    this.email = '',
    this.resetToken,
    this.errorMessage,
    this.fieldErrors = const {},
    this.obscurePassword = true,
    this.obscureConfirm = true,
  });

  final ForgotPasswordStep step;
  final ForgotPasswordStatus status;
  final String email;
  final String? resetToken;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool obscurePassword;
  final bool obscureConfirm;

  String? fieldError(String key) => fieldErrors[key];

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    ForgotPasswordStatus? status,
    String? email,
    String? resetToken,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool clearError = false,
  }) =>
      ForgotPasswordState(
        step: step ?? this.step,
        status: status ?? this.status,
        email: email ?? this.email,
        resetToken: resetToken ?? this.resetToken,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      );

  @override
  List<Object?> get props =>
      [step, status, email, resetToken, errorMessage, fieldErrors, obscurePassword, obscureConfirm];
}

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  ForgotPasswordUseCase get _forgotUseCase =>
      ref.read(forgotPasswordUseCaseProvider);
  VerifyForgotPasswordOtpUseCase get _verifyOtpUseCase =>
      ref.read(verifyForgotPasswordOtpUseCaseProvider);
  ResetPasswordUseCase get _resetUseCase =>
      ref.read(resetPasswordUseCaseProvider);

  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  Future<void> sendOtp(String email) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      email: email,
      clearError: true,
    );
    try {
      await _forgotUseCase(email);
      state = state.copyWith(
        status: ForgotPasswordStatus.success,
        step: ForgotPasswordStep.otp,
      );
    } on ApiException catch (e) {
      appLogger.e('Forgot password error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      appLogger.e('Unexpected forgot password error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      clearError: true,
    );
    try {
      final resetToken = await _verifyOtpUseCase(
        email: state.email,
        otp: otp,
      );
      state = state.copyWith(
        status: ForgotPasswordStatus.success,
        resetToken: resetToken,
        step: ForgotPasswordStep.reset,
      );
    } on ApiException catch (e) {
      appLogger.e('Verify forgot OTP error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      appLogger.e('Unexpected verify OTP error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: 'OTP verification failed. Please try again.',
      );
    }
  }

  Future<void> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      clearError: true,
    );
    try {
      await _resetUseCase(
        resetToken: state.resetToken!,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(status: ForgotPasswordStatus.success);
    } on ApiException catch (e) {
      appLogger.e('Reset password error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      appLogger.e('Unexpected reset password error', error: e);
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        errorMessage: 'Password reset failed. Please try again.',
      );
    }
  }

  void resetState() => state = const ForgotPasswordState();
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);
