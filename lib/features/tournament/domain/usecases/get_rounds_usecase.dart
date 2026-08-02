import '../entities/round_entity.dart';
import '../repositories/round_repository.dart';
import '../repositories/tournament_repository.dart';

class GetRoundsUseCase {
  GetRoundsUseCase(this._repository);

  final RoundRepository _repository;

  Future<PaginatedResult<RoundEntity>> call({
    required int stageId,
    int page = 1,
    int perPage = 10,
  }) =>
      _repository.getRounds(
        stageId: stageId,
        page: page,
        perPage: perPage,
      );
}
