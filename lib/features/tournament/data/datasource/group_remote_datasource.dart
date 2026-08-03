import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/group_model.dart';

class PaginatedGroups {
  const PaginatedGroups({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });

  final List<GroupModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
}

abstract interface class GroupRemoteDatasource {
  Future<PaginatedGroups> getGroups({
    required int roundId,
    int page = 1,
    int perPage = 10,
  });
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

  int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  @override
  Future<PaginatedGroups> getGroups({
    required int roundId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupsList,
        data: {
          'round_id': roundId,
          'page': page,
          'per_page': perPage,
        },
      );
      appLogger.d('Groups response: $response');
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;
      final currentPage = _toInt(meta?['current_page'], page);
      final lastPage = _toInt(meta?['last_page'], page);

      final items = data != null
          ? data
              .map((e) => GroupModel.fromJson(e as Map<String, dynamic>, roundId: roundId))
              .toList()
          : <GroupModel>[];

      final hasMore = meta != null ? currentPage < lastPage : items.length >= perPage;

      return PaginatedGroups(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
      );
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
