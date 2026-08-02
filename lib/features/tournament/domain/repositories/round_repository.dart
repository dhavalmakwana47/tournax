import '../entities/round_entity.dart';
import 'tournament_repository.dart';

abstract interface class RoundRepository {
  Future<PaginatedResult<RoundEntity>> getRounds({
    required int stageId,
    int page = 1,
    int perPage = 10,
  });
  Future<RoundEntity> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    String? status,
  });
  Future<RoundEntity> showRound(int roundId);
  Future<RoundEntity> updateRound({
    required int roundId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    required String status,
  });
  Future<void> deleteRound(int roundId);
}
