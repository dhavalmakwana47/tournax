import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasource/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final GroupRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<GroupEntity>> getGroups(int roundId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getGroups(roundId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<GroupEntity> createGroup({
    required int roundId,
    required String name,
    int? displayOrder,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.createGroup(
      roundId: roundId,
      name: name,
      displayOrder: displayOrder,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<GroupEntity> showGroup(int groupId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.showGroup(groupId);
    return model.toEntity();
  }

  @override
  Future<void> updateGroup({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.updateGroup(
      groupId: groupId,
      name: name,
      displayOrder: displayOrder,
      status: status,
    );
  }

  @override
  Future<void> deleteGroup(int groupId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteGroup(groupId);
  }

  @override
  Future<GroupEntity> addGroupTeam({
    required int groupId,
    required int teamId,
    int? seed,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.addGroupTeam(
      groupId: groupId,
      teamId: teamId,
      seed: seed,
    );
    return model.toEntity();
  }

  @override
  Future<GroupEntity> removeGroupTeam({
    required int groupId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.removeGroupTeam(
      groupId: groupId,
      teamId: teamId,
    );
    return model.toEntity();
  }
}
