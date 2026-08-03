import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/tournament_model.dart';
import 'tournament_remote_datasource.dart';

abstract interface class PlayerTournamentRemoteDatasource {
  Future<PaginatedTournaments> getPublicTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
  });

  Future<PaginatedTournaments> getParticipatedTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
  });

  Future<TournamentModel> showTournament(int tournamentId);

  Future<Map<String, dynamic>> joinTournament({
    required int tournamentId,
    required int teamId,
  });

  Future<String> leaveTournament({
    required int tournamentId,
    required int teamId,
  });
}

class PlayerTournamentRemoteDatasourceImpl
    implements PlayerTournamentRemoteDatasource {
  PlayerTournamentRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  PaginatedTournaments _parsePaginated(
      Map<String, dynamic> response, int page, int perPage) {
    final data = response['data'] as List<dynamic>?;
    final meta = response['meta'] as Map<String, dynamic>?;
    final currentPage = _toInt(meta?['current_page'], page);
    final lastPage = _toInt(meta?['last_page'], page);
    final items = data != null
        ? data
            .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <TournamentModel>[];
    final hasMore =
        meta != null ? currentPage < lastPage : items.length >= perPage;

    return PaginatedTournaments(
      items: items,
      hasMore: hasMore,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  @override
  Future<PaginatedTournaments> getPublicTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
  }) async {
    try {
      final body = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final response = await _apiClient.post(
        ApiConstants.playerTournaments,
        data: body,
      );
      return _parsePaginated(response, page, perPage);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player public tournaments parse error',
          error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<PaginatedTournaments> getParticipatedTournaments({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      final response = await _apiClient.post(
        ApiConstants.playerTournamentsParticipated,
        data: body,
      );
      return _parsePaginated(response, page, perPage);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player participated tournaments parse error',
          error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TournamentModel> showTournament(int tournamentId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.playerTournamentsShow,
        data: {'tournament_id': tournamentId},
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TournamentModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player show tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<Map<String, dynamic>> joinTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.playerTournamentsJoin,
        data: {
          'tournament_id': tournamentId,
          'team_id': teamId,
        },
      );
      return response;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player join tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<String> leaveTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.playerTournamentsLeave,
        data: {
          'tournament_id': tournamentId,
          'team_id': teamId,
        },
      );
      return response['message'] as String? ?? 'Left tournament successfully.';
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player leave tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
