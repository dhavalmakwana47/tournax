import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/group_controller.dart';
import '../controller/team_controller.dart';

class GroupListPage extends ConsumerStatefulWidget {
  const GroupListPage({
    super.key,
    required this.tournament,
    required this.roundId,
  });

  final TournamentEntity tournament;
  final int roundId;

  @override
  ConsumerState<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends ConsumerState<GroupListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupControllerProvider(widget.roundId).notifier).fetchGroups();
      ref.read(teamControllerProvider(widget.tournament.id).notifier).fetchTeams();
    });
  }

  Future<void> _confirmDelete(GroupEntity group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Delete Group', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(groupControllerProvider(widget.roundId).notifier)
        .deleteGroup(group.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref.read(groupControllerProvider(widget.roundId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to delete group.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showAddTeamDialog(GroupEntity group) async {
    final teamsState = ref.read(teamControllerProvider(widget.tournament.id));
    if (teamsState.listStatus != TeamListStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teams are still loading. Please try again in a moment.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final allTeams = teamsState.teams;
    final currentTeamIds = group.teams?.map((t) => t.id).toSet() ?? {};
    final availableTeams = allTeams.where((t) => !currentTeamIds.contains(t.id)).toList();

    if (availableTeams.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Text('Add Team to Group', style: AppTextStyles.titleMedium),
          content: const Text(
            'All registered tournament teams are already in this group.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      return;
    }

    int? selectedTeamId = availableTeams.first.id;
    final seedController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Text(
            'Add Team to Group',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Team', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                value: selectedTeamId,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _dialogInputDecoration(),
                items: availableTeams
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setStateDialog(() => selectedTeamId = v);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Seed (optional)', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: seedController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dialogInputDecoration(hint: 'e.g. 1'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop({
                  'teamId': selectedTeamId,
                  'seed': int.tryParse(seedController.text),
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    ).then((result) async {
      if (result == null || !mounted) return;

      final tId = result['teamId'] as int;
      final seed = result['seed'] as int?;

      final success = await ref
          .read(groupControllerProvider(widget.roundId).notifier)
          .addGroupTeam(groupId: group.id, teamId: tId, seed: seed);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team added to group successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final msg = ref.read(groupControllerProvider(widget.roundId)).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg ?? 'Failed to add team to group.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  Future<void> _removeTeamFromGroup(GroupEntity group, int teamId, String teamName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Remove Team', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to remove "$teamName" from "${group.name}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(groupControllerProvider(widget.roundId).notifier)
        .removeGroupTeam(groupId: group.id, teamId: teamId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team removed from group successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref.read(groupControllerProvider(widget.roundId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to remove team from group.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showManageTeamsBottomSheet(GroupEntity group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManageGroupTeamsBottomSheet(
        group: group,
        onAddTeam: () {
          Navigator.pop(ctx);
          _showAddTeamDialog(group);
        },
        onRemoveTeam: (teamId, teamName) {
          Navigator.pop(ctx);
          _removeTeamFromGroup(group, teamId, teamName);
        },
      ),
    );
  }

  InputDecoration _dialogInputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 13),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupControllerProvider(widget.roundId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          AppRoutes.createGroup,
          extra: GroupArgs(tournament: widget.tournament, roundId: widget.roundId),
        ),
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.textPrimary,
          size: 30,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            widget.tournament.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          tooltip: 'Round Standings',
          onPressed: () => context.pushNamed(
            AppRoutes.leaderboard,
            extra: LeaderboardArgs(
              tournament: widget.tournament,
              type: LeaderboardType.round,
              id: widget.roundId,
              name: 'Round Standings',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(GroupState state) {
    return switch (state.listStatus) {
      GroupListStatus.initial || GroupListStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      GroupListStatus.empty => _EmptyState(
          onAdd: () => context.pushNamed(
            AppRoutes.createGroup,
            extra: GroupArgs(tournament: widget.tournament, roundId: widget.roundId),
          ),
        ),
      GroupListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(groupControllerProvider(widget.roundId).notifier)
              .fetchGroups(),
        ),
      GroupListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(groupControllerProvider(widget.roundId).notifier)
              .fetchGroups(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Quick Stats Overview Container
                _QuickStatsOverview(
                  tournament: widget.tournament,
                  groupsCount: state.groups.length,
                  totalTeams: state.groups.fold(0, (acc, g) => acc + (g.teams?.length ?? 0)),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tournament Groups Section Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tournament Groups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pushNamed(
                        AppRoutes.createGroup,
                        extra: GroupArgs(
                          tournament: widget.tournament,
                          roundId: widget.roundId,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFFF8C00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Add Group',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Groups List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return _GroupCard(
                      index: index,
                      group: group,
                      onEdit: () => context.pushNamed(
                        AppRoutes.editGroup,
                        extra: EditGroupArgs(
                          tournament: widget.tournament,
                          roundId: widget.roundId,
                          groupId: group.id,
                        ),
                      ),
                      onDelete: () => _confirmDelete(group),
                      onManageTeams: () => context.pushNamed(
                        AppRoutes.groupTeamList,
                        extra: GroupTeamListArgs(
                          tournament: widget.tournament,
                          roundId: widget.roundId,
                          group: group,
                        ),
                      ),
                      onShowLeaderboard: () => context.pushNamed(
                        AppRoutes.leaderboard,
                        extra: LeaderboardArgs(
                          tournament: widget.tournament,
                          type: LeaderboardType.group,
                          id: group.id,
                          name: group.name,
                        ),
                      ),
                      onConfigurePoints: () => context.pushNamed(
                        AppRoutes.pointSystem,
                        extra: PointSystemArgs(
                          tournament: widget.tournament,
                          groupId: group.id,
                        ),
                      ),
                      onManageMatches: () => context.pushNamed(
                        AppRoutes.matchList,
                        extra: MatchArgs(
                          tournament: widget.tournament,
                          group: group,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    };
  }
}

class _QuickStatsOverview extends StatelessWidget {
  const _QuickStatsOverview({
    required this.tournament,
    required this.groupsCount,
    required this.totalTeams,
  });

  final TournamentEntity tournament;
  final int groupsCount;
  final int totalTeams;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.grid_view_rounded,
            iconBg: const Color(0xFF6C5CE7),
            value: '$groupsCount',
            label: 'Total Groups',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.groups_rounded,
            iconBg: const Color(0xFF00CEC9),
            value: '$totalTeams',
            label: 'Total Teams',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.flag_rounded,
            iconBg: AppColors.upcomingStatus,
            value: tournament.status.toUpperCase(),
            label: 'Status',
            isStatus: true,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
    this.isStatus = false,
  });

  final IconData icon;
  final Color iconBg;
  final String value;
  final String label;
  final bool isStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconBg, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isStatus ? AppColors.upcomingStatus : AppColors.textPrimary,
            fontSize: isStatus ? 13 : 15,
            fontWeight: FontWeight.w800,
            letterSpacing: isStatus ? 0.5 : 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.index,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onManageTeams,
    required this.onShowLeaderboard,
    required this.onConfigurePoints,
    required this.onManageMatches,
  });

  final int index;
  final GroupEntity group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageTeams;
  final VoidCallback onShowLeaderboard;
  final VoidCallback onConfigurePoints;
  final VoidCallback onManageMatches;

  @override
  Widget build(BuildContext context) {
    final teams = group.teams ?? [];
    final orderNum = group.displayOrder > 0 ? group.displayOrder : index + 1;
    final statusLower = group.status.toLowerCase();
    final statusColor = switch (statusLower) {
      'active' || 'in_progress' => AppColors.primary,
      'completed' => AppColors.upcomingStatus,
      _ => AppColors.draftStatus,
    };
    final statusLabel = group.status.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(color: statusColor),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Order Circle + Name + Status Badge + Popup Menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Order Number
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$orderNum',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title Column: Group Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.groups_rounded,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${teams.length} Teams Assigned',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right Status Badge & Popup Menu Column
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              color: AppColors.surface,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColors.cardBorder,
                                ),
                              ),
                              onSelected: (val) {
                                if (val == 'leaderboard') onShowLeaderboard();
                                if (val == 'points') onConfigurePoints();
                                if (val == 'edit') onEdit();
                                if (val == 'delete') onDelete();
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'leaderboard',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events_outlined,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'View Standings',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'points',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.settings_outlined,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Configure Points',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit Group',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(height: 1),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: AppColors.error,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete Group',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 10),

                    // Action Buttons Row: Manage Teams & Manage Matches
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onManageTeams,
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.people_alt_rounded,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Teams (${teams.length})',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFFFF8C00)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onManageMatches,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Matches',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageGroupTeamsBottomSheet extends StatelessWidget {
  const _ManageGroupTeamsBottomSheet({
    required this.group,
    required this.onAddTeam,
    required this.onRemoveTeam,
  });

  final GroupEntity group;
  final VoidCallback onAddTeam;
  final Function(int teamId, String teamName) onRemoveTeam;

  Widget _teamInitial(String name) => Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final teams = group.teams ?? [];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1.5),
          left: BorderSide(color: AppColors.cardBorder, width: 1),
          right: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Handle Indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row: Group Name & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group.name} - Assigned Teams',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total ${teams.length} teams assigned to this group',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),

          // Scrollable Assigned Teams List
          Flexible(
            child: teams.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.groups_outlined,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No teams assigned to this group yet.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: teams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final team = teams[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.surface,
                              child: team.logo != null
                                  ? Image.network(
                                      team.logo!,
                                      errorBuilder: (_, __, ___) => _teamInitial(team.name),
                                    )
                                  : _teamInitial(team.name),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (team.seed != null)
                                    Text(
                                      'Seed: #${team.seed}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => onRemoveTeam(team.id, team.name),
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              tooltip: 'Remove Team',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // Bottom Action Button: Add Team to Group
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8C00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddTeam,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Add Team to Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Groups Added Yet',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create groups to organize teams and schedule matches.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8C00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Add First Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
