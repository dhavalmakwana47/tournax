import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum ProfileStatus { initial, loading, success, error }

enum UpdateStatus { idle, loading, success, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.updateStatus = UpdateStatus.idle,
    this.profile,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final ProfileStatus status;
  final UpdateStatus updateStatus;
  final ProfileEntity? profile;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  ProfileState copyWith({
    ProfileStatus? status,
    UpdateStatus? updateStatus,
    ProfileEntity? profile,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      ProfileState(
        status: status ?? this.status,
        updateStatus: updateStatus ?? this.updateStatus,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props =>
      [status, updateStatus, profile, errorMessage, fieldErrors];
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState(status: ProfileStatus.initial);

  GetProfileUseCase get _getUseCase => ref.read(getProfileUseCaseProvider);
  UpdateProfileUseCase get _updateUseCase =>
      ref.read(updateProfileUseCaseProvider);

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
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
  dependencies: [],
);
