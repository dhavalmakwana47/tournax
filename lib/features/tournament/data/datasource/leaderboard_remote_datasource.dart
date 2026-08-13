import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/leaderboard_item_model.dart';

abstract interface class LeaderboardRemoteDatasource {
  Future<List<LeaderboardItemModel>> getGroupLeaderboard(int groupId, {int? page, int? perPage});
  Future<List<LeaderboardItemModel>> getRoundLeaderboard(int roundId, {int? page, int? perPage});
  Future<List<LeaderboardItemModel>> getStageLeaderboard(int stageId, {int? page, int? perPage});
  Future<List<LeaderboardItemModel>> getTournamentLeaderboard(int tournamentId, {int? page, int? perPage});
  Future<List<LeaderboardItemModel>> getMatchLeaderboard(int matchId, {int? page, int? perPage});
}

class LeaderboardRemoteDatasourceImpl implements LeaderboardRemoteDatasource {
  LeaderboardRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  List<LeaderboardItemModel> _parseLeaderboardItems(dynamic response) {
    final rawData = response['data'];
    List<dynamic>? list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      list = rawData['data'] as List<dynamic>;
    }
    if (list == null) return [];
    return list
        .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LeaderboardItemModel>> getGroupLeaderboard(int groupId, {int? page, int? perPage}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardGroup,
        data: {
          'group_id': groupId,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (perPage != null) 'limit': perPage,
        },
      );
      appLogger.d('Group leaderboard response: $response');
      return _parseLeaderboardItems(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Group leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getRoundLeaderboard(int roundId, {int? page, int? perPage}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardRound,
        data: {
          'round_id': roundId,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (perPage != null) 'limit': perPage,
        },
      );
      appLogger.d('Round leaderboard response: $response');
      return _parseLeaderboardItems(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Round leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getStageLeaderboard(int stageId, {int? page, int? perPage}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardStage,
        data: {
          'stage_id': stageId,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (perPage != null) 'limit': perPage,
        },
      );
      appLogger.d('Stage leaderboard response: $response');
      return _parseLeaderboardItems(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Stage leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getTournamentLeaderboard(int tournamentId, {int? page, int? perPage}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardTournament,
        data: {
          'tournament_id': tournamentId,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (perPage != null) 'limit': perPage,
        },
      );
      appLogger.d('Tournament leaderboard response: $response');
      return _parseLeaderboardItems(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Tournament leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getMatchLeaderboard(int matchId, {int? page, int? perPage}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardMatch,
        data: {
          'match_id': matchId,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (perPage != null) 'limit': perPage,
        },
      );
      appLogger.d('Match leaderboard response: $response');
      return _parseLeaderboardItems(response);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Match leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
