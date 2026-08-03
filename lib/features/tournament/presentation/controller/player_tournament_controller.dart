import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/usecases/get_participated_tournaments_usecase.dart';
import '../../domain/usecases/get_player_tournaments_usecase.dart';
import '../../domain/usecases/join_tournament_usecase.dart';
import '../../domain/usecases/leave_tournament_usecase.dart';

enum PlayerTournamentStatus { initial, loading, success, error }

class PlayerTournamentState extends Equatable {
  const PlayerTournamentState({
    this.status = PlayerTournamentStatus.initial,
    this.tournaments = const <TournamentEntity>[],
    this.participatedTournaments = const <TournamentEntity>[],
    this.selectedTab = 0,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.errorMessage,
    this.actionMessage,
    this.isActionLoading = false,
  });

  final PlayerTournamentStatus status;
  final List<TournamentEntity> tournaments;
  final List<TournamentEntity> participatedTournaments;
  final int selectedTab;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? actionMessage;
  final bool isActionLoading;

  PlayerTournamentState copyWith({
    PlayerTournamentStatus? status,
    List<TournamentEntity>? tournaments,
    List<TournamentEntity>? participatedTournaments,
    int? selectedTab,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? errorMessage,
    String? actionMessage,
    bool? isActionLoading,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return PlayerTournamentState(
      status: status ?? this.status,
      tournaments: tournaments ?? this.tournaments,
      participatedTournaments:
          participatedTournaments ?? this.participatedTournaments,
      selectedTab: selectedTab ?? this.selectedTab,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tournaments,
        participatedTournaments,
        selectedTab,
        hasMore,
        currentPage,
        isLoadingMore,
        errorMessage,
        actionMessage,
        isActionLoading,
      ];
}

class PlayerTournamentController extends Notifier<PlayerTournamentState> {
  @override
  PlayerTournamentState build() => const PlayerTournamentState();

  GetPlayerTournamentsUseCase get _getPublicUseCase =>
      ref.read(getPlayerTournamentsUseCaseProvider);
  GetParticipatedTournamentsUseCase get _getParticipatedUseCase =>
      ref.read(getParticipatedTournamentsUseCaseProvider);
  JoinTournamentUseCase get _joinUseCase =>
      ref.read(joinTournamentUseCaseProvider);
  LeaveTournamentUseCase get _leaveUseCase =>
      ref.read(leaveTournamentUseCaseProvider);

  void selectTab(int index) {
    state = state.copyWith(selectedTab: index, clearError: true);
    if (index == 0 && state.tournaments.isEmpty) {
      fetchPublicTournaments();
    } else if (index == 1 && state.participatedTournaments.isEmpty) {
      fetchParticipatedTournaments();
    }
  }

  Future<void> fetchPublicTournaments({
    bool refresh = false,
    String? status,
    String? search,
  }) async {
    if (refresh) {
      state = state.copyWith(
        status: PlayerTournamentStatus.loading,
        currentPage: 1,
        clearError: true,
      );
    } else if (state.status == PlayerTournamentStatus.initial) {
      state = state.copyWith(status: PlayerTournamentStatus.loading);
    }

    try {
      final res = await _getPublicUseCase(
        page: refresh ? 1 : state.currentPage,
        status: status,
        search: search,
      );

      final List<TournamentEntity> entities = res.items;

      state = state.copyWith(
        status: PlayerTournamentStatus.success,
        tournaments:
            refresh ? entities : [...state.tournaments, ...entities],
        hasMore: res.hasMore,
        currentPage: res.currentPage,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch player public tournaments failed', error: e);
      state = state.copyWith(
        status: PlayerTournamentStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      appLogger.e('Unexpected player public tournaments error', error: e);
      state = state.copyWith(
        status: PlayerTournamentStatus.error,
        errorMessage: 'Failed to load tournaments.',
      );
    }
  }

  Future<void> fetchParticipatedTournaments({
    bool refresh = false,
    String? status,
  }) async {
    if (refresh) {
      state = state.copyWith(
        status: PlayerTournamentStatus.loading,
        currentPage: 1,
        clearError: true,
      );
    } else if (state.participatedTournaments.isEmpty) {
      state = state.copyWith(status: PlayerTournamentStatus.loading);
    }

    try {
      final res = await _getParticipatedUseCase(
        page: refresh ? 1 : state.currentPage,
        status: status,
      );

      final List<TournamentEntity> entities = res.items;

      state = state.copyWith(
        status: PlayerTournamentStatus.success,
        participatedTournaments: refresh
            ? entities
            : [...state.participatedTournaments, ...entities],
        hasMore: res.hasMore,
        currentPage: res.currentPage,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch participated tournaments failed', error: e);
      state = state.copyWith(
        status: PlayerTournamentStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      appLogger.e('Unexpected participated tournaments error', error: e);
      state = state.copyWith(
        status: PlayerTournamentStatus.error,
        errorMessage: 'Failed to load participated tournaments.',
      );
    }
  }

  Future<bool> joinTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    state = state.copyWith(isActionLoading: true, clearActionMessage: true);
    try {
      final res = await _joinUseCase(
        tournamentId: tournamentId,
        teamId: teamId,
      );
      final msg =
          res['message'] as String? ?? 'Joined tournament successfully!';
      state = state.copyWith(
        isActionLoading: false,
        actionMessage: msg,
      );
      fetchParticipatedTournaments(refresh: true);
      return true;
    } on ApiException catch (e) {
      appLogger.e('Join tournament failed', error: e);
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected join tournament error', error: e);
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to join tournament.',
      );
      return false;
    }
  }

  Future<bool> leaveTournament({
    required int tournamentId,
    required int teamId,
  }) async {
    state = state.copyWith(isActionLoading: true, clearActionMessage: true);
    try {
      final msg = await _leaveUseCase(
        tournamentId: tournamentId,
        teamId: teamId,
      );
      state = state.copyWith(
        isActionLoading: false,
        actionMessage: msg,
      );
      fetchParticipatedTournaments(refresh: true);
      return true;
    } on ApiException catch (e) {
      appLogger.e('Leave tournament failed', error: e);
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected leave tournament error', error: e);
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to leave tournament.',
      );
      return false;
    }
  }
}

final playerTournamentControllerProvider =
    NotifierProvider<PlayerTournamentController, PlayerTournamentState>(
  PlayerTournamentController.new,
  dependencies: [],
);
