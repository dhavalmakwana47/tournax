import '../entities/point_system_entity.dart';
import '../repositories/point_system_repository.dart';

class GetPointSystemsUseCase {
  GetPointSystemsUseCase(this._repository);
  final PointSystemRepository _repository;
  Future<List<PointSystemEntity>> call(int? groupId) => _repository.getPointSystems(groupId);
}
