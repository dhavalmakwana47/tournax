import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/send_delete_account_otp_usecase.dart';
import '../../domain/usecases/confirm_delete_account_usecase.dart';

enum ProfileStatus { initial, loading, success, error }

enum UpdateStatus { idle, loading, success, error }

enum DeleteAccountStatus { idle, sendingOtp, otpSent, confirming, deleted, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.updateStatus = UpdateStatus.idle,
    this.deleteAccountStatus = DeleteAccountStatus.idle,
    this.profile,
    this.errorMessage,
    this.deleteAccountMessage,
    this.fieldErrors = const {},
  });

  final ProfileStatus status;
  final UpdateStatus updateStatus;
  final DeleteAccountStatus deleteAccountStatus;
  final ProfileEntity? profile;
  final String? errorMessage;
  final String? deleteAccountMessage;
  final Map<String, String> fieldErrors;

  ProfileState copyWith({
    ProfileStatus? status,
    UpdateStatus? updateStatus,
    DeleteAccountStatus? deleteAccountStatus,
    ProfileEntity? profile,
    String? errorMessage,
    String? deleteAccountMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      ProfileState(
        status: status ?? this.status,
        updateStatus: updateStatus ?? this.updateStatus,
        deleteAccountStatus: deleteAccountStatus ?? this.deleteAccountStatus,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        deleteAccountMessage: clearError ? null : deleteAccountMessage ?? this.deleteAccountMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        status,
        updateStatus,
        deleteAccountStatus,
        profile,
        errorMessage,
        deleteAccountMessage,
        fieldErrors,
      ];
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState(status: ProfileStatus.initial);

  GetProfileUseCase get _getUseCase => ref.read(getProfileUseCaseProvider);
  UpdateProfileUseCase get _updateUseCase =>
      ref.read(updateProfileUseCaseProvider);
  SendDeleteAccountOtpUseCase get _sendDeleteOtpUseCase =>
      ref.read(sendDeleteAccountOtpUseCaseProvider);
  ConfirmDeleteAccountUseCase get _confirmDeleteUseCase =>
      ref.read(confirmDeleteAccountUseCaseProvider);

  Future<void> fetch() async {
    if (state.status == ProfileStatus.loading) return;
    if (state.status == ProfileStatus.success) return;
    state = state.copyWith(status: ProfileStatus.loading, clearError: true);
    try {
      final profile = await _getUseCase();
      state = state.copyWith(status: ProfileStatus.success, profile: profile);
    } on ApiException catch (e) {
      appLogger.e('Profile fetch failed', error: e);
      state =
          state.copyWith(status: ProfileStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected profile error', error: e);
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to load profile.',
      );
    }
  }

  Future<void> update({
    String? name,
    String? email,
    String? username,
  }) async {
    state = state.copyWith(
        updateStatus: UpdateStatus.loading, clearError: true);
    try {
      final updated =
          await _updateUseCase(name: name, email: email, username: username);
      state = state.copyWith(
        updateStatus: UpdateStatus.success,
        profile: updated,
        status: ProfileStatus.success,
      );
    } on ApiException catch (e) {
      appLogger.e('Profile update failed', error: e);
      state = state.copyWith(
        updateStatus: UpdateStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      appLogger.e('Unexpected profile update error', error: e);
      state = state.copyWith(
        updateStatus: UpdateStatus.error,
        errorMessage: 'Failed to update profile.',
      );
    }
  }

  void resetUpdateStatus() =>
      state = state.copyWith(updateStatus: UpdateStatus.idle, clearError: true);

  Future<bool> sendDeleteAccountOtp() async {
    state = state.copyWith(
      deleteAccountStatus: DeleteAccountStatus.sendingOtp,
      clearError: true,
    );
    try {
      final message = await _sendDeleteOtpUseCase();
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.otpSent,
        deleteAccountMessage: message,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Send delete account OTP failed', error: e);
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected send delete OTP error', error: e);
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.error,
        errorMessage: 'Failed to send OTP. Please try again.',
      );
      return false;
    }
  }

  Future<bool> confirmDeleteAccount(String otp) async {
    state = state.copyWith(
      deleteAccountStatus: DeleteAccountStatus.confirming,
      clearError: true,
    );
    try {
      final message = await _confirmDeleteUseCase(otp);
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.deleted,
        deleteAccountMessage: message,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Confirm delete account failed', error: e);
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected confirm delete error', error: e);
      state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.error,
        errorMessage: 'Failed to delete account. Please try again.',
      );
      return false;
    }
  }

  void resetDeleteAccountStatus() => state = state.copyWith(
        deleteAccountStatus: DeleteAccountStatus.idle,
        clearError: true,
      );
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
  dependencies: [],
);
