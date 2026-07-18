import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/point_system_entity.dart';
import '../../domain/usecases/get_point_systems_usecase.dart';
import '../../domain/usecases/create_point_system_usecase.dart';
import '../../domain/usecases/update_point_system_usecase.dart';
import '../../domain/usecases/delete_point_system_usecase.dart';

enum PointSystemActionStatus { idle, loading, success, error }

class PointSystemState extends Equatable {
  const PointSystemState({
    this.status = PointSystemActionStatus.idle,
    this.saveStatus = PointSystemActionStatus.idle,
    this.deleteStatus = PointSystemActionStatus.idle,
    this.pointSystems = const [],
    this.customPointSystem,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final PointSystemActionStatus status;
  final PointSystemActionStatus saveStatus;
  final PointSystemActionStatus deleteStatus;
  final List<PointSystemEntity> pointSystems;
  final PointSystemEntity? customPointSystem;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  PointSystemState copyWith({
    PointSystemActionStatus? status,
    PointSystemActionStatus? saveStatus,
    PointSystemActionStatus? deleteStatus,
    List<PointSystemEntity>? pointSystems,
    PointSystemEntity? customPointSystem,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
    bool clearCustomSystem = false,
  }) =>
      PointSystemState(
        status: status ?? this.status,
        saveStatus: saveStatus ?? this.saveStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        pointSystems: pointSystems ?? this.pointSystems,
        customPointSystem: clearCustomSystem ? null : customPointSystem ?? this.customPointSystem,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        status,
        saveStatus,
        deleteStatus,
        pointSystems,
        customPointSystem,
        errorMessage,
        fieldErrors,
      ];
}

class PointSystemController extends FamilyNotifier<PointSystemState, int> {
  @override
  PointSystemState build(int groupId) => const PointSystemState();

  GetPointSystemsUseCase get _getPointSystems => ref.read(getPointSystemsUseCaseProvider);
  CreatePointSystemUseCase get _createPointSystem => ref.read(createPointSystemUseCaseProvider);
  UpdatePointSystemUseCase get _updatePointSystem => ref.read(updatePointSystemUseCaseProvider);
  DeletePointSystemUseCase get _deletePointSystem => ref.read(deletePointSystemUseCaseProvider);

  Future<void> loadPointSystems() async {
    state = state.copyWith(status: PointSystemActionStatus.loading, clearError: true);
    try {
      final list = await _getPointSystems(arg);
      
      // Check if the group actually has a custom system, otherwise null
      final actualCustom = list.any((e) => e.groupId == arg)
          ? list.firstWhere((e) => e.groupId == arg)
          : null;

      state = state.copyWith(
        status: PointSystemActionStatus.success,
        pointSystems: list,
        customPointSystem: actualCustom,
      );
    } on ApiException catch (e) {
      appLogger.e('Load point systems failed', error: e);
      state = state.copyWith(status: PointSystemActionStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected load point systems error', error: e);
      state = state.copyWith(status: PointSystemActionStatus.error, errorMessage: 'Failed to load point systems');
    }
  }

  Future<bool> saveCustomPointSystem({
    required String name,
    required String code,
    required double killPoint,
    String? description,
    required List<Map<String, dynamic>> rules,
  }) async {
    state = state.copyWith(saveStatus: PointSystemActionStatus.loading, clearError: true);
    try {
      final PointSystemEntity updated;
      if (state.customPointSystem != null) {
        updated = await _updatePointSystem(
          pointSystemId: state.customPointSystem!.id,
          groupId: arg,
          name: name,
          code: code,
          killPoint: killPoint,
          description: description,
          rules: rules,
        );
      } else {
        updated = await _createPointSystem(
          groupId: arg,
          name: name,
          code: code,
          killPoint: killPoint,
          description: description,
          rules: rules,
        );
      }
      state = state.copyWith(
        saveStatus: PointSystemActionStatus.success,
        customPointSystem: updated,
      );
      await loadPointSystems();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Save point system failed', error: e);
      state = state.copyWith(
        saveStatus: PointSystemActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected save point system error', error: e);
      state = state.copyWith(saveStatus: PointSystemActionStatus.error, errorMessage: 'Failed to save point system');
      return false;
    }
  }

  Future<bool> resetToDefault() async {
    if (state.customPointSystem == null) return true;
    state = state.copyWith(deleteStatus: PointSystemActionStatus.loading, clearError: true);
    try {
      await _deletePointSystem(state.customPointSystem!.id);
      state = state.copyWith(
        deleteStatus: PointSystemActionStatus.success,
        clearCustomSystem: true,
      );
      await loadPointSystems();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Reset point system failed', error: e);
      state = state.copyWith(deleteStatus: PointSystemActionStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected reset point system error', error: e);
      state = state.copyWith(deleteStatus: PointSystemActionStatus.error, errorMessage: 'Failed to reset point system');
      return false;
    }
  }
}

final pointSystemControllerProvider =
    NotifierProviderFamily<PointSystemController, PointSystemState, int>(
  PointSystemController.new,
);
