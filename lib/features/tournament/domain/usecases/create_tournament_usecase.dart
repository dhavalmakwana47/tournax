import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class CreateTournamentUseCase {
  CreateTournamentUseCase(this._repository);

  final TournamentRepository _repository;

  Future<TournamentEntity> call({
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
  }) =>
      _repository.createTournament(
        name: name,
        mode: mode,
        tournamentType: tournamentType,
        maxTeams: maxTeams,
        maxPlayersPerTeam: maxPlayersPerTeam,
        startDate: startDate,
        endDate: endDate,
        description: description,
        registrationStart: registrationStart,
        registrationEnd: registrationEnd,
      );
}
