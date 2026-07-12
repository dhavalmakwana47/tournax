import '../repositories/tournament_repository.dart';

class UpdateTournamentUseCase {
  UpdateTournamentUseCase(this._repository);

  final TournamentRepository _repository;

  Future<void> call(Map<String, dynamic> data) =>
      _repository.updateTournament(data);
}
