import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/usecases/get_teams_usecase.dart';
import '../../domain/usecases/create_team_usecase.dart';
import '../../domain/usecases/get_team_usecase.dart';
import '../../domain/usecases/update_team_usecase.dart';
import '../../domain/usecases/delete_team_usecase.dart';
import '../../domain/usecases/get_players_usecase.dart';
import '../../domain/usecases/add_player_usecase.dart';
import '../../domain/usecases/get_player_usecase.dart';
import '../../domain/usecases/update_player_usecase.dart';
import '../../domain/usecases/delete_player_usecase.dart';

enum TeamListStatus { initial, loading, success, empty, error }

enum PlayerListStatus { initial, loading, success, empty, error }

enum TeamActionStatus { idle, loading, success, error }

class TeamState extends Equatable {
  const TeamState({
    this.listStatus = TeamListStatus.initial,
    this.playerListStatus = PlayerListStatus.initial,
    this.createTeamStatus = TeamActionStatus.idle,
    this.updateTeamStatus = TeamActionStatus.idle,
    this.deleteTeamStatus = TeamActionStatus.idle,
    this.addPlayerStatus = TeamActionStatus.idle,
    this.updatePlayerStatus = TeamActionStatus.idle,
    this.deletePlayerStatus = TeamActionStatus.idle,
    this.teams = const [],
    this.players = const [],
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final TeamListStatus listStatus;
  final PlayerListStatus playerListStatus;
  final TeamActionStatus createTeamStatus;
  final TeamActionStatus updateTeamStatus;
  final TeamActionStatus deleteTeamStatus;
  final TeamActionStatus addPlayerStatus;
  final TeamActionStatus updatePlayerStatus;
  final TeamActionStatus deletePlayerStatus;
  final List<TeamEntity> teams;
  final List<PlayerEntity> players;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  TeamState copyWith({
    TeamListStatus? listStatus,
    PlayerListStatus? playerListStatus,
    TeamActionStatus? createTeamStatus,
    TeamActionStatus? updateTeamStatus,
    TeamActionStatus? deleteTeamStatus,
    TeamActionStatus? addPlayerStatus,
    TeamActionStatus? updatePlayerStatus,
    TeamActionStatus? deletePlayerStatus,
    List<TeamEntity>? teams,
    List<PlayerEntity>? players,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) =>
      TeamState(
        listStatus: listStatus ?? this.listStatus,
        playerListStatus: playerListStatus ?? this.playerListStatus,
        createTeamStatus: createTeamStatus ?? this.createTeamStatus,
        updateTeamStatus: updateTeamStatus ?? this.updateTeamStatus,
        deleteTeamStatus: deleteTeamStatus ?? this.deleteTeamStatus,
        addPlayerStatus: addPlayerStatus ?? this.addPlayerStatus,
        updatePlayerStatus: updatePlayerStatus ?? this.updatePlayerStatus,
        deletePlayerStatus: deletePlayerStatus ?? this.deletePlayerStatus,
        teams: teams ?? this.teams,
        players: players ?? this.players,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        listStatus,
        playerListStatus,
        createTeamStatus,
        updateTeamStatus,
        deleteTeamStatus,
        addPlayerStatus,
        updatePlayerStatus,
        deletePlayerStatus,
        teams,
        players,
        errorMessage,
        fieldErrors,
      ];
}

class TeamController extends FamilyNotifier<TeamState, int> {
  @override
  TeamState build(int tournamentId) => const TeamState();

  GetTeamsUseCase get _getTeams => ref.read(getTeamsUseCaseProvider);
  CreateTeamUseCase get _createTeam => ref.read(createTeamUseCaseProvider);
  GetTeamUseCase get _getTeam => ref.read(getTeamUseCaseProvider);
  UpdateTeamUseCase get _updateTeam => ref.read(updateTeamUseCaseProvider);
  DeleteTeamUseCase get _deleteTeam => ref.read(deleteTeamUseCaseProvider);
  GetPlayersUseCase get _getPlayers => ref.read(getPlayersUseCaseProvider);
  AddPlayerUseCase get _addPlayer => ref.read(addPlayerUseCaseProvider);
  GetPlayerUseCase get _getPlayer => ref.read(getPlayerUseCaseProvider);
  UpdatePlayerUseCase get _updatePlayer => ref.read(updatePlayerUseCaseProvider);
  DeletePlayerUseCase get _deletePlayer => ref.read(deletePlayerUseCaseProvider);

  Future<void> fetchTeams() async {
    if (state.listStatus == TeamListStatus.loading) return;
    state = state.copyWith(listStatus: TeamListStatus.loading, clearError: true);
    try {
      final teams = await _getTeams(arg);
      state = state.copyWith(
        listStatus:
            teams.isEmpty ? TeamListStatus.empty : TeamListStatus.success,
        teams: teams,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch teams failed', error: e);
      state = state.copyWith(
          listStatus: TeamListStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch teams error', error: e);
      state = state.copyWith(
          listStatus: TeamListStatus.error,
          errorMessage: 'Failed to load teams.');
    }
  }

  Future<TeamEntity?> fetchTeam(int teamId) async {
    try {
      return await _getTeam(tournamentId: arg, teamId: teamId);
    } on ApiException catch (e) {
      appLogger.e('Fetch team failed', error: e);
      return null;
    } catch (e) {
      appLogger.e('Unexpected fetch team error', error: e);
      return null;
    }
  }

  Future<void> fetchPlayers(int teamId) async {
    if (state.playerListStatus == PlayerListStatus.loading) return;
    state = state.copyWith(
        playerListStatus: PlayerListStatus.loading, clearError: true);
    try {
      final players = await _getPlayers(tournamentId: arg, teamId: teamId);
      state = state.copyWith(
        playerListStatus: players.isEmpty
            ? PlayerListStatus.empty
            : PlayerListStatus.success,
        players: players,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch players failed', error: e);
      state = state.copyWith(
          playerListStatus: PlayerListStatus.error, errorMessage: e.message);
    } catch (e) {
      appLogger.e('Unexpected fetch players error', error: e);
      state = state.copyWith(
          playerListStatus: PlayerListStatus.error,
          errorMessage: 'Failed to load players.');
    }
  }

  Future<PlayerEntity?> fetchPlayer({
    required int teamId,
    required int playerId,
  }) async {
    try {
      return await _getPlayer(
          tournamentId: arg, teamId: teamId, playerId: playerId);
    } on ApiException catch (e) {
      appLogger.e('Fetch player failed', error: e);
      return null;
    } catch (e) {
      appLogger.e('Unexpected fetch player error', error: e);
      return null;
    }
  }

  Future<bool> createTeam(String name) async {
    state = state.copyWith(
        createTeamStatus: TeamActionStatus.loading, clearError: true);
    try {
      final team = await _createTeam(tournamentId: arg, name: name);
      state = state.copyWith(
        createTeamStatus: TeamActionStatus.success,
        teams: [...state.teams, team],
        listStatus: TeamListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create team failed', error: e);
      state = state.copyWith(
        createTeamStatus: TeamActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create team error', error: e);
      state = state.copyWith(
          createTeamStatus: TeamActionStatus.error,
          errorMessage: 'Failed to create team.');
      return false;
    }
  }

  Future<bool> updateTeam({
    required int teamId,
    required String name,
  }) async {
    state = state.copyWith(
        updateTeamStatus: TeamActionStatus.loading, clearError: true);
    try {
      final updated =
          await _updateTeam(tournamentId: arg, teamId: teamId, name: name);
      state = state.copyWith(
        updateTeamStatus: TeamActionStatus.success,
        teams: state.teams.map((t) => t.id == teamId ? updated : t).toList(),
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Update team failed', error: e);
      state = state.copyWith(
        updateTeamStatus: TeamActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected update team error', error: e);
      state = state.copyWith(
          updateTeamStatus: TeamActionStatus.error,
          errorMessage: 'Failed to update team.');
      return false;
    }
  }

  Future<bool> addPlayer({
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    state = state.copyWith(
        addPlayerStatus: TeamActionStatus.loading, clearError: true);
    try {
      final player = await _addPlayer(
        tournamentId: arg,
        teamId: teamId,
        name: name,
        gameUid: gameUid,
        role: role,
        userId: userId,
      );
      state = state.copyWith(
        addPlayerStatus: TeamActionStatus.success,
        players: [...state.players, player],
        teams: state.teams.map((t) {
          if (t.id != teamId) return t;
          return TeamEntity(
            id: t.id,
            name: t.name,
            tournamentId: t.tournamentId,
            playerCount: t.playerCount + 1,
            createdAt: t.createdAt,
          );
        }).toList(),
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Add player failed', error: e);
      state = state.copyWith(
        addPlayerStatus: TeamActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected add player error', error: e);
      state = state.copyWith(
          addPlayerStatus: TeamActionStatus.error,
          errorMessage: 'Failed to add player.');
      return false;
    }
  }

  Future<bool> updatePlayer({
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    state = state.copyWith(
        updatePlayerStatus: TeamActionStatus.loading, clearError: true);
    try {
      final updated = await _updatePlayer(
        tournamentId: arg,
        teamId: teamId,
        playerId: playerId,
        name: name,
        gameUid: gameUid,
        role: role,
        userId: userId,
      );
      state = state.copyWith(
        updatePlayerStatus: TeamActionStatus.success,
        players:
            state.players.map((p) => p.id == playerId ? updated : p).toList(),
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Update player failed', error: e);
      state = state.copyWith(
        updatePlayerStatus: TeamActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected update player error', error: e);
      state = state.copyWith(
          updatePlayerStatus: TeamActionStatus.error,
          errorMessage: 'Failed to update player.');
      return false;
    }
  }

  void resetCreateTeamStatus() => state = state.copyWith(
      createTeamStatus: TeamActionStatus.idle, clearError: true);

  void resetUpdateTeamStatus() => state = state.copyWith(
      updateTeamStatus: TeamActionStatus.idle, clearError: true);

  void resetAddPlayerStatus() => state = state.copyWith(
      addPlayerStatus: TeamActionStatus.idle, clearError: true);

  void resetUpdatePlayerStatus() => state = state.copyWith(
      updatePlayerStatus: TeamActionStatus.idle, clearError: true);

  Future<bool> deleteTeam(int teamId) async {
    if (state.deleteTeamStatus == TeamActionStatus.loading) return false;
    state = state.copyWith(
        deleteTeamStatus: TeamActionStatus.loading, clearError: true);
    try {
      await _deleteTeam(tournamentId: arg, teamId: teamId);
      final updated = state.teams.where((t) => t.id != teamId).toList();
      state = state.copyWith(
        deleteTeamStatus: TeamActionStatus.success,
        teams: updated,
        listStatus:
            updated.isEmpty ? TeamListStatus.empty : TeamListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete team failed', error: e);
      state = state.copyWith(
          deleteTeamStatus: TeamActionStatus.error,
          errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete team error', error: e);
      state = state.copyWith(
          deleteTeamStatus: TeamActionStatus.error,
          errorMessage: 'Failed to delete team.');
      return false;
    }
  }

  Future<bool> deletePlayer({
    required int teamId,
    required int playerId,
  }) async {
    if (state.deletePlayerStatus == TeamActionStatus.loading) return false;
    state = state.copyWith(
        deletePlayerStatus: TeamActionStatus.loading, clearError: true);
    try {
      await _deletePlayer(
          tournamentId: arg, teamId: teamId, playerId: playerId);
      final updated =
          state.players.where((p) => p.id != playerId).toList();
      state = state.copyWith(
        deletePlayerStatus: TeamActionStatus.success,
        players: updated,
        playerListStatus: updated.isEmpty
            ? PlayerListStatus.empty
            : PlayerListStatus.success,
        teams: state.teams.map((t) {
          if (t.id != teamId) return t;
          return TeamEntity(
            id: t.id,
            name: t.name,
            tournamentId: t.tournamentId,
            playerCount: t.playerCount > 0 ? t.playerCount - 1 : 0,
            createdAt: t.createdAt,
          );
        }).toList(),
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete player failed', error: e);
      state = state.copyWith(
          deletePlayerStatus: TeamActionStatus.error,
          errorMessage: e.message);
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete player error', error: e);
      state = state.copyWith(
          deletePlayerStatus: TeamActionStatus.error,
          errorMessage: 'Failed to delete player.');
      return false;
    }
  }
}

final teamControllerProvider =
    NotifierProviderFamily<TeamController, TeamState, int>(
  TeamController.new,
);
