import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/repositories/stage_repository.dart';
import '../datasource/stage_remote_datasource.dart';

class StageRepositoryImpl implements StageRepository {
  StageRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final StageRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<StageEntity>> getStages(int tournamentId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getStages(tournamentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<StageEntity> createStage({
    required int tournamentId,
    required String name,
    required String stageType,
    int? order,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.createStage(
      tournamentId: tournamentId,
      name: name,
      stageType: stageType,
      order: order,
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
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.updateStage(
      stageId: stageId,
      name: name,
      stageType: stageType,
      order: order,
    );
  }

  @override
  Future<void> deleteStage(int stageId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteStage(stageId);
  }
}
