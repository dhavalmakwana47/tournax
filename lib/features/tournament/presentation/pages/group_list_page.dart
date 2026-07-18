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
              foregroundColor: AppColors.textPrimary,
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
          title: const Text('Add Team to Group', style: AppTextStyles.titleMedium),
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
                foregroundColor: AppColors.textPrimary,
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
              foregroundColor: AppColors.textPrimary,
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

  InputDecoration _dialogInputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium,
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Groups', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.createGroup,
                extra: GroupArgs(tournament: widget.tournament, roundId: widget.roundId),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Group'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(state),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.groups.length,
            itemBuilder: (_, i) => _GroupCard(
              group: state.groups[i],
              onEdit: () => context.pushNamed(
                AppRoutes.editGroup,
                extra: EditGroupArgs(
                  tournament: widget.tournament,
                  roundId: widget.roundId,
                  groupId: state.groups[i].id,
                ),
              ),
              onDelete: () => _confirmDelete(state.groups[i]),
              onAddTeam: () => _showAddTeamDialog(state.groups[i]),
              onRemoveTeam: (teamId, teamName) =>
                  _removeTeamFromGroup(state.groups[i], teamId, teamName),
              onConfigurePoints: () => context.pushNamed(
                AppRoutes.pointSystem,
                extra: PointSystemArgs(
                  tournament: widget.tournament,
                  groupId: state.groups[i].id,
                ),
              ),
              onManageMatches: () => context.pushNamed(
                AppRoutes.matchList,
                extra: MatchArgs(
                  tournament: widget.tournament,
                  group: state.groups[i],
                ),
              ),
            ),
          ),
        ),
    };
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTeam,
    required this.onRemoveTeam,
    required this.onConfigurePoints,
    required this.onManageMatches,
  });

  final GroupEntity group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTeam;
  final Function(int teamId, String teamName) onRemoveTeam;
  final VoidCallback onConfigurePoints;
  final VoidCallback onManageMatches;

  @override
  Widget build(BuildContext context) {
    final teams = group.teams ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusBadge(status: group.status),
                        Text('Order: ${group.displayOrder}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showMenu(context),
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                tooltip: 'More options',
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teams (${teams.length})',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onAddTeam,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Team', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (teams.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No teams assigned to this group yet.',
                style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teams.length,
              itemBuilder: (context, idx) {
                final team = teams[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.inputFill,
                        child: team.logo != null
                            ? Image.network(team.logo!, errorBuilder: (_, __, ___) => _teamInitial(team.name))
                            : _teamInitial(team.name),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                            ),
                            if (team.seed != null)
                              Text(
                                'Seed: #${team.seed}',
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemoveTeam(team.id, team.name),
                        icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Remove team',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _teamInitial(String name) => Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      );

  void _showMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box!.localToGlobal(box.size.topRight(Offset.zero), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surface,
      items: const [
        PopupMenuItem(value: 'matches', child: Text('Manage Matches')),
        PopupMenuItem(value: 'points', child: Text('Configure Points')),
        PopupMenuItem(value: 'edit', child: Text('Edit Group')),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete Group', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ).then((value) {
      if (value == 'matches') onManageMatches();
      if (value == 'points') onConfigurePoints();
      if (value == 'edit') onEdit();
      if (value == 'delete') onDelete();
    });
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'active' => AppColors.success,
      'completed' => AppColors.primary,
      _ => AppColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.grid_view_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No groups yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add the first group to get started.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Group'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
