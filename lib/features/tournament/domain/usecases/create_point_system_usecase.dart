import '../entities/point_system_entity.dart';
import '../repositories/point_system_repository.dart';

class CreatePointSystemUseCase {
  CreatePointSystemUseCase(this._repository);
  final PointSystemRepository _repository;
  Future<PointSystemEntity> call({
    int? groupId,
    required String name,
    required String code,
    required double killPoint,
    String? description,
    bool? isDefault,
    bool? status,
    required List<Map<String, dynamic>> rules,
  }) =>
      _repository.createPointSystem(
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
