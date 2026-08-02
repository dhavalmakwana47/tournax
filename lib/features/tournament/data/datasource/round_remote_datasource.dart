import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/round_model.dart';

class PaginatedRounds {
  const PaginatedRounds({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });

  final List<RoundModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
}

abstract interface class RoundRemoteDatasource {
  Future<PaginatedRounds> getRounds({
    required int stageId,
    int page = 1,
    int perPage = 10,
  });
  Future<RoundModel> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    String? status,
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

  int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  @override
  Future<PaginatedRounds> getRounds({
    required int stageId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.roundsList,
        data: {
          'stage_id': stageId,
          'page': page,
          'per_page': perPage,
        },
      );
      appLogger.d('Rounds response: $response');
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;
      final currentPage = _toInt(meta?['current_page'], page);
      final lastPage = _toInt(meta?['last_page'], page);

      final items = data != null
          ? data
              .map((e) => RoundModel.fromJson(e as Map<String, dynamic>, stageId: stageId))
              .toList()
          : <RoundModel>[];

      final hasMore = meta != null ? currentPage < lastPage : items.length >= perPage;

      return PaginatedRounds(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
      );
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
    String? status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.rounds,
        data: {
          'stage_id': stageId,
          'name': name,
          if (roundNumber != null) 'round_number': roundNumber,
          if (numberOfGroups != null) 'number_of_groups': numberOfGroups,
          if (status != null && status.isNotEmpty) 'status': status,
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
