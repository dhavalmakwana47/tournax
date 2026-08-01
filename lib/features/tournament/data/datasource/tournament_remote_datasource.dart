import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/tournament_meta_model.dart';
import '../models/tournament_model.dart';

class PaginatedTournaments {
  const PaginatedTournaments({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });

  final List<TournamentModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
}

abstract interface class TournamentRemoteDatasource {
  Future<PaginatedTournaments> getTournaments({
    int page = 1,
    int perPage = 5,
    String? status,
  });
  Future<TournamentModel> createTournament(Map<String, dynamic> data);
  Future<TournamentMetaModel> getTournamentMeta();
  Future<TournamentModel> showTournament(int tournamentId);
  Future<void> updateTournament(Map<String, dynamic> data);
}

class TournamentRemoteDatasourceImpl implements TournamentRemoteDatasource {
  TournamentRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedTournaments> getTournaments({
    int page = 1,
    int perPage = 5,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      final response = await _apiClient.get(
        ApiConstants.tournaments,
        queryParameters: queryParams,
      );
      appLogger.d('Tournaments response: $response');
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;
      final currentPage = meta?['current_page'] as int? ?? page;
      final lastPage = meta?['last_page'] as int? ?? page;
      final items = data != null
          ? data
              .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : <TournamentModel>[];
      final hasMore = meta != null ? currentPage < lastPage : items.length >= perPage;

      return PaginatedTournaments(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Tournaments parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TournamentModel> createTournament(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiClient.post(ApiConstants.tournaments, data: data);
      appLogger.d('Create tournament response: $response');
      final responseData = response['data'] as Map<String, dynamic>?;
      if (responseData == null) throw ApiException.unexpected();
      return TournamentModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Create tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TournamentMetaModel> getTournamentMeta() async {
    try {
      final response = await _apiClient.get(ApiConstants.tournamentsMeta);
      appLogger.d('Tournament meta response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TournamentMetaModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Tournament meta parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<TournamentModel> showTournament(int tournamentId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tournamentsShow,
        data: {'tournament_id': tournamentId},
      );
      appLogger.d('Show tournament response: $response');
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) throw ApiException.unexpected();
      return TournamentModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Show tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }

  @override
  Future<void> updateTournament(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiConstants.tournamentsUpdate, data: data);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Update tournament error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
