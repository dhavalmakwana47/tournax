import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchesUseCase {
  GetMatchesUseCase(this._repository);
  final MatchRepository _repository;
  Future<List<MatchEntity>> call(int groupId) => _repository.getMatches(groupId);
}
