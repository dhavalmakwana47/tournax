import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  Future<List<GroupEntity>> getGroups(int roundId);
  Future<GroupEntity> createGroup({
    required int roundId,
    required String name,
    int? displayOrder,
    String? status,
  });
  Future<GroupEntity> showGroup(int groupId);
  Future<void> updateGroup({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  });
  Future<void> deleteGroup(int groupId);
  Future<GroupEntity> addGroupTeam({
    required int groupId,
    required int teamId,
    int? seed,
  });
  Future<GroupEntity> removeGroupTeam({
    required int groupId,
    required int teamId,
  });
}
