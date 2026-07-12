import '../entities/player_search_result.dart';

abstract interface class PlayerSearchRepository {
  Future<List<PlayerSearchResult>> search(String query);
}
