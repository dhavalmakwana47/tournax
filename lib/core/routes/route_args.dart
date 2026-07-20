import 'package:equatable/equatable.dart';
import '../../features/tournament/domain/entities/player_entity.dart';
import '../../features/tournament/domain/entities/team_entity.dart';
import '../../features/tournament/domain/entities/tournament_entity.dart';
import '../../features/tournament/domain/entities/group_entity.dart';



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

class RoundArgs {
  const RoundArgs({required this.tournament, required this.stageId});
  final TournamentEntity tournament;
  final int stageId;
}

class GroupArgs {
  const GroupArgs({required this.tournament, required this.roundId});
  final TournamentEntity tournament;
  final int roundId;
}

class EditGroupArgs {
  const EditGroupArgs({
    required this.tournament,
    required this.roundId,
    required this.groupId,
  });
  final TournamentEntity tournament;
  final int roundId;
  final int groupId;
}

class PointSystemArgs {
  const PointSystemArgs({
    required this.tournament,
    required this.groupId,
  });
  final TournamentEntity tournament;
  final int groupId;
}

class MatchArgs {
  const MatchArgs({
    required this.tournament,
    required this.group,
  });
  final TournamentEntity tournament;
  final GroupEntity group;
}

enum LeaderboardType { group, round, stage, tournament, match }

class LeaderboardArgs extends Equatable {
  const LeaderboardArgs({
    required this.tournament,
    required this.type,
    required this.id,
    required this.name,
  });
  final TournamentEntity tournament;
  final LeaderboardType type;
  final int id;
  final String name;

  @override
  List<Object?> get props => [tournament, type, id, name];
}
