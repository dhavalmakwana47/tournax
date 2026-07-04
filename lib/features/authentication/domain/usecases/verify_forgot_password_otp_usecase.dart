import '../repositories/auth_repository.dart';

class VerifyForgotPasswordOtpUseCase {
  const VerifyForgotPasswordOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call({required String email, required String otp}) =>
      _repository.verifyForgotPasswordOtp(email: email, otp: otp);
}
