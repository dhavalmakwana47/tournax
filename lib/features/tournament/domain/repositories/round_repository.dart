import '../entities/round_entity.dart';

abstract interface class RoundRepository {
  Future<List<RoundEntity>> getRounds(int stageId);
  Future<RoundEntity> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
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
