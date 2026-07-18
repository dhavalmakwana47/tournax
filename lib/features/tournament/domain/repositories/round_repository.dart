import '../entities/round_entity.dart';

abstract interface class RoundRepository {
  Future<List<RoundEntity>> getRounds(int stageId);
  Future<RoundEntity> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
  });
  Future<void> deleteRound(int roundId);
}
