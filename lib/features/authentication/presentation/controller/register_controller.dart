import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/app_logger.dart';

enum RegisterStatus { initial, loading, success, error }

enum OtpStatus { initial, loading, success, error, resending }

class RegisterState extends Equatable {
  const RegisterState({
    this.registerStatus = RegisterStatus.initial,
    this.otpStatus = OtpStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.registeredEmail,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.selectedRole = 'player',
  });

  final RegisterStatus registerStatus;
  final OtpStatus otpStatus;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? registeredEmail;
  final bool obscurePassword;
  final bool obscureConfirm;
  final String selectedRole;

  RegisterState copyWith({
    RegisterStatus? registerStatus,
    OtpStatus? otpStatus,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? registeredEmail,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? selectedRole,
    bool clearError = false,
  }) =>
      RegisterState(
        registerStatus: registerStatus ?? this.registerStatus,
        otpStatus: otpStatus ?? this.otpStatus,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
        registeredEmail: registeredEmail ?? this.registeredEmail,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscureConfirm: obscureConfirm ?? this.obscureConfirm,
        selectedRole: selectedRole ?? this.selectedRole,
      );

  @override
  List<Object?> get props => [
        registerStatus,
        otpStatus,
        errorMessage,
        fieldErrors,
        registeredEmail,
        obscurePassword,
        obscureConfirm,
        selectedRole,
      ];
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  void setRole(String role) => state = state.copyWith(selectedRole: role);

  void clearFieldErrors() =>
      state = state.copyWith(fieldErrors: const {}, clearError: true);

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(registerStatus: RegisterStatus.loading, clearError: true);
    try {
      await ref.read(registerUseCaseProvider).call(
            role: state.selectedRole,
            name: name,
            username: username,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      state = state.copyWith(
        registerStatus: RegisterStatus.success,
        registeredEmail: email,
      );
    } on ApiException catch (e) {
      appLogger.e('Register failed', error: e);
      state = state.copyWith(
        registerStatus: RegisterStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      appLogger.e('Unexpected register error', error: e);
      state = state.copyWith(
        registerStatus: RegisterStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(otpStatus: OtpStatus.loading, clearError: true);
    try {
      final result = await ref.read(verifyOtpUseCaseProvider).call(
            email: email,
            otp: otp,
          );
      state = state.copyWith(otpStatus: OtpStatus.success);
      authNotifier.setToken(result.token);
    } on ApiException catch (e) {
      appLogger.e('OTP verification failed', error: e);
      state = state.copyWith(otpStatus: OtpStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected OTP error', error: e);
      state = state.copyWith(
        otpStatus: OtpStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> resendOtp(String email) async {
    state = state.copyWith(otpStatus: OtpStatus.resending, clearError: true);
    try {
      await ref.read(resendOtpUseCaseProvider).call(email);
      state = state.copyWith(otpStatus: OtpStatus.initial);
    } on ApiException catch (e) {
      appLogger.e('Resend OTP failed', error: e);
      state = state.copyWith(otpStatus: OtpStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        otpStatus: OtpStatus.error,
        errorMessage: 'Failed to resend OTP.',
      );
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
