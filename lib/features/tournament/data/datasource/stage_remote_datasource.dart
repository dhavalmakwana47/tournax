import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/stage_model.dart';

class PaginatedStages {
  const PaginatedStages({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });

  final List<StageModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
}

abstract interface class StageRemoteDatasource {
  Future<PaginatedStages> getStages({
    required int tournamentId,
    int page = 1,
    int perPage = 10,
  });
  Future<StageModel> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  });
  Future<StageModel> showStage(int stageId);
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  });
  Future<void> deleteStage(int stageId);
}

class StageRemoteDatasourceImpl implements StageRemoteDatasource {
  StageRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  @override
  Future<PaginatedStages> getStages({
    required int tournamentId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stagesList,
        data: {
          'tournament_id': tournamentId,
          'page': page,
          'per_page': perPage,
        },
      );
      appLogger.d('Stages response: $response');
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;
      final currentPage = _toInt(meta?['current_page'], page);
      final lastPage = _toInt(meta?['last_page'], page);

      final items = data != null
          ? data
              .map((e) => StageModel.fromJson(e as Map<String, dynamic>,
                  tournamentId: tournamentId))
              .toList()
          : <StageModel>[];

      final hasMore = meta != null ? currentPage < lastPage : items.length >= perPage;

      return PaginatedStages(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
      );
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
    String? status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stages,
        data: {
          'tournament_id': tournamentId,
          'name': name,
          'stage_type': stageType,
          if (order != null) 'order': order,
          if (status != null && status.isNotEmpty) 'status': status,
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
    String? status,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.stagesUpdate,
        data: {
          'stage_id': stageId,
          'name': name,
          'stage_type': stageType,
          if (order != null) 'order': order,
          if (status != null && status.isNotEmpty) 'status': status,
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
