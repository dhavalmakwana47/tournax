import '../entities/round_entity.dart';
import '../repositories/round_repository.dart';

class UpdateRoundUseCase {
  UpdateRoundUseCase(this._repository);

  final RoundRepository _repository;

  Future<RoundEntity> call({
    required int roundId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    required String status,
  }) =>
      _repository.updateRound(
        roundId: roundId,
        name: name,
        roundNumber: roundNumber,
        numberOfGroups: numberOfGroups,
        status: status,
      );
}
