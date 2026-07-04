import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<LoginResult> call({required String email, required String otp}) =>
      _repository.verifyEmailOtp(email: email, otp: otp);
}
