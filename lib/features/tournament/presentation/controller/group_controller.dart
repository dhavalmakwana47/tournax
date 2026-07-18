import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../domain/usecases/show_group_usecase.dart';
import '../../domain/usecases/update_group_usecase.dart';
import '../../domain/usecases/delete_group_usecase.dart';
import '../../domain/usecases/add_group_team_usecase.dart';
import '../../domain/usecases/remove_group_team_usecase.dart';

enum GroupListStatus { initial, loading, success, empty, error }
enum GroupActionStatus { idle, loading, success, error }

class GroupState extends Equatable {
  const GroupState({
    this.listStatus = GroupListStatus.initial,
    this.createStatus = GroupActionStatus.idle,
    this.updateStatus = GroupActionStatus.idle,
    this.deleteStatus = GroupActionStatus.idle,
    this.teamActionStatus = GroupActionStatus.idle,
    this.groups = const [],
    this.errorMessage,
    this.fieldErrors = const {},
    this.isWarning = false,
  });

  final GroupListStatus listStatus;
  final GroupActionStatus createStatus;
  final GroupActionStatus updateStatus;
  final GroupActionStatus deleteStatus;
  final GroupActionStatus teamActionStatus;
  final List<GroupEntity> groups;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isWarning;

  GroupState copyWith({
    GroupListStatus? listStatus,
    GroupActionStatus? createStatus,
    GroupActionStatus? updateStatus,
    GroupActionStatus? deleteStatus,
    GroupActionStatus? teamActionStatus,
    List<GroupEntity>? groups,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isWarning,
    bool clearError = false,
  }) =>
      GroupState(
        listStatus: listStatus ?? this.listStatus,
        createStatus: createStatus ?? this.createStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        teamActionStatus: teamActionStatus ?? this.teamActionStatus,
        groups: groups ?? this.groups,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        fieldErrors: clearError ? const {} : fieldErrors ?? this.fieldErrors,
        isWarning: clearError ? false : isWarning ?? this.isWarning,
      );

  @override
  List<Object?> get props => [
        listStatus,
        createStatus,
        updateStatus,
        deleteStatus,
        teamActionStatus,
        groups,
        errorMessage,
        fieldErrors,
        isWarning,
      ];
}

class GroupController extends FamilyNotifier<GroupState, int> {
  @override
  GroupState build(int roundId) => const GroupState();

  GetGroupsUseCase get _getGroups => ref.read(getGroupsUseCaseProvider);
  CreateGroupUseCase get _createGroup => ref.read(createGroupUseCaseProvider);
  ShowGroupUseCase get _showGroup => ref.read(showGroupUseCaseProvider);
  UpdateGroupUseCase get _updateGroup => ref.read(updateGroupUseCaseProvider);
  DeleteGroupUseCase get _deleteGroup => ref.read(deleteGroupUseCaseProvider);
  AddGroupTeamUseCase get _addGroupTeam => ref.read(addGroupTeamUseCaseProvider);
  RemoveGroupTeamUseCase get _removeGroupTeam => ref.read(removeGroupTeamUseCaseProvider);

  Future<void> fetchGroups() async {
    if (state.listStatus == GroupListStatus.loading) return;
    state = state.copyWith(listStatus: GroupListStatus.loading, clearError: true);
    try {
      final groups = await _getGroups(arg);
      final sortedGroups = List<GroupEntity>.from(groups)
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      state = state.copyWith(
        listStatus: sortedGroups.isEmpty ? GroupListStatus.empty : GroupListStatus.success,
        groups: sortedGroups,
      );
    } on ApiException catch (e) {
      appLogger.e('Fetch groups failed', error: e);
      state = state.copyWith(
        listStatus: GroupListStatus.error,
        errorMessage: e.message,
        isWarning: e.isWarning,
      );
    } catch (e) {
      appLogger.e('Unexpected fetch groups error', error: e);
      state = state.copyWith(
        listStatus: GroupListStatus.error,
        errorMessage: 'Failed to load groups.',
      );
    }
  }

