import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/repositories/round_repository.dart';
import '../datasource/round_remote_datasource.dart';

import '../../domain/repositories/tournament_repository.dart';

class RoundRepositoryImpl implements RoundRepository {
  RoundRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final RoundRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<PaginatedResult<RoundEntity>> getRounds({
    required int stageId,
    int page = 1,
    int perPage = 10,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final res = await remoteDatasource.getRounds(
      stageId: stageId,
      page: page,
      perPage: perPage,
    );
    return PaginatedResult<RoundEntity>(
      items: res.items.map((m) => m.toEntity()).toList(),
      hasMore: res.hasMore,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
    );
  }

  @override
  Future<RoundEntity> createRound({
    required int stageId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.createRound(
      stageId: stageId,
      name: name,
      roundNumber: roundNumber,
      numberOfGroups: numberOfGroups,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<RoundEntity> showRound(int roundId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.showRound(roundId);
    return model.toEntity();
  }

  @override
  Future<RoundEntity> updateRound({
    required int roundId,
    required String name,
    int? roundNumber,
    int? numberOfGroups,
    required String status,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.updateRound(
      roundId: roundId,
      name: name,
      roundNumber: roundNumber,
      numberOfGroups: numberOfGroups,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteRound(int roundId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteRound(roundId);
  }
}
