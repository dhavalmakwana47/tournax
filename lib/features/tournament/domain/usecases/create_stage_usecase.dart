import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';

class CreateStageUseCase {
  CreateStageUseCase(this._repository);

  final StageRepository _repository;

  Future<StageEntity> call({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
  }) =>
      _repository.createStage(
        tournamentId: tournamentId,
        name: name,
        stageType: stageType,
        order: order,
      );
}
