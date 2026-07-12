import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/usecases/get_stages_usecase.dart';
import '../../domain/usecases/create_stage_usecase.dart';
import '../../domain/usecases/show_stage_usecase.dart';
import '../../domain/usecases/update_stage_usecase.dart';
import '../../domain/usecases/delete_stage_usecase.dart';

enum StageListStatus { initial, loading, success, empty, error }

enum StageActionStatus { idle, loading, success, error }

class StageState extends Equatable {
  const StageState({
    this.listStatus = StageListStatus.initial,
    this.createStatus = StageActionStatus.idle,
    this.updateStatus = StageActionStatus.idle,
    this.deleteStatus = StageActionStatus.idle,
    this.stages = const [],
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final StageListStatus listStatus;
  final StageActionStatus createStatus;
  final StageActionStatus updateStatus;
  final StageActionStatus deleteStatus;
  final List<StageEntity> stages;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  StageState copyWith({
    StageListStatus? listStatus,
    StageActionStatus? createStatus,
    StageActionStatus? updateStatus,
    StageActionStatus? deleteStatus,
    List<StageEntity>? stages,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      StageState(
        listStatus: listStatus ?? this.listStatus,
        createStatus: createStatus ?? this.createStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        stages: stages ?? this.stages,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        listStatus,
        createStatus,
        updateStatus,
        deleteStatus,
        stages,
        errorMessage,
        fieldErrors,
      ];
}

class StageController extends FamilyNotifier<StageState, int> {
  @override
  StageState build(int tournamentId) => const StageState();

  GetStagesUseCase get _getStages => ref.read(getStagesUseCaseProvider);
  CreateStageUseCase get _createStage => ref.read(createStageUseCaseProvider);
  ShowStageUseCase get _showStage => ref.read(showStageUseCaseProvider);
  UpdateStageUseCase get _updateStage => ref.read(updateStageUseCaseProvider);
  DeleteStageUseCase get _deleteStage => ref.read(deleteStageUseCaseProvider);

  Future<void> fetchStages() async {
    if (state.listStatus == StageListStatus.loading) return;
    state = state.copyWith(listStatus: StageListStatus.loading, clearError: true);
    try {
      final stages = await _getStages(arg);
      state = state.copyWith(
        listStatus: stages.isEmpty ? StageListStatus.empty : StageListStatus.success,
        stages: stages,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch stages failed', error: e);
      state = state.copyWith(
          listStatus: StageListStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch stages error', error: e);
      state = state.copyWith(
          listStatus: StageListStatus.error,
          errorMessage: 'Failed to load stages.');
    }
  }

  Future<bool> createStage({
    required String name,
    required String stageType,
    int? order,
  }) async {
    state = state.copyWith(
        createStatus: StageActionStatus.loading, clearError: true);
    try {
      final stage = await _createStage(
        tournamentId: arg,
        name: name,
        stageType: stageType,
        order: order,
      );
      state = state.copyWith(
        createStatus: StageActionStatus.success,
        stages: [...state.stages, stage],
        listStatus: StageListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create stage failed', error: e);
      state = state.copyWith(
        createStatus: StageActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create stage error', error: e);
      state = state.copyWith(
          createStatus: StageActionStatus.error,
          errorMessage: 'Failed to create stage.');
      return false;
    }
  }

  Future<StageEntity?> showStage(int stageId) async {
    try {
      return await _showStage(stageId);
    } on ApiException catch (e) {
      appLogger.e('Show stage failed', error: e);
      return null;
    } catch (e) {
      appLogger.e('Unexpected show stage error', error: e);
      return null;
    }
  }

  Future<bool> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
  }) async {
    state = state.copyWith(
        updateStatus: StageActionStatus.loading, clearError: true);
    try {
      await _updateStage(
        stageId: stageId,
        name: name,
        stageType: stageType,
        order: order,
      );
      final updated = state.stages.map((s) {
        if (s.id != stageId) return s;
        return StageEntity(
          id: s.id,
          tournamentId: s.tournamentId,
          name: name,
          stageType: stageType,
          order: order,
          status: s.status,
          createdAt: s.createdAt,
        );
      }).toList();
      state = state.copyWith(
        updateStatus: StageActionStatus.success,
        stages: updated,
        listStatus: StageListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Update stage failed', error: e);
      state = state.copyWith(
        updateStatus: StageActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected update stage error', error: e);
      state = state.copyWith(
          updateStatus: StageActionStatus.error,
          errorMessage: 'Failed to update stage.');
      return false;
    }
  }

  Future<bool> deleteStage(int stageId) async {
    state = state.copyWith(
        deleteStatus: StageActionStatus.loading, clearError: true);
    try {
      await _deleteStage(stageId);
      final remaining = state.stages.where((s) => s.id != stageId).toList();
      state = state.copyWith(
        deleteStatus: StageActionStatus.success,
        stages: remaining,
        listStatus:
            remaining.isEmpty ? StageListStatus.empty : StageListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete stage failed', error: e);
      state = state.copyWith(
          deleteStatus: StageActionStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete stage error', error: e);
      state = state.copyWith(
          deleteStatus: StageActionStatus.error,
          errorMessage: 'Failed to delete stage.');
      return false;
    }
  }

  void resetCreateStatus() =>
      state = state.copyWith(createStatus: StageActionStatus.idle, clearError: true);

  void resetUpdateStatus() =>
      state = state.copyWith(updateStatus: StageActionStatus.idle, clearError: true);

  void resetDeleteStatus() =>
      state = state.copyWith(deleteStatus: StageActionStatus.idle, clearError: true);
}

final stageControllerProvider =
    NotifierProviderFamily<StageController, StageState, int>(
  StageController.new,
);
