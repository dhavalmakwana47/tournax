import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/match_result_entity.dart';
import '../../domain/usecases/submit_match_results_usecase.dart';
import '../../domain/usecases/get_match_results_usecase.dart';
import '../../domain/usecases/delete_match_results_usecase.dart';

enum MatchResultStatus { idle, loading, success, error }

class MatchResultState extends Equatable {
  const MatchResultState({
    this.status = MatchResultStatus.idle,
    this.saveStatus = MatchResultStatus.idle,
    this.deleteStatus = MatchResultStatus.idle,
    this.results = const [],
    this.errorMessage,
  });

  final MatchResultStatus status;
  final MatchResultStatus saveStatus;
  final MatchResultStatus deleteStatus;
  final List<TeamResultEntity> results;
  final String? errorMessage;

  MatchResultState copyWith({
    MatchResultStatus? status,
    MatchResultStatus? saveStatus,
    MatchResultStatus? deleteStatus,
    List<TeamResultEntity>? results,
    String? errorMessage,
    bool clearError = false,
  }) =>
      MatchResultState(
        status: status ?? this.status,
        saveStatus: saveStatus ?? this.saveStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        results: results ?? this.results,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, saveStatus, deleteStatus, results, errorMessage];
}

class MatchResultController extends FamilyNotifier<MatchResultState, int> {
  @override
  MatchResultState build(int matchId) => const MatchResultState();

  SubmitMatchResultsUseCase get _submitResults => ref.read(submitMatchResultsUseCaseProvider);
  GetMatchResultsUseCase get _getResults => ref.read(getMatchResultsUseCaseProvider);
  DeleteMatchResultsUseCase get _deleteResults => ref.read(deleteMatchResultsUseCaseProvider);

  Future<void> fetchResults() async {
    state = state.copyWith(status: MatchResultStatus.loading, clearError: true);
    try {
      final list = await _getResults(arg);
      state = state.copyWith(status: MatchResultStatus.success, results: list);
    } on ApiException catch (e) {
      appLogger.e('Fetch match results failed', error: e);
      state = state.copyWith(status: MatchResultStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch match results error', error: e);
      state = state.copyWith(status: MatchResultStatus.error, errorMessage: 'Failed to load match results');
    }
  }

  Future<bool> saveResults(List<TeamResultEntity> results) async {
    state = state.copyWith(saveStatus: MatchResultStatus.loading, clearError: true);
    try {
      await _submitResults(matchId: arg, results: results);
      state = state.copyWith(saveStatus: MatchResultStatus.success);
      await fetchResults();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Save match results failed', error: e);
      state = state.copyWith(saveStatus: MatchResultStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected save match results error', error: e);
      state = state.copyWith(saveStatus: MatchResultStatus.error, errorMessage: 'Failed to save match results');
      return false;
    }
  }

  Future<bool> clearResults() async {
    state = state.copyWith(deleteStatus: MatchResultStatus.loading, clearError: true);
    try {
      await _deleteResults(arg);
      state = state.copyWith(deleteStatus: MatchResultStatus.success, results: const []);
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete match results failed', error: e);
      state = state.copyWith(deleteStatus: MatchResultStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete match results error', error: e);
      state = state.copyWith(deleteStatus: MatchResultStatus.error, errorMessage: 'Failed to delete match results');
      return false;
    }
  }
}

final matchResultControllerProvider = NotifierProviderFamily<MatchResultController, MatchResultState, int>(
  MatchResultController.new,
);
