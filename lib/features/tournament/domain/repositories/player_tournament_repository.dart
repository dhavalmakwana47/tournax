import 'tournament_repository.dart';
import '../entities/tournament_entity.dart';

abstract interface class PlayerTournamentRepository {
  Future<PaginatedResult<TournamentEntity>> getPublicTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
  });

  Future<PaginatedResult<TournamentEntity>> getParticipatedTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
  });

  Future<TournamentEntity> showTournament(int tournamentId);

  Future<Map<String, dynamic>> joinTournament({
    required int tournamentId,
    required int teamId,
  });

  Future<String> leaveTournament({
    required int tournamentId,
    required int teamId,
  });
}
