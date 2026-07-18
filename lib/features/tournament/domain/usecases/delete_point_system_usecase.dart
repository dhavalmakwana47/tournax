import '../repositories/point_system_repository.dart';

class DeletePointSystemUseCase {
  DeletePointSystemUseCase(this._repository);
  final PointSystemRepository _repository;
  Future<void> call(int pointSystemId) => _repository.deletePointSystem(pointSystemId);
}
