import '../repositories/group_repository.dart';

class UpdateGroupUseCase {
  UpdateGroupUseCase(this._repository);

  final GroupRepository _repository;

  Future<void> call({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  }) =>
      _repository.updateGroup(
        groupId: groupId,
        name: name,
        displayOrder: displayOrder,
        status: status,
      );
}
