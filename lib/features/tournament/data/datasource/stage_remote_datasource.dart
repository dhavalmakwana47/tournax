import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/stage_model.dart';

abstract interface class StageRemoteDatasource {
  Future<List<StageModel>> getStages(int tournamentId);
  Future<StageModel> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
  });
  Future<StageModel> showStage(int stageId);
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
  });
  Future<void> deleteStage(int stageId);
}

class StageRemoteDatasourceImpl implements StageRemoteDatasource {
  StageRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<StageModel>> getStages(int tournamentId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stagesList,
        data: {'tournament_id': tournamentId},
      );
      appLogger.d('Stages response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => StageModel.fromJson(e as Map<String, dynamic>,
              tournamentId: tournamentId))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Stages parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<StageModel> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stages,
        data: {
          'tournament_id': tournamentId,
          'name': name,
          'stage_type': stageType,
          if (order != null) 'order': order,
        },
      );
      appLogger.d('Create stage response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return StageModel.fromJson(data, tournamentId: tournamentId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Create stage error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<StageModel> showStage(int stageId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stagesShow,
        data: {'stage_id': stageId},
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return StageModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Show stage error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.stagesUpdate,
        data: {
          'stage_id': stageId,
          'name': name,
          'stage_type': stageType,
          if (order != null) 'order': order,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update stage error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> deleteStage(int stageId) async {
    try {
      await _apiClient.post(
        ApiConstants.stagesDelete,
        data: {'stage_id': stageId},
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Delete stage error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
