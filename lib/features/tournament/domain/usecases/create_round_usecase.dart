import '../entities/round_entity.dart';
import '../repositories/round_repository.dart';

class CreateRoundUseCase {
  CreateRoundUseCase(this._repository);

  final RoundRepository _repository;

  Future<RoundEntity> call({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    String? status,
  }) =>
      _repository.createRound(
        stageId: stageId,
        name: name,
        roundNumber: roundNumber,
        numberOfGroups: numberOfGroups,
        status: status,
      );
}
