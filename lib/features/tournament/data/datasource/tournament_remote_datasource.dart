import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/tournament_meta_model.dart';
import '../models/tournament_model.dart';

abstract interface class TournamentRemoteDatasource {
  Future<List<TournamentModel>> getTournaments({int perPage = 15});
  Future<TournamentModel> createTournament(Map<String, dynamic> data);
  Future<TournamentMetaModel> getTournamentMeta();
}

class TournamentRemoteDatasourceImpl implements TournamentRemoteDatasource {
  TournamentRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TournamentModel>> getTournaments({int perPage = 15}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.tournaments,
        queryParameters: {'per_page': perPage},
      );
      appLogger.d('Tournaments response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
}
