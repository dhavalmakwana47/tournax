import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class ShowStageUseCase {
  ShowStageUseCase(this._repository);

  final StageRepository _repository;

  Future<StageEntity> call(int stageId) => _repository.showStage(stageId);
}
