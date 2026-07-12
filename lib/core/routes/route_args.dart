import '../../features/tournament/domain/entities/player_entity.dart';
import '../../features/tournament/domain/entities/team_entity.dart';
import '../../features/tournament/domain/entities/tournament_entity.dart';

class AddPlayerArgs {
  const AddPlayerArgs({required this.tournament, required this.team});
  final TournamentEntity tournament;
  final TeamEntity team;
}

class PlayerListArgs {
  const PlayerListArgs({required this.tournament, required this.team});
  final TournamentEntity tournament;
  final TeamEntity team;
}

class EditTeamArgs {
  const EditTeamArgs({required this.tournament, required this.team});
  final TournamentEntity tournament;
  final TeamEntity team;
}

class EditPlayerArgs {
  const EditPlayerArgs({
    required this.tournament,
    required this.team,
    required this.player,
  });
  final TournamentEntity tournament;
  final TeamEntity team;
  final PlayerEntity player;
}

class StageArgs {
  const StageArgs({required this.tournament});
  final TournamentEntity tournament;
}

class EditStageArgs {
  const EditStageArgs({required this.tournament, required this.stageId});
  final TournamentEntity tournament;
  final int stageId;
}

class EditTournamentArgs {
  const EditTournamentArgs({required this.tournamentId});
  final int tournamentId;
}
