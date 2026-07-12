import '../entities/stage_entity.dart';

abstract interface class StageRepository {
  Future<List<StageEntity>> getStages(int tournamentId);
  Future<StageEntity> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
  });
  Future<StageEntity> showStage(int stageId);
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
  });
  Future<void> deleteStage(int stageId);
}
