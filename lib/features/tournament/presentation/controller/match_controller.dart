import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/usecases/get_matches_usecase.dart';
import '../../domain/usecases/create_match_usecase.dart';
import '../../domain/usecases/update_match_usecase.dart';
import '../../domain/usecases/delete_match_usecase.dart';
import '../../domain/usecases/add_match_team_usecase.dart';
import '../../domain/usecases/remove_match_team_usecase.dart';

enum MatchActionStatus { idle, loading, success, error }

class MatchState extends Equatable {
  const MatchState({
    this.status = MatchActionStatus.idle,
    this.saveStatus = MatchActionStatus.idle,
    this.deleteStatus = MatchActionStatus.idle,
    this.teamActionStatus = MatchActionStatus.idle,
    this.matches = const [],
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final MatchActionStatus status;
  final MatchActionStatus saveStatus;
  final MatchActionStatus deleteStatus;
  final MatchActionStatus teamActionStatus;
  final List<MatchEntity> matches;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  MatchState copyWith({
    MatchActionStatus? status,
    MatchActionStatus? saveStatus,
    MatchActionStatus? deleteStatus,
    MatchActionStatus? teamActionStatus,
    List<MatchEntity>? matches,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      MatchState(
        status: status ?? this.status,
        saveStatus: saveStatus ?? this.saveStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        teamActionStatus: teamActionStatus ?? this.teamActionStatus,
        matches: matches ?? this.matches,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        status,
        saveStatus,
        deleteStatus,
        teamActionStatus,
        matches,
        errorMessage,
        fieldErrors,
      ];
}

class MatchController extends FamilyNotifier<MatchState, int> {
  @override
  MatchState build(int groupId) => const MatchState();

  GetMatchesUseCase get _getMatches => ref.read(getMatchesUseCaseProvider);
  CreateMatchUseCase get _createMatch => ref.read(createMatchUseCaseProvider);
  UpdateMatchUseCase get _updateMatch => ref.read(updateMatchUseCaseProvider);
  DeleteMatchUseCase get _deleteMatch => ref.read(deleteMatchUseCaseProvider);
  AddMatchTeamUseCase get _addMatchTeam => ref.read(addMatchTeamUseCaseProvider);
  RemoveMatchTeamUseCase get _removeMatchTeam => ref.read(removeMatchTeamUseCaseProvider);

  Future<void> loadMatches() async {
    state = state.copyWith(status: MatchActionStatus.loading, clearError: true);
    try {
      final list = await _getMatches(arg);
      final sortedList = List<MatchEntity>.from(list)
        ..sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
      state = state.copyWith(status: MatchActionStatus.success, matches: sortedList);
    } on ApiException catch (e) {
      appLogger.e('Load matches failed', error: e);
      state = state.copyWith(status: MatchActionStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected load matches error', error: e);
      state = state.copyWith(status: MatchActionStatus.error, errorMessage: 'Failed to load matches');
    }
  }

  Future<bool> createMatch({
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  }) async {
    state = state.copyWith(saveStatus: MatchActionStatus.loading, clearError: true);
    try {
      await _createMatch(
        groupId: arg,
        matchNumber: matchNumber,
        name: name,
        map: map,
        scheduledAt: scheduledAt,
        status: status,
      );
      state = state.copyWith(saveStatus: MatchActionStatus.success);
      await loadMatches();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create match failed', error: e);
      state = state.copyWith(
        saveStatus: MatchActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create match error', error: e);
      state = state.copyWith(saveStatus: MatchActionStatus.error, errorMessage: 'Failed to create match');
      return false;
    }
  }

  Future<bool> updateMatch({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  }) async {
    state = state.copyWith(saveStatus: MatchActionStatus.loading, clearError: true);
    try {
      await _updateMatch(
        matchId: matchId,
        matchNumber: matchNumber,
        name: name,
        map: map,
        scheduledAt: scheduledAt,
        startedAt: startedAt,
        endedAt: endedAt,
        status: status,
      );
      state = state.copyWith(saveStatus: MatchActionStatus.success);
      await loadMatches();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Update match failed', error: e);
      state = state.copyWith(
        saveStatus: MatchActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected update match error', error: e);
      state = state.copyWith(saveStatus: MatchActionStatus.error, errorMessage: 'Failed to update match');
      return false;
    }
  }

  Future<bool> deleteMatch(int matchId) async {
    state = state.copyWith(deleteStatus: MatchActionStatus.loading, clearError: true);
    try {
      await _deleteMatch(matchId);
      state = state.copyWith(deleteStatus: MatchActionStatus.success);
      await loadMatches();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete match failed', error: e);
      state = state.copyWith(deleteStatus: MatchActionStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete match error', error: e);
      state = state.copyWith(deleteStatus: MatchActionStatus.error, errorMessage: 'Failed to delete match');
      return false;
    }
  }

  Future<bool> addTeamToMatch({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  }) async {
    state = state.copyWith(teamActionStatus: MatchActionStatus.loading, clearError: true);
    try {
      await _addMatchTeam(
        matchId: matchId,
        teamId: teamId,
        slot: slot,
        lane: lane,
      );
      state = state.copyWith(teamActionStatus: MatchActionStatus.success);
      await loadMatches();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Add team to match failed', error: e);
      state = state.copyWith(
        teamActionStatus: MatchActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected add team to match error', error: e);
      state = state.copyWith(teamActionStatus: MatchActionStatus.error, errorMessage: 'Failed to add team to match');
      return false;
    }
  }

  Future<bool> removeTeamFromMatch({
    required int matchId,
    required int teamId,
  }) async {
    state = state.copyWith(teamActionStatus: MatchActionStatus.loading, clearError: true);
    try {
      await _removeMatchTeam(
        matchId: matchId,
        teamId: teamId,
      );
      state = state.copyWith(teamActionStatus: MatchActionStatus.success);
      await loadMatches();
      return true;
    } on ApiException catch (e) {
      appLogger.e('Remove team from match failed', error: e);
      state = state.copyWith(teamActionStatus: MatchActionStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected remove team from match error', error: e);
      state = state.copyWith(teamActionStatus: MatchActionStatus.error, errorMessage: 'Failed to remove team from match');
      return false;
    }
  }
}

final matchControllerProvider =
    NotifierProviderFamily<MatchController, MatchState, int>(
  MatchController.new,
);
