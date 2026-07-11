import '../entities/tournament_entity.dart';
import '../entities/tournament_meta_entity.dart';

abstract interface class TournamentRepository {
  Future<List<TournamentEntity>> getTournaments();
  Future<TournamentEntity> createTournament({
    required String name,
    required String mode,
    required String tournamentType,
    required int maxTeams,
    required int maxPlayersPerTeam,
    required String startDate,
    required String endDate,
    String? description,
    String? registrationStart,
    String? registrationEnd,
  });
  Future<TournamentMetaEntity> getTournamentMeta();
}
