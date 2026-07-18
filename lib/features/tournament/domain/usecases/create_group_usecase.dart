import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class CreateGroupUseCase {
  CreateGroupUseCase(this._repository);

  final GroupRepository _repository;

  Future<GroupEntity> call({
    required int roundId,
    required String name,
    int? displayOrder,
    String? status,
  }) =>
      _repository.createGroup(
        roundId: roundId,
        name: name,
        displayOrder: displayOrder,
        status: status,
      );
}
