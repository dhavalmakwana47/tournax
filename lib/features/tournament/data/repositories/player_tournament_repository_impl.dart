import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/repositories/player_tournament_repository.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasource/player_tournament_remote_datasource.dart';
import '../models/tournament_model.dart';

class PlayerTournamentRepositoryImpl implements PlayerTournamentRepository {
  PlayerTournamentRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final PlayerTournamentRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  TournamentEntity _toEntity(TournamentModel m) => TournamentEntity(
        id: m.id,
        name: m.name,
        slug: m.slug,
        mode: m.mode,
        tournamentType: m.tournamentType,
        status: m.status,
        maxTeams: m.maxTeams,
        maxPlayersPerTeam: m.maxPlayersPerTeam,
        description: m.description,
        startDate: m.startDate,
        endDate: m.endDate,
        registrationStart: m.registrationStart,
        registrationEnd: m.registrationEnd,
        checkInEnabled: m.checkInEnabled,
        allowSubstitute: m.allowSubstitute,
        autoQualify: m.autoQualify,
        leaderboardType: m.leaderboardType,
        rules: m.rules,
        createdAt: m.createdAt,
      );

  @override
  Future<PaginatedResult<TournamentEntity>> getPublicTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final res = await remoteDatasource.getPublicTournaments(
      page: page,
      perPage: perPage,
      status: status,
      search: search,
    );
    return PaginatedResult<TournamentEntity>(
      items: res.items.map(_toEntity).toList(),
      hasMore: res.hasMore,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
    );
  }

  @override
  Future<PaginatedResult<TournamentEntity>> getParticipatedTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final res = await remoteDatasource.getParticipatedTournaments(
      page: page,
      perPage: perPage,
      status: status,
    );
    return PaginatedResult<TournamentEntity>(
      items: res.items.map(_toEntity).toList(),
      hasMore: res.hasMore,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
    );
  }

  @override
  Future<TournamentEntity> showTournament(int tournamentId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.showTournament(tournamentId);
    return _toEntity(model);
  }

  @override
  Future<Map<String, dynamic>> joinTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    return remoteDatasource.joinTournament(
      tournamentId: tournamentId,
      teamId: teamId,
    );
  }

  @override
  Future<String> leaveTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    return remoteDatasource.leaveTournament(
      tournamentId: tournamentId,
      teamId: teamId,
    );
  }
}
