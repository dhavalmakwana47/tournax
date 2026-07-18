import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/group_model.dart';

abstract interface class GroupRemoteDatasource {
  Future<List<GroupModel>> getGroups(int roundId);
  Future<GroupModel> createGroup({
    required int roundId,
    required String name,
    int? displayOrder,
    String? status,
  });
  Future<GroupModel> showGroup(int groupId);
  Future<void> updateGroup({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  });
  Future<void> deleteGroup(int groupId);
  Future<GroupModel> addGroupTeam({
    required int groupId,
    required int teamId,
    int? seed,
  });
  Future<GroupModel> removeGroupTeam({
    required int groupId,
    required int teamId,
  });
}

class GroupRemoteDatasourceImpl implements GroupRemoteDatasource {
  GroupRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<GroupModel>> getGroups(int roundId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupsList,
        data: {'round_id': roundId},
      );
      appLogger.d('Groups response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>, roundId: roundId))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Groups parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<GroupModel> createGroup({
    required int roundId,
    required String name,
    int? displayOrder,
    String? status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groups,
        data: {
          'round_id': roundId,
          'name': name,
          if (displayOrder != null) 'display_order': displayOrder,
          if (status != null) 'status': status,
        },
      );
      appLogger.d('Create group response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return GroupModel.fromJson(data, roundId: roundId);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Create group error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<GroupModel> showGroup(int groupId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupsShow,
        data: {'group_id': groupId},
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return GroupModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Show group error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> updateGroup({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.groupsUpdate,
        data: {
          'group_id': groupId,
          if (name != null) 'name': name,
          if (displayOrder != null) 'display_order': displayOrder,
          if (status != null) 'status': status,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update group error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> deleteGroup(int groupId) async {
    try {
      await _apiClient.post(
        ApiConstants.groupsDelete,
        data: {'group_id': groupId},
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Delete group error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<GroupModel> addGroupTeam({
    required int groupId,
    required int teamId,
    int? seed,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupsAddTeam,
        data: {
          'group_id': groupId,
          'team_id': teamId,
          if (seed != null) 'seed': seed,
        },
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return GroupModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Add group team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<GroupModel> removeGroupTeam({
    required int groupId,
    required int teamId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupsRemoveTeam,
        data: {
          'group_id': groupId,
          'team_id': teamId,
        },
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return GroupModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Remove group team error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
