import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';
import '../repositories/tournament_repository.dart';

class GetGroupsUseCase {
  GetGroupsUseCase(this._repository);

  final GroupRepository _repository;

  Future<PaginatedResult<GroupEntity>> call({
    required int roundId,
    int page = 1,
    int perPage = 10,
  }) =>
      _repository.getGroups(
        roundId: roundId,
        page: page,
        perPage: perPage,
      );
}