  Future<bool> createGroup({
    required String name,
    int? displayOrder,
    String? status,
  }) async {
    state = state.copyWith(createStatus: GroupActionStatus.loading, clearError: true);
    try {
      final group = await _createGroup(
        roundId: arg,
        name: name,
        displayOrder: displayOrder,
        status: status,
      );
      final sortedGroups = [...state.groups, group]
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      state = state.copyWith(
        createStatus: GroupActionStatus.success,
        groups: sortedGroups,
        listStatus: GroupListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Create group failed', error: e);
      state = state.copyWith(
        createStatus: GroupActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
        isWarning: e.isWarning,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected create group error', error: e);
      state = state.copyWith(
        createStatus: GroupActionStatus.error,
        errorMessage: 'Failed to create group.',
      );
      return false;
    }
  }

  Future<GroupEntity?> showGroup(int groupId) async {
    try {
      return await _showGroup(groupId);
    } on ApiException catch (e) {
      appLogger.e('Show group failed', error: e);
      return null;
    } catch (e) {
      appLogger.e('Unexpected show group error', error: e);
      return null;
    }
  }

  Future<bool> updateGroup({
    required int groupId,
    String? name,
    int? displayOrder,
    String? status,
  }) async {
    state = state.copyWith(updateStatus: GroupActionStatus.loading, clearError: true);
    try {
      await _updateGroup(
        groupId: groupId,
        name: name,
        displayOrder: displayOrder,
        status: status,
      );
      final updated = state.groups.map((g) {
        if (g.id != groupId) return g;
        return GroupEntity(
          id: g.id,
          roundId: g.roundId,
          name: name ?? g.name,
          displayOrder: displayOrder ?? g.displayOrder,
          status: status ?? g.status,
          createdAt: g.createdAt,
          teams: g.teams,
        );
      }).toList();
      updated.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      state = state.copyWith(
        updateStatus: GroupActionStatus.success,
        groups: updated,
        listStatus: GroupListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Update group failed', error: e);
      state = state.copyWith(
        updateStatus: GroupActionStatus.error,
        errorMessage: e.fieldErrors.isEmpty ? e.message : null,
        fieldErrors: e.fieldErrors,
        isWarning: e.isWarning,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected update group error', error: e);
      state = state.copyWith(
        updateStatus: GroupActionStatus.error,
        errorMessage: 'Failed to update group.',
      );
      return false;
    }
  }

  Future<bool> deleteGroup(int groupId) async {
    state = state.copyWith(deleteStatus: GroupActionStatus.loading, clearError: true);
    try {
      await _deleteGroup(groupId);
      final remaining = state.groups.where((g) => g.id != groupId).toList();
      state = state.copyWith(
        deleteStatus: GroupActionStatus.success,
        groups: remaining,
        listStatus: remaining.isEmpty ? GroupListStatus.empty : GroupListStatus.success,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Delete group failed', error: e);
      state = state.copyWith(
        deleteStatus: GroupActionStatus.error,
        errorMessage: e.message,
        isWarning: e.isWarning,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected delete group error', error: e);
      state = state.copyWith(
        deleteStatus: GroupActionStatus.error,
        errorMessage: 'Failed to delete group.',
      );
      return false;
    }
  }

  Future<bool> addGroupTeam({
    required int groupId,
    required int teamId,
    int? seed,
  }) async {
    state = state.copyWith(teamActionStatus: GroupActionStatus.loading, clearError: true);
    try {
      final updatedGroup = await _addGroupTeam(
        groupId: groupId,
        teamId: teamId,
        seed: seed,
      );
      final updatedList = state.groups.map((g) {
        if (g.id != groupId) return g;
        return updatedGroup;
      }).toList();
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.success,
        groups: updatedList,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Add team to group failed', error: e);
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.error,
        errorMessage: e.message,
        isWarning: e.isWarning,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected add team to group error', error: e);
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.error,
        errorMessage: 'Failed to add team to group.',
      );
      return false;
    }
  }

  Future<bool> removeGroupTeam({
    required int groupId,
    required int teamId,
  }) async {
    state = state.copyWith(teamActionStatus: GroupActionStatus.loading, clearError: true);
    try {
      final updatedGroup = await _removeGroupTeam(
        groupId: groupId,
        teamId: teamId,
      );
      final updatedList = state.groups.map((g) {
        if (g.id != groupId) return g;
        return updatedGroup;
      }).toList();
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.success,
        groups: updatedList,
      );
      return true;
    } on ApiException catch (e) {
      appLogger.e('Remove team from group failed', error: e);
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.error,
        errorMessage: e.message,
        isWarning: e.isWarning,
      );
      return false;
    } catch (e) {
      appLogger.e('Unexpected remove team from group error', error: e);
      state = state.copyWith(
        teamActionStatus: GroupActionStatus.error,
        errorMessage: 'Failed to remove team from group.',
      );
      return false;
    }
  }

  void resetCreateStatus() =>
      state = state.copyWith(createStatus: GroupActionStatus.idle, clearError: true);

  void resetUpdateStatus() =>
      state = state.copyWith(updateStatus: GroupActionStatus.idle, clearError: true);

  void resetDeleteStatus() =>
      state = state.copyWith(deleteStatus: GroupActionStatus.idle, clearError: true);

  void resetTeamActionStatus() =>
      state = state.copyWith(teamActionStatus: GroupActionStatus.idle, clearError: true);
}

final groupControllerProvider =
    NotifierProviderFamily<GroupController, GroupState, int>(
  GroupController.new,
);
