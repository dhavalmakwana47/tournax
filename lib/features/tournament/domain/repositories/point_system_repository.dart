import '../entities/point_system_entity.dart';

abstract interface class PointSystemRepository {
  Future<List<PointSystemEntity>> getPointSystems(int? groupId);
  Future<PointSystemEntity> createPointSystem({
    int? groupId,
    required String name,
    required String code,
    required double killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    required List<Map<String, dynamic>> rules,
  });
  Future<PointSystemEntity> showPointSystem(int pointSystemId);
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
  });
  Future<void> deletePointSystem(int pointSystemId);
}
