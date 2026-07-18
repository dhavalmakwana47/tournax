import '../entities/point_system_entity.dart';
import '../repositories/point_system_repository.dart';

class UpdatePointSystemUseCase {
  UpdatePointSystemUseCase(this._repository);
  final PointSystemRepository _repository;
  Future<PointSystemEntity> call({
    required int pointSystemId,
    int? groupId,
    String? name,
    String? code,
    double? killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    List<Map<String, dynamic>>? rules,
  }) =>
      _repository.updatePointSystem(
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
}
