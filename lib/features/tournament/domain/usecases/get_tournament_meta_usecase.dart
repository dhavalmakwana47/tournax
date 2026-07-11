import '../entities/tournament_meta_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentMetaUseCase {
  GetTournamentMetaUseCase(this._repository);

  final TournamentRepository _repository;

  Future<TournamentMetaEntity> call() => _repository.getTournamentMeta();
}
