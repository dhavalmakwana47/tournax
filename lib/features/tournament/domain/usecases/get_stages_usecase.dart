import '../entities/stage_entity.dart';
import '../repositories/stage_repository.dart';
import '../repositories/tournament_repository.dart';

class GetStagesUseCase {
  GetStagesUseCase(this._repository);

  final StageRepository _repository;

  Future<PaginatedResult<StageEntity>> call({
    required int tournamentId,
    int page = 1,
    int perPage = 10,
  }) =>
      _repository.getStages(
        tournamentId: tournamentId,
        page: page,
        perPage: perPage,
      );
}
