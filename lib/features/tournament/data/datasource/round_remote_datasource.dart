import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/round_model.dart';

abstract interface class RoundRemoteDatasource {
  Future<List<RoundModel>> getRounds(int stageId);
  Future<RoundModel> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
  });
  Future<RoundModel> showRound(int roundId);
  Future<RoundModel> updateRound({
    required int roundId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    required String status,
  });
  Future<void> deleteRound(int roundId);
}

class RoundRemoteDatasourceImpl implements RoundRemoteDatasource {
  RoundRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<RoundModel>> getRounds(int stageId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.roundsList,
        data: {'stage_id': stageId},
      );
      appLogger.d('Rounds response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => RoundModel.fromJson(e as Map<String, dynamic>, stageId: stageId))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Rounds parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<RoundModel> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.rounds,
        data: {
          'stage_id': stageId,
          'name': name,
          if (roundNumber != null) 'round_number': roundNumber,
          if (numberOfGroups != null) 'number_of_groups': numberOfGroups,
        },
      );
      appLogger.d('Create round response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return RoundModel.fromJson(data, stageId: stageId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Create round error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<RoundModel> showRound(int roundId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.roundsShow,
        data: {'round_id': roundId},
      );
      appLogger.d('Show round response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return RoundModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Show round error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<RoundModel> updateRound({
    required int roundId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    required String status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.roundsUpdate,
        data: {
          'round_id': roundId,
          'name': name,
          if (roundNumber != null) 'round_number': roundNumber,
          if (numberOfGroups != null) 'number_of_groups': numberOfGroups,
          'status': status,
        },
      );
      appLogger.d('Update round response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return RoundModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update round error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> deleteRound(int roundId) async {
    try {
      await _apiClient.post(
        ApiConstants.roundsDelete,
        data: {'round_id': roundId},
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Delete round error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
