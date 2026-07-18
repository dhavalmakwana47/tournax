import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/player_model.dart';
import '../models/team_model.dart';

abstract interface class TeamRemoteDatasource {
  Future<List<TeamModel>> getTeams(int tournamentId);
  Future<TeamModel> createTeam({
    required int tournamentId,
    required String name,
  });
  Future<TeamModel> getTeam({
    required int tournamentId,
    required int teamId,
  });
  Future<TeamModel> updateTeam({
    required int tournamentId,
    required int teamId,
    required String name,
  });
  Future<List<PlayerModel>> getPlayers({
    required int tournamentId,
    required int teamId,
  });
  Future<PlayerModel> addPlayer({
    required int tournamentId,
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  });
  Future<PlayerModel> getPlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  });
  Future<PlayerModel> updatePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  });
  Future<void> deleteTeam({
    required int tournamentId,
    required int teamId,
  });
  Future<void> deletePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  });
}

class TeamRemoteDatasourceImpl implements TeamRemoteDatasource {
  TeamRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TeamModel>> getTeams(int tournamentId) async {
    try {
      final response =
          await _apiClient.get(ApiConstants.tournamentTeams(tournamentId));
      appLogger.d('Teams response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => TeamModel.fromJson(e as Map<String, dynamic>,
              tournamentId: tournamentId))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Teams parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TeamModel> createTeam({
    required int tournamentId,
    required String name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tournamentTeams(tournamentId),
        data: {'name': name},
      );
      appLogger.d('Create team response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TeamModel.fromJson(data, tournamentId: tournamentId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Create team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TeamModel> getTeam({
    required int tournamentId,
    required int teamId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.tournamentTeam(tournamentId, teamId),
      );
      appLogger.d('Get team response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TeamModel.fromJson(data, tournamentId: tournamentId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Get team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TeamModel> updateTeam({
    required int tournamentId,
    required int teamId,
    required String name,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.tournamentTeam(tournamentId, teamId),
        data: {'name': name},
      );
      appLogger.d('Update team response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TeamModel.fromJson(data, tournamentId: tournamentId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<List<PlayerModel>> getPlayers({
    required int tournamentId,
    required int teamId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.tournamentTeamPlayers(tournamentId, teamId),
      );
      appLogger.d('Players response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>,
              teamId: teamId))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Players parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<PlayerModel> addPlayer({
    required int tournamentId,
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tournamentTeamPlayers(tournamentId, teamId),
        data: {
          'name': name,
          if (gameUid != null && gameUid.isNotEmpty) 'game_uid': gameUid,
          if (role != null && role.isNotEmpty) 'role': role,
          if (userId != null) 'user_id': userId,
        },
      );
      appLogger.d('Add player response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return PlayerModel.fromJson(data, teamId: teamId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Add player error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<PlayerModel> getPlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.tournamentTeamPlayer(tournamentId, teamId, playerId),
      );
      appLogger.d('Get player response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return PlayerModel.fromJson(data, teamId: teamId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Get player error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<PlayerModel> updatePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.tournamentTeamPlayer(tournamentId, teamId, playerId),
        data: {
          'name': name,
          if (gameUid != null && gameUid.isNotEmpty) 'game_uid': gameUid,
          if (role != null && role.isNotEmpty) 'role': role,
          if (userId != null) 'user_id': userId,
        },
      );
      appLogger.d('Update player response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return PlayerModel.fromJson(data, teamId: teamId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update player error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> deleteTeam({
    required int tournamentId,
    required int teamId,
  }) async {
    try {
      await _apiClient.delete(
        ApiConstants.tournamentTeam(tournamentId, teamId),
      );
      appLogger.d('Delete team: $teamId');
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Delete team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> deletePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) async {
    try {
      await _apiClient.delete(
        ApiConstants.tournamentTeamPlayer(tournamentId, teamId, playerId),
      );
      appLogger.d('Delete player: $playerId');
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Delete player error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
