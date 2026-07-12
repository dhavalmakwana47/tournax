import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class GetStagesUseCase {
  GetStagesUseCase(this._repository);

  final StageRepository _repository;

  Future<List<StageEntity>> call(int tournamentId) =>
      _repository.getStages(tournamentId);
}
