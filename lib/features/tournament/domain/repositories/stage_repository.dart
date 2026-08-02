import '../entities/stage_entity.dart';
import 'tournament_repository.dart';

abstract interface class StageRepository {
  Future<PaginatedResult<StageEntity>> getStages({
    required int tournamentId,
    int page = 1,
    int perPage = 10,
  });
  Future<StageEntity> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  });
  Future<StageEntity> showStage(int stageId);
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  });
  Future<void> deleteStage(int stageId);
}
