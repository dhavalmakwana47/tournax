import '../entities/round_entity.dart';
import '../repositories/round_repository.dart';

class GetRoundsUseCase {
  GetRoundsUseCase(this._repository);

  final RoundRepository _repository;

  Future<List<RoundEntity>> call(int stageId) => _repository.getRounds(stageId);
}
