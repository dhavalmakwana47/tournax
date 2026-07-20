import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/leaderboard_item_model.dart';

abstract interface class LeaderboardRemoteDatasource {
  Future<List<LeaderboardItemModel>> getGroupLeaderboard(int groupId);
  Future<List<LeaderboardItemModel>> getRoundLeaderboard(int roundId);
  Future<List<LeaderboardItemModel>> getStageLeaderboard(int stageId);
  Future<List<LeaderboardItemModel>> getTournamentLeaderboard(int tournamentId);
  Future<List<LeaderboardItemModel>> getMatchLeaderboard(int matchId);
}

class LeaderboardRemoteDatasourceImpl implements LeaderboardRemoteDatasource {
  LeaderboardRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<LeaderboardItemModel>> getGroupLeaderboard(int groupId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardGroup,
        data: {'group_id': groupId},
      );
      appLogger.d('Group leaderboard response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Group leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getRoundLeaderboard(int roundId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardRound,
        data: {'round_id': roundId},
      );
      appLogger.d('Round leaderboard response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Round leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getStageLeaderboard(int stageId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardStage,
        data: {'stage_id': stageId},
      );
      appLogger.d('Stage leaderboard response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Stage leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getTournamentLeaderboard(int tournamentId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardTournament,
        data: {'tournament_id': tournamentId},
      );
      appLogger.d('Tournament leaderboard response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Tournament leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<LeaderboardItemModel>> getMatchLeaderboard(int matchId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.leaderboardMatch,
        data: {'match_id': matchId},
      );
      appLogger.d('Match leaderboard response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => LeaderboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Match leaderboard parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
