import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

enum LoginStatus { initial, loading, success, error }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
    this.obscurePassword = true,
    this.rememberMe = false,
  });

  final LoginStatus status;
  final String? errorMessage;
  final UserEntity? user;
  final bool obscurePassword;
  final bool rememberMe;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    UserEntity? user,
    bool? obscurePassword,
    bool? rememberMe,
    bool clearError = false,
  }) =>
      LoginState(
        status: status ?? this.status,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        user: user ?? this.user,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        rememberMe: rememberMe ?? this.rememberMe,
      );

  @override
  List<Object?> get props => [status, errorMessage, user, obscurePassword, rememberMe];
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    _loadRememberMe();
    return const LoginState();
  }

  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);

  Future<void> _loadRememberMe() async {
    final remembered = await _storage.getRememberMe();
    state = state.copyWith(rememberMe: remembered);
  }

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    state = state.copyWith(status: LoginStatus.loading, clearError: true);

    try {
      final result = await _loginUseCase(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      await _storage.saveRememberMe(value: state.rememberMe);

      state = state.copyWith(status: LoginStatus.success, user: result.user);

      // Push token into AuthNotifier — triggers router redirect to home.
      authNotifier.setToken(result.token);
    } on ApiException catch (e) {
      appLogger.e('Login failed', error: e);
      state = state.copyWith(status: LoginStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected login error', error: e);
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
