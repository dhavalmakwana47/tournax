import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/repositories/round_repository.dart';
import '../datasource/round_remote_datasource.dart';

class RoundRepositoryImpl implements RoundRepository {
  RoundRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final RoundRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<RoundEntity>> getRounds(int stageId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getRounds(stageId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RoundEntity> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.createRound(
      stageId: stageId,
      name: name,
      roundNumber: roundNumber,
      numberOfGroups: numberOfGroups,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteRound(int roundId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteRound(roundId);
  }
}
