import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/repositories/stage_repository.dart';
import '../datasource/stage_remote_datasource.dart';

import '../../domain/repositories/tournament_repository.dart';

class StageRepositoryImpl implements StageRepository {
  StageRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final StageRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<PaginatedResult<StageEntity>> getStages({
    required int tournamentId,
    int page = 1,
    int perPage = 10,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final res = await remoteDatasource.getStages(
      tournamentId: tournamentId,
      page: page,
      perPage: perPage,
    );
    return PaginatedResult<StageEntity>(
      items: res.items.map((m) => m.toEntity()).toList(),
      hasMore: res.hasMore,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
    );
  }

  @override
  Future<StageEntity> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.createStage(
      tournamentId: tournamentId,
      name: name,
      stageType: stageType,
      order: order,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<StageEntity> showStage(int stageId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.showStage(stageId);
    return model.toEntity();
  }

  @override
  Future<void> updateStage({
    required int stageId,
    required String name,
    required String stageType,
    int? order,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.updateStage(
      stageId: stageId,
      name: name,
      stageType: stageType,
      order: order,
      status: status,
    );
  }

  @override
  Future<void> deleteStage(int stageId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteStage(stageId);
  }
}
