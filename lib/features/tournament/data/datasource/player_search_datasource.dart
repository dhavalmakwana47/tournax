import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/player_search_model.dart';

abstract interface class PlayerSearchDatasource {
  Future<List<PlayerSearchModel>> search(String query);
}

class PlayerSearchDatasourceImpl implements PlayerSearchDatasource {
  PlayerSearchDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PlayerSearchModel>> search(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.playersSearch,
        queryParameters: {'q': query},
      );
      appLogger.d('Player search response: $response');
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => PlayerSearchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      appLogger.e('Player search parse error', error: e, stackTrace: st);
      throw ApiException.unexpected();
    }
  }
}
