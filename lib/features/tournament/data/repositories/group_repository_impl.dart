import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasource/group_remote_datasource.dart';

import '../../domain/repositories/tournament_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final GroupRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<PaginatedResult<GroupEntity>> getGroups({
    required int roundId,
    int page = 1,
    int perPage = 10,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final res = await remoteDatasource.getGroups(
      roundId: roundId,
      page: page,
      perPage: perPage,
    );
    return PaginatedResult<GroupEntity>(
      items: res.items.map((m) => m.toEntity()).toList(),
      hasMore: res.hasMore,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
    );
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
