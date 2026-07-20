import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/leaderboard_item_entity.dart';
import '../../domain/usecases/get_group_leaderboard_usecase.dart';
import '../../domain/usecases/get_round_leaderboard_usecase.dart';
import '../../domain/usecases/get_stage_leaderboard_usecase.dart';
import '../../domain/usecases/get_tournament_leaderboard_usecase.dart';
import '../../domain/usecases/get_match_leaderboard_usecase.dart';

enum LeaderboardStatus { initial, loading, success, empty, error }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final LeaderboardStatus status;
  final List<LeaderboardItemEntity> items;
  final String? errorMessage;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<LeaderboardItemEntity>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      LeaderboardState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, items, errorMessage];
}

class LeaderboardController extends FamilyNotifier<LeaderboardState, LeaderboardArgs> {
  @override
  LeaderboardState build(LeaderboardArgs arg) => const LeaderboardState();

  GetGroupLeaderboardUseCase get _getGroup => ref.read(getGroupLeaderboardUseCaseProvider);
  GetRoundLeaderboardUseCase get _getRound => ref.read(getRoundLeaderboardUseCaseProvider);
  GetStageLeaderboardUseCase get _getStage => ref.read(getStageLeaderboardUseCaseProvider);
  GetTournamentLeaderboardUseCase get _getTournament => ref.read(getTournamentLeaderboardUseCaseProvider);
  GetMatchLeaderboardUseCase get _getMatch => ref.read(getMatchLeaderboardUseCaseProvider);

  Future<void> fetchStandings() async {
    if (state.status == LeaderboardStatus.loading) return;
    state = state.copyWith(status: LeaderboardStatus.loading, clearError: true);
    try {
      final List<LeaderboardItemEntity> items;
      switch (arg.type) {
        case LeaderboardType.group:
          items = await _getGroup(arg.id);
          break;
        case LeaderboardType.round:
          items = await _getRound(arg.id);
          break;
        case LeaderboardType.stage:
          items = await _getStage(arg.id);
          break;
        case LeaderboardType.tournament:
          items = await _getTournament(arg.id);
          break;
        case LeaderboardType.match:
          items = await _getMatch(arg.id);
          break;
      }
      state = state.copyWith(
        status: items.isEmpty ? LeaderboardStatus.empty : LeaderboardStatus.success,
        items: items,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch leaderboard failed', error: e);
      state = state.copyWith(status: LeaderboardStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch leaderboard error', error: e);
      state = state.copyWith(status: LeaderboardStatus.error, errorMessage: 'Failed to load leaderboard.');
    }
  }
}

final leaderboardControllerProvider = NotifierProviderFamily<LeaderboardController, LeaderboardState, LeaderboardArgs>(
  LeaderboardController.new,
);
