import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/player_search_result.dart';
import '../../domain/repositories/player_search_repository.dart';
import '../datasource/player_search_datasource.dart';

class PlayerSearchRepositoryImpl implements PlayerSearchRepository {
  PlayerSearchRepositoryImpl({
    required this.datasource,
    required this.networkInfo,
  });

  final PlayerSearchDatasource datasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<PlayerSearchResult>> search(String query) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await datasource.search(query);
    return models.map((m) => m.toEntity()).toList();
  }
}
