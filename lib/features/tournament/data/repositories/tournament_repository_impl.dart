import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_meta_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasource/tournament_remote_datasource.dart';
import '../models/tournament_model.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final TournamentRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<TournamentEntity>> getTournaments() async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getTournaments();
    return models.map(_toEntity).toList();
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final data = <String, dynamic>{
      'name': name,
      'mode': mode,
      'tournament_type': tournamentType,
      'max_teams': maxTeams,
      'max_players_per_team': maxPlayersPerTeam,
      'start_date': startDate,
      'end_date': endDate,
      if (description != null) 'description': description,
      if (registrationStart != null) 'registration_start': registrationStart,
      if (registrationEnd != null) 'registration_end': registrationEnd,
    };
    final model = await remoteDatasource.createTournament(data);
    return _toEntity(model);
  }

  TournamentEntity _toEntity(TournamentModel m) => TournamentEntity(
        id: m.id,
        name: m.name,
        slug: m.slug,
        mode: m.mode,
        tournamentType: m.tournamentType,
        status: m.status,
        maxTeams: m.maxTeams,
        maxPlayersPerTeam: m.maxPlayersPerTeam,
        startDate: m.startDate,
        endDate: m.endDate,
        createdAt: m.createdAt,
      );

  @override
  Future<TournamentMetaEntity> getTournamentMeta() async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.getTournamentMeta();
    return model.toEntity();
  }
}
