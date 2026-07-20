import '../entities/round_entity.dart';
import '../repositories/round_repository.dart';

class ShowRoundUseCase {
  ShowRoundUseCase(this._repository);

  final RoundRepository _repository;

  Future<RoundEntity> call(int roundId) => _repository.showRound(roundId);
}
