import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetTournamentLeaderboardUseCase {
  GetTournamentLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int tournamentId, {int? page, int? perPage}) =>
      _repository.getTournamentLeaderboard(tournamentId, page: page, perPage: perPage);
}
