import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/match_model.dart';
import '../models/match_result_model.dart';

abstract interface class MatchRemoteDatasource {
  Future<List<MatchModel>> getMatches(int groupId);
  Future<MatchModel> createMatch({
    required int groupId,
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  });
  Future<MatchModel> showMatch(int matchId);
  Future<MatchModel> updateMatch({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  });
  Future<void> deleteMatch(int matchId);
  Future<MatchModel> addTeamToMatch({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  });
  Future<MatchModel> removeTeamFromMatch({
    required int matchId,
    required int teamId,
  });
  Future<void> submitMatchResults({
    required int matchId,
    required List<Map<String, dynamic>> results,
  });
  Future<List<TeamResultModel>> getMatchResults(int matchId);
  Future<void> deleteMatchResults(int matchId);
}

class MatchRemoteDatasourceImpl implements MatchRemoteDatasource {
  MatchRemoteDatasourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<MatchModel>> getMatches(int groupId) async {
    final response = await _apiClient.post('/matches/list', data: {'group_id': groupId});
    final data = response['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MatchModel> createMatch({
    required int groupId,
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  }) async {
    final response = await _apiClient.post(
      '/matches',
      data: {
        'group_id': groupId,
        'match_number': matchNumber,
        if (name != null) 'name': name,
        if (map != null) 'map': map,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (status != null) 'status': status,
      },
    );
    return MatchModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<MatchModel> showMatch(int matchId) async {
    final response = await _apiClient.post('/matches/show', data: {'match_id': matchId});
    return MatchModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<MatchModel> updateMatch({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  }) async {
    final response = await _apiClient.post(
      '/matches/update',
      data: {
        'match_id': matchId,
        if (matchNumber != null) 'match_number': matchNumber,
        if (name != null) 'name': name,
        if (map != null) 'map': map,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (startedAt != null) 'started_at': startedAt,
        if (endedAt != null) 'ended_at': endedAt,
        if (status != null) 'status': status,
      },
    );
    return MatchModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMatch(int matchId) async {
    await _apiClient.post('/matches/delete', data: {'match_id': matchId});
  }

  @override
  Future<MatchModel> addTeamToMatch({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  }) async {
    final response = await _apiClient.post(
      '/matches/add-team',
      data: {
        'match_id': matchId,
        'team_id': teamId,
        if (slot != null) 'slot': slot,
        if (lane != null) 'lane': lane,
      },
    );
    return MatchModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<MatchModel> removeTeamFromMatch({
    required int matchId,
    required int teamId,
  }) async {
    final response = await _apiClient.post(
      '/matches/remove-team',
      data: {
        'match_id': matchId,
        'team_id': teamId,
      },
    );
    return MatchModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> submitMatchResults({
    required int matchId,
    required List<Map<String, dynamic>> results,
  }) async {
    await _apiClient.post(
      ApiConstants.matchesResultsStore,
      data: {
        'match_id': matchId,
        'results': results,
      },
    );
  }

  @override
  Future<List<TeamResultModel>> getMatchResults(int matchId) async {
    final response = await _apiClient.post(
      ApiConstants.matchesResultsShow,
      data: {'match_id': matchId},
    );
    final data = response['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => TeamResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteMatchResults(int matchId) async {
    await _apiClient.post(
      ApiConstants.matchesResultsDelete,
      data: {'match_id': matchId},
    );
  }
}
