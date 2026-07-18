import '../../../../core/network/network_info.dart';
import '../../domain/entities/point_system_entity.dart';
import '../../domain/repositories/point_system_repository.dart';
import '../datasource/point_system_remote_datasource.dart';

class PointSystemRepositoryImpl implements PointSystemRepository {
  PointSystemRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final PointSystemRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<PointSystemEntity>> getPointSystems(int? groupId) async {
    final list = await remoteDatasource.getPointSystems(groupId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<PointSystemEntity> createPointSystem({
    int? groupId,
    required String name,
    required String code,
    required double killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    required List<Map<String, dynamic>> rules,
  }) async {
    final model = await remoteDatasource.createPointSystem(
      groupId: groupId,
      name: name,
      code: code,
      killPoint: killPoint,
      description: description,
      isDefault: isDefault,
      status: status,
      rules: rules,
    );
    return model.toEntity();
  }

  @override
  Future<PointSystemEntity> showPointSystem(int pointSystemId) async {
    final model = await remoteDatasource.showPointSystem(pointSystemId);
    return model.toEntity();
  }

  @override
  Future<PointSystemEntity> updatePointSystem({
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
    final model = await remoteDatasource.updatePointSystem(
      pointSystemId: pointSystemId,
      groupId: groupId,
      name: name,
      code: code,
      killPoint: killPoint,
      description: description,
      isDefault: isDefault,
      status: status,
      rules: rules,
    );
    return model.toEntity();
  }

  @override
  Future<void> deletePointSystem(int pointSystemId) async {
    await remoteDatasource.deletePointSystem(pointSystemId);
  }
}
