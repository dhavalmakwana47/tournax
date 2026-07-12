import '../repositories/stage_repository.dart';

class DeleteStageUseCase {
  DeleteStageUseCase(this._repository);

  final StageRepository _repository;

  Future<void> call(int stageId) => _repository.deleteStage(stageId);
}
