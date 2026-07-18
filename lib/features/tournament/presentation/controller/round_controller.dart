import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/usecases/get_rounds_usecase.dart';
import '../../domain/usecases/create_round_usecase.dart';
import '../../domain/usecases/delete_round_usecase.dart';

enum RoundListStatus { initial, loading, success, empty, error }
enum RoundActionStatus { idle, loading, success, error }

class RoundState extends Equatable {
  const RoundState({
    this.listStatus = RoundListStatus.initial,
    this.createStatus = RoundActionStatus.idle,
    this.deleteStatus = RoundActionStatus.idle,
    this.rounds = const [],
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final RoundListStatus listStatus;
  final RoundActionStatus createStatus;
  final RoundActionStatus deleteStatus;
  final List<RoundEntity> rounds;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  RoundState copyWith({
    RoundListStatus? listStatus,
    RoundActionStatus? createStatus,
    RoundActionStatus? deleteStatus,
    List<RoundEntity>? rounds,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      RoundState(
        listStatus: listStatus ?? this.listStatus,
        createStatus: createStatus ?? this.createStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        rounds: rounds ?? this.rounds,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [listStatus, createStatus, deleteStatus, rounds, errorMessage, fieldErrors];
}

class RoundController extends FamilyNotifier<RoundState, int> {
  @override
  RoundState build(int stageId) => const RoundState();

  GetRoundsUseCase get _getRounds => ref.read(getRoundsUseCaseProvider);
  CreateRoundUseCase get _createRound => ref.read(createRoundUseCaseProvider);
  DeleteRoundUseCase get _deleteRound => ref.read(deleteRoundUseCaseProvider);

  Future<void> fetchRounds() async {
    if (state.listStatus == RoundListStatus.loading) return;
    state = state.copyWith(listStatus: RoundListStatus.loading, clearError: true);
    try {
      final rounds = await _getRounds(arg);
      state = state.copyWith(
        listStatus: rounds.isEmpty ? RoundListStatus.empty : RoundListStatus.success,
        rounds: rounds,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch rounds failed', error: e);
      state = state.copyWith(listStatus: RoundListStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch rounds error', error: e);
      state = state.copyWith(listStatus: RoundListStatus.error, errorMessage: 'Failed to load rounds.');
    }
  }

  Future<bool> createRound({
    required String name,
    int? roundNumber,
    int? numberOfGroups,
  }) async {
    state = state.copyWith(createStatus: RoundActionStatus.loading, clearError: true);
    try {
      final round = await _createRound(
        stageId: arg,
        name: name,
        roundNumber: roundNumber,
        numberOfGroups: numberOfGroups,
      );
      state = state.copyWith(
        createStatus: RoundActionStatus.success,
        rounds: [...state.rounds, round],
        listStatus: RoundListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create round failed', error: e);
      state = state.copyWith(
        createStatus: RoundActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create round error', error: e);
      state = state.copyWith(
        createStatus: RoundActionStatus.error,
        errorMessage: 'Failed to create round.',
      );
      return false;
    }
  }

  Future<bool> deleteRound(int roundId) async {
    state = state.copyWith(deleteStatus: RoundActionStatus.loading, clearError: true);
    try {
      await _deleteRound(roundId);
      final remaining = state.rounds.where((r) => r.id != roundId).toList();
      state = state.copyWith(
        deleteStatus: RoundActionStatus.success,
        rounds: remaining,
        listStatus: remaining.isEmpty ? RoundListStatus.empty : RoundListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete round failed', error: e);
      state = state.copyWith(deleteStatus: RoundActionStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete round error', error: e);
      state = state.copyWith(deleteStatus: RoundActionStatus.error, errorMessage: 'Failed to delete round.');
      return false;
    }
  }

  void resetCreateStatus() => state = state.copyWith(createStatus: RoundActionStatus.idle, clearError: true);
  void resetDeleteStatus() => state = state.copyWith(deleteStatus: RoundActionStatus.idle, clearError: true);
}

final roundControllerProvider = NotifierProviderFamily<RoundController, RoundState, int>(
  RoundController.new,
);
