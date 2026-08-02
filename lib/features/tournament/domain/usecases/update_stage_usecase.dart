import '../repositories/stage_repository.dart';

class UpdateStageUseCase {
  UpdateStageUseCase(this._repository);

  final StageRepository _repository;

  Future<void> call({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  }) =>
      _repository.updateStage(
        stageId: stageId,
        name: name,
        stageType: stageType,
        order: order,
        status: status,
      );
}
