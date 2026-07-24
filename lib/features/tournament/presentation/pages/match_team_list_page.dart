import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/match_controller.dart';

class MatchTeamListPage extends ConsumerStatefulWidget {
  const MatchTeamListPage({
    super.key,
    required this.tournament,
    required this.group,
    required this.match,
  });

  final TournamentEntity tournament;
  final GroupEntity group;
  final MatchEntity match;

  @override
  ConsumerState<MatchTeamListPage> createState() => _MatchTeamListPageState();
}

class _MatchTeamListPageState extends ConsumerState<MatchTeamListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
    });
  }

  void _showAddTeamDialog(MatchEntity currentMatch) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTeamToMatchDialog(
        group: widget.group,
        match: currentMatch,
        onSuccess: () {
          ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
        },
      ),
    );
  }

  Future<void> _removeTeam(MatchEntity currentMatch, MatchTeamMemberEntity team) async {
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
          'Are you sure you want to remove "${team.name}" from ${currentMatch.name ?? 'Match ${currentMatch.matchNumber}'}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(matchControllerProvider(widget.group.id).notifier)
          .removeTeamFromMatch(matchId: currentMatch.id, teamId: team.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${team.name}" from match.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchControllerProvider(widget.group.id));
    final currentMatch = state.matches.firstWhere(
      (m) => m.id == widget.match.id,
      orElse: () => widget.match,
    );
    final teams = currentMatch.teams;

    final formattedDate = currentMatch.scheduledAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(currentMatch.scheduledAt!).toLocal())
        : 'Not scheduled';

    final statusLower = currentMatch.status.toLowerCase();
    final statusColor = switch (statusLower) {
      'completed' => AppColors.success,
      'live' => Colors.amber,
      'cancelled' => AppColors.error,
      _ => AppColors.primary,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentMatch.name ?? 'Match ${currentMatch.matchNumber} Teams',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${widget.tournament.name} • ${widget.group.name}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeamDialog(currentMatch),
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Overview Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 0.15),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '#${currentMatch.matchNumber}',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentMatch.name ?? 'Match ${currentMatch.matchNumber}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.map_outlined, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                currentMatch.map ?? 'TBD Map',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        currentMatch.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Match Teams (${teams.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showAddTeamDialog(currentMatch),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              const SizedBox(height: AppSpacing.md),

              // Teams List
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
                        Icons.sports_esports_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Teams in this Match',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Assign group teams to slots for this match.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTeamDialog(currentMatch),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      team.slot != null ? '#${team.slot}' : 'TBD',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
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
                                        if (team.lane != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Lane: ${team.lane}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeTeam(currentMatch, team),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    tooltip: 'Remove Team from Match',
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
      ),
    );
  }
}

class _AddTeamToMatchDialog extends ConsumerStatefulWidget {
  const _AddTeamToMatchDialog({
    required this.group,
    required this.match,
    required this.onSuccess,
  });

  final GroupEntity group;
  final MatchEntity match;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_AddTeamToMatchDialog> createState() => _AddTeamToMatchDialogState();
}

class _AddTeamToMatchDialogState extends ConsumerState<_AddTeamToMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _slotCtrl = TextEditingController();
  final _laneCtrl = TextEditingController();

  int? _selectedTeamId;

  @override
  void dispose() {
    _slotCtrl.dispose();
    _laneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchControllerProvider(widget.group.id));
    final isSaving = state.teamActionStatus == MatchActionStatus.loading;
    final errors = state.fieldErrors;

    final matchTeamIds = widget.match.teams.map((t) => t.id).toSet();
    final availableTeams = widget.group.teams?.where((t) => !matchTeamIds.contains(t.id)).toList() ?? [];

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      title: const Text('Add Team to Match', style: AppTextStyles.titleMedium),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (availableTeams.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'No available teams in the group to add.',
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                DropdownButtonFormField<int>(
                  value: _selectedTeamId,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  dropdownColor: AppColors.surface,
                  decoration: _inputDecoration('Select Team').copyWith(
                    errorText: errors['team_id'],
                  ),
                  items: availableTeams
                      .map((team) => DropdownMenuItem<int>(
                            value: team.id,
                            child: Text(team.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTeamId = v),
                  validator: (v) => v == null ? 'Please select a team' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _slotCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Slot Number (optional)').copyWith(
                    errorText: errors['slot'],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _laneCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Lane/Drop Point (optional)').copyWith(
                    errorText: errors['lane'],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        if (availableTeams.isNotEmpty)
          FilledButton(
            onPressed: isSaving
                ? null
                : () async {
                    if (!_formKey.currentState!.validate() || _selectedTeamId == null) return;
                    final slotStr = _slotCtrl.text.trim();
                    final slot = slotStr.isNotEmpty ? int.parse(slotStr) : null;
                    final lane = _laneCtrl.text.trim().isEmpty ? null : _laneCtrl.text.trim();

                    final success = await ref
                        .read(matchControllerProvider(widget.group.id).notifier)
                        .addTeamToMatch(
                          matchId: widget.match.id,
                          teamId: _selectedTeamId!,
                          slot: slot,
                          lane: lane,
                        );

                    if (success && mounted) {
                      widget.onSuccess();
                      Navigator.of(context).pop();
                    }
                  },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                  )
                : const Text('Add'),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );
}
