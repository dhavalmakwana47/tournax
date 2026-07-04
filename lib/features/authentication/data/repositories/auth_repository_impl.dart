import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.storageService,
    required this.networkInfo,
  });

  final AuthRemoteDatasource remoteDatasource;
  final SecureStorageService storageService;
  final NetworkInfo networkInfo;

  @override
  Future<LoginResult> login({
    required String emailOrUsername,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ApiException.noInternet();
    }

    final response = await remoteDatasource.login(
      LoginRequestModel(emailOrUsername: emailOrUsername, password: password),
    );

    final token = response.token;
    if (token == null || token.isEmpty) {
      throw const ApiException(message: 'Authentication token missing from response.');
    }

    final userJson = response.user?.toJson() ?? <String, dynamic>{};

    await Future.wait([
      storageService.saveToken(token),
      storageService.saveUser(userJson),
    ]);

    final user = response.user;

    return LoginResult(
      token: token,
      user: UserEntity(
        id: user!.id,
        name: user.name,
        email: user.email,
        username: user.username,
        role: user.role,
        avatar: user.avatar,
        permissions: user.permissions,
      ),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDatasource.logout();
    } finally {
      await storageService.clearAll();
    }
  }

  @override
  Future<void> register({
    required String role,
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.register(
      RegisterRequestModel(
        role: role,
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  @override
  Future<LoginResult> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final response = await remoteDatasource.verifyEmailOtp(
      VerifyOtpRequestModel(email: email, otp: otp),
    );
    final token = response.token;
    if (token == null || token.isEmpty) {
      throw const ApiException(message: 'Token missing after OTP verification.');
    }
    final user = response.user;
    final userJson = user?.toJson() ?? <String, dynamic>{};
    await Future.wait([
      storageService.saveToken(token),
      storageService.saveUser(userJson),
    ]);
    return LoginResult(
      token: token,
      user: UserEntity(
        id: user!.id,
        name: user.name,
        email: user.email,
        username: user.username,
        role: user.role,
        avatar: user.avatar,
        permissions: user.permissions,
      ),
    );
  }

  @override
  Future<void> resendEmailOtp(String email) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.resendEmailOtp(email);
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.forgotPassword(email);
  }

  @override
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    return remoteDatasource.verifyForgotPasswordOtp(email: email, otp: otp);
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.resetPassword(
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
