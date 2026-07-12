import '../entities/player_search_result.dart';
import '../repositories/player_search_repository.dart';

class SearchPlayerUseCase {
  SearchPlayerUseCase(this._repository);

  final PlayerSearchRepository _repository;

  Future<List<PlayerSearchResult>> call(String query) =>
      _repository.search(query);
}
