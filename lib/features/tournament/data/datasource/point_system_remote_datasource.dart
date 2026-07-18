import '../../../../core/api/api_client.dart';
import '../models/point_system_model.dart';

abstract interface class PointSystemRemoteDatasource {
  Future<List<PointSystemModel>> getPointSystems(int? groupId);
  Future<PointSystemModel> createPointSystem({
    int? groupId,
    required String name,
    required String code,
    required double killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    required List<Map<String, dynamic>> rules,
  });
  Future<PointSystemModel> showPointSystem(int pointSystemId);
  Future<PointSystemModel> updatePointSystem({
    required int pointSystemId,
    int? groupId,
    String? name,
    String? code,
    double? killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    List<Map<String, dynamic>>? rules,
  });
  Future<void> deletePointSystem(int pointSystemId);
}

class PointSystemRemoteDatasourceImpl implements PointSystemRemoteDatasource {
  PointSystemRemoteDatasourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<PointSystemModel>> getPointSystems(int? groupId) async {
    final response = await _apiClient.post(
      '/point-systems/list',
      data: groupId != null ? {'group_id': groupId} : {},
    );
    final data = response['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => PointSystemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PointSystemModel> createPointSystem({
    int? groupId,
    required String name,
    required String code,
    required double killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    required List<Map<String, dynamic>> rules,
  }) async {
    final response = await _apiClient.post(
      '/point-systems',
      data: {
        if (groupId != null) 'group_id': groupId,
        'name': name,
        'code': code,
        'kill_point': killPoint,
        if (description != null) 'description': description,
        if (isDefault != null) 'is_default': isDefault,
        if (status != null) 'status': status,
        'rules': rules,
      },
    );
    return PointSystemModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PointSystemModel> showPointSystem(int pointSystemId) async {
    final response = await _apiClient.post(
      '/point-systems/show',
      data: {'point_system_id': pointSystemId},
    );
    return PointSystemModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PointSystemModel> updatePointSystem({
    required int pointSystemId,
    int? groupId,
    String? name,
    String? code,
    double? killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    List<Map<String, dynamic>>? rules,
  }) async {
    final response = await _apiClient.post(
      '/point-systems/update',
      data: {
        'point_system_id': pointSystemId,
        if (groupId != null) 'group_id': groupId,
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (killPoint != null) 'kill_point': killPoint,
        if (description != null) 'description': description,
        if (isDefault != null) 'is_default': isDefault,
        if (status != null) 'status': status,
        if (rules != null) 'rules': rules,
      },
    );
    return PointSystemModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePointSystem(int pointSystemId) async {
    await _apiClient.post(
      '/point-systems/delete',
      data: {'point_system_id': pointSystemId},
    );
  }
}
