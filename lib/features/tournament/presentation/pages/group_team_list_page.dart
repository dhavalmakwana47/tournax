import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/group_controller.dart';
import '../controller/team_controller.dart';

class GroupTeamListPage extends ConsumerStatefulWidget {
  const GroupTeamListPage({
    super.key,
    required this.tournament,
    required this.roundId,
    required this.group,
  });

  final TournamentEntity tournament;
  final int roundId;
  final GroupEntity group;

  @override
  ConsumerState<GroupTeamListPage> createState() => _GroupTeamListPageState();
}

class _GroupTeamListPageState extends ConsumerState<GroupTeamListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamControllerProvider(widget.tournament.id).notifier).fetchTeams();
      ref.read(groupControllerProvider(widget.roundId).notifier).fetchGroups();
    });
  }

  Future<void> _showAddTeamDialog() async {
    final teamState = ref.read(teamControllerProvider(widget.tournament.id));
    final groupState = ref.read(groupControllerProvider(widget.roundId));
    final currentGroup = groupState.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );
    final assignedTeamIds = (currentGroup.teams ?? []).map((t) => t.id).toSet();

    final availableTeams = teamState.teams
        .where((t) => !assignedTeamIds.contains(t.id))
        .toList();

    if (availableTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All tournament teams are already assigned to this group or no teams exist.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    int selectedTeamId = availableTeams.first.id;
    final seedController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Text('Add Team to Group', style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Team', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: selectedTeamId,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _dialogInputDecoration(),
                items: availableTeams
                    .map((t) => DropdownMenuItem<int>(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedTeamId = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Seed Number (Optional)', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
              TextField(
                controller: seedController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _dialogInputDecoration(hint: 'e.g. 1'),
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
    );

    if (result == null || !mounted) return;

    final tId = result['teamId'] as int;
    final seed = result['seed'] as int?;

    final success = await ref
        .read(groupControllerProvider(widget.roundId).notifier)
        .addGroupTeam(groupId: widget.group.id, teamId: tId, seed: seed);

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
  }

  Future<void> _removeTeam(int teamId, String teamName) async {
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
          'Are you sure you want to remove "$teamName" from "${widget.group.name}"?',
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
        .removeGroupTeam(groupId: widget.group.id, teamId: teamId);

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
    final groupState = ref.watch(groupControllerProvider(widget.roundId));
    final currentGroup = groupState.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );
    final teams = currentGroup.teams ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
            Text(
              '${currentGroup.name} - Teams',
              style: const TextStyle(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTeamDialog,
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Team',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            Container(
              padding: const EdgeInsets.all(16),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentGroup.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Teams Assigned: ${teams.length}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _showAddTeamDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add Team',
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
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section Header
            const Text(
              'Group Teams List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (teams.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Teams Assigned',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Click "+ Add Team" to assign registered tournament teams to this group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddTeamDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add First Team'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teams.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
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
                            child: Container(color: AppColors.primary),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.surface,
                                  child: team.logo != null
                                      ? Image.network(
                                          team.logo!,
                                          errorBuilder: (_, __, ___) => _teamInitial(team.name),
                                        )
                                      : _teamInitial(team.name),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        team.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (team.seed != null)
                                        Text(
                                          'Seed: #${team.seed}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeTeam(team.id, team.name),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  tooltip: 'Remove Team',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _teamInitial(String name) => Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
}
