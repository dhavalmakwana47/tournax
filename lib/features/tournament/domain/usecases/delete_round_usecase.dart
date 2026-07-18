import '../repositories/round_repository.dart';

class DeleteRoundUseCase {
  DeleteRoundUseCase(this._repository);

  final RoundRepository _repository;

  Future<void> call(int roundId) => _repository.deleteRound(roundId);
}
