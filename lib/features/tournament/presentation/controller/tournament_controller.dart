import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_meta_entity.dart';
import '../../domain/usecases/get_tournaments_usecase.dart';
import '../../domain/usecases/create_tournament_usecase.dart';
import '../../domain/usecases/get_tournament_meta_usecase.dart';

enum TournamentListStatus { initial, loading, success, empty, error }

enum TournamentCreateStatus { idle, loading, success, error }

enum TournamentMetaStatus { initial, loading, success, error }

class TournamentState extends Equatable {
  const TournamentState({
    this.listStatus = TournamentListStatus.initial,
    this.createStatus = TournamentCreateStatus.idle,
    this.metaStatus = TournamentMetaStatus.initial,
    this.tournaments = const [],
    this.meta,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final TournamentListStatus listStatus;
  final TournamentCreateStatus createStatus;
  final TournamentMetaStatus metaStatus;
  final List<TournamentEntity> tournaments;
  final TournamentMetaEntity? meta;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  TournamentState copyWith({
    TournamentListStatus? listStatus,
    TournamentCreateStatus? createStatus,
    TournamentMetaStatus? metaStatus,
    List<TournamentEntity>? tournaments,
    TournamentMetaEntity? meta,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      TournamentState(
        listStatus: listStatus ?? this.listStatus,
        createStatus: createStatus ?? this.createStatus,
        metaStatus: metaStatus ?? this.metaStatus,
        tournaments: tournaments ?? this.tournaments,
        meta: meta ?? this.meta,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        listStatus,
        createStatus,
        metaStatus,
        tournaments,
        meta,
        errorMessage,
        fieldErrors,
      ];
}

class TournamentController extends Notifier<TournamentState> {
  @override
  TournamentState build() => const TournamentState();

  GetTournamentsUseCase get _getUseCase =>
      ref.read(getTournamentsUseCaseProvider);
  CreateTournamentUseCase get _createUseCase =>
      ref.read(createTournamentUseCaseProvider);
  GetTournamentMetaUseCase get _metaUseCase =>
      ref.read(getTournamentMetaUseCaseProvider);

  Future<void> fetchTournamentMeta() async {
    if (state.metaStatus == TournamentMetaStatus.loading) return;
    state = state.copyWith(metaStatus: TournamentMetaStatus.loading);
    try {
      final meta = await _metaUseCase();
      state = state.copyWith(metaStatus: TournamentMetaStatus.success, meta: meta);
    } on ApiException catch (e) {
      appLogger.e('Fetch tournament meta failed', error: e);
      state = state.copyWith(
        metaStatus: TournamentMetaStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      appLogger.e('Unexpected fetch tournament meta error', error: e);
      state = state.copyWith(
        metaStatus: TournamentMetaStatus.error,
        errorMessage: 'Failed to load tournament options.',
      );
    }
  }

  Future<void> fetchTournaments() async {
    if (state.listStatus == TournamentListStatus.loading) return;
    state = state.copyWith(
        listStatus: TournamentListStatus.loading, clearError: true);
    try {
      final list = await _getUseCase();
      state = state.copyWith(
        listStatus: list.isEmpty
            ? TournamentListStatus.empty
            : TournamentListStatus.success,
        tournaments: list,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch tournaments failed', error: e);
      state = state.copyWith(
          listStatus: TournamentListStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch tournaments error', error: e);
      state = state.copyWith(
        listStatus: TournamentListStatus.error,
        errorMessage: 'Failed to load tournaments.',
      );
    }
  }

  Future<bool> createTournament({
    required String name,
    required String mode,
    required String tournamentType,
    required int maxTeams,
    required int maxPlayersPerTeam,
    required String startDate,
    required String endDate,
    String? description,
    String? registrationStart,
    String? registrationEnd,
  }) async {
    state = state.copyWith(
        createStatus: TournamentCreateStatus.loading, clearError: true);
    try {
      final created = await _createUseCase(
        name: name,
        mode: mode,
        tournamentType: tournamentType,
        maxTeams: maxTeams,
        maxPlayersPerTeam: maxPlayersPerTeam,
        startDate: startDate,
        endDate: endDate,
        description: description,
        registrationStart: registrationStart,
        registrationEnd: registrationEnd,
      );
      state = state.copyWith(
        createStatus: TournamentCreateStatus.success,
        tournaments: [created, ...state.tournaments],
        listStatus: TournamentListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create tournament failed', error: e);
      state = state.copyWith(
        createStatus: TournamentCreateStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create tournament error', error: e);
      state = state.copyWith(
        createStatus: TournamentCreateStatus.error,
        errorMessage: 'Failed to create tournament.',
      );
      return false;
    }
  }

  void resetCreateStatus() => state =
      state.copyWith(createStatus: TournamentCreateStatus.idle, clearError: true);
}

final tournamentControllerProvider =
    NotifierProvider<TournamentController, TournamentState>(
  TournamentController.new,
);
