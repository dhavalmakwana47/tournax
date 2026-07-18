import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/match_controller.dart';

class MatchListPage extends ConsumerStatefulWidget {
  const MatchListPage({
    super.key,
    required this.tournament,
    required this.group,
  });

  final TournamentEntity tournament;
  final GroupEntity group;

  @override
  ConsumerState<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends ConsumerState<MatchListPage> {
  // Keeps track of which match card is expanded
  final Set<int> _expandedMatchIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
    });
  }

  void _toggleExpand(int matchId) {
    setState(() {
      if (_expandedMatchIds.contains(matchId)) {
        _expandedMatchIds.remove(matchId);
      } else {
        _expandedMatchIds.add(matchId);
      }
    });
  }

  void _showMatchDialog({MatchEntity? match}) {
    showDialog(
      context: context,
      builder: (ctx) => _MatchFormDialog(
        groupId: widget.group.id,
        match: match,
        onSuccess: () {
          ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
        },
      ),
    );
  }

  Future<void> _deleteMatch(MatchEntity match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Match', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete Match ${match.matchNumber} (${match.map ?? 'No map'})?',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(matchControllerProvider(widget.group.id).notifier)
          .deleteMatch(match.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showAddTeamDialog(MatchEntity match) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTeamToMatchDialog(
        group: widget.group,
        match: match,
        onSuccess: () {
          ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
        },
      ),
    );
  }

  Future<void> _removeTeamFromMatch(MatchEntity match, MatchTeamMemberEntity team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Team', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to remove ${team.name} from Match ${match.matchNumber}?',
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
          .removeTeamFromMatch(matchId: match.id, teamId: team.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${team.name} from match.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchControllerProvider(widget.group.id));
    final isLoading = state.status == MatchActionStatus.loading;

    ref.listen(matchControllerProvider(widget.group.id), (_, next) {
      if (next.errorMessage != null && next.status == MatchActionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

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
            Text('Manage Matches', style: AppTextStyles.titleMedium),
            Text('${widget.tournament.name} - ${widget.group.name}', style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Add Match',
            onPressed: () => _showMatchDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.matches.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: state.matches.length,
                  itemBuilder: (context, idx) {
                    final match = state.matches[idx];
                    final isExpanded = _expandedMatchIds.contains(match.id);
                    return _buildMatchCard(match, isExpanded);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_esports_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          const Text('No matches scheduled yet', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          const Text('Tap "+" at the top to schedule a new match.', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchEntity match, bool isExpanded) {
    Color statusColor;
    switch (match.status) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'live':
        statusColor = Colors.amber;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.primary;
    }

    final formattedDate = match.scheduledAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(match.scheduledAt!).toLocal())
        : 'Not scheduled';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _toggleExpand(match.id),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#${match.matchNumber}',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.name ?? 'Match ${match.matchNumber}',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.map_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(match.map ?? 'TBD', style: AppTextStyles.bodySmall),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(formattedDate, style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      match.status.toUpperCase(),
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: AppColors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Teams (${match.teams.length})',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                            onPressed: () => _showMatchDialog(match: match),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            onPressed: () => _deleteMatch(match),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: () => _showAddTeamDialog(match),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Team'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (match.teams.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'No teams configured for this match.',
                        style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: match.teams.map((team) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final double cardWidth;
                        if (screenWidth < 400) {
                          cardWidth = screenWidth - 66;
                        } else {
                          cardWidth = (screenWidth - 66 - AppSpacing.sm) / 2;
                        }

                        return Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  team.slot != null ? 'Slot ${team.slot}' : 'TBD',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name,
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (team.lane != null && team.lane!.isNotEmpty)
                                      Text(
                                        'Lane: ${team.lane}',
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                onPressed: () => _removeTeamFromMatch(match, team),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchFormDialog extends ConsumerStatefulWidget {
  const _MatchFormDialog({
    required this.groupId,
    this.match,
    required this.onSuccess,
  });

  final int groupId;
  final MatchEntity? match;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_MatchFormDialog> createState() => _MatchFormDialogState();
}

class _MatchFormDialogState extends ConsumerState<_MatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _mapCtrl = TextEditingController();
  final _scheduledAtCtrl = TextEditingController();

  String _status = 'scheduled';
  DateTime? _scheduledDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      _numberCtrl.text = widget.match!.matchNumber.toString();
      _nameCtrl.text = widget.match!.name ?? '';
      _mapCtrl.text = widget.match!.map ?? '';
      _status = widget.match!.status;
      if (widget.match!.scheduledAt != null) {
        _scheduledDateTime = DateTime.parse(widget.match!.scheduledAt!).toLocal();
        _scheduledAtCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduledDateTime!);
      }
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _mapCtrl.dispose();
    _scheduledAtCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    setState(() {
      _scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _scheduledAtCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(_scheduledDateTime!);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final number = int.parse(_numberCtrl.text.trim());
    final name = _nameCtrl.text.trim();
    final map = _mapCtrl.text.trim();
    final scheduledStr = _scheduledDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_scheduledDateTime!)
        : null;

    final notifier = ref.read(matchControllerProvider(widget.groupId).notifier);
    final success;

    if (widget.match != null) {
      success = await notifier.updateMatch(
        matchId: widget.match!.id,
        matchNumber: number,
        name: name.isEmpty ? null : name,
        map: map.isEmpty ? null : map,
        scheduledAt: scheduledStr,
        status: _status,
      );
    } else {
      success = await notifier.createMatch(
        matchNumber: number,
        name: name.isEmpty ? null : name,
        map: map.isEmpty ? null : map,
        scheduledAt: scheduledStr,
        status: _status,
      );
    }

    if (success && mounted) {
      widget.onSuccess();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchControllerProvider(widget.groupId));
    final isSaving = state.saveStatus == MatchActionStatus.loading;
    final errors = state.fieldErrors;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.match != null ? 'Edit Match' : 'Add Match', style: AppTextStyles.titleMedium),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _numberCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Match Number').copyWith(errorText: errors['match_number']),
                validator: (v) => Validators.required(v),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Match Name (optional)').copyWith(errorText: errors['name']),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _mapCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Map (e.g. Erangel, Miramar)').copyWith(errorText: errors['map']),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _scheduledAtCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                readOnly: true,
                onTap: _selectDateTime,
                decoration: _inputDecoration('Scheduled At (optional)').copyWith(
                  errorText: errors['scheduled_at'],
                  suffixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _status,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                dropdownColor: AppColors.surface,
                decoration: _inputDecoration('Status'),
                items: const [
                  DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                  DropdownMenuItem(value: 'live', child: Text('Live')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _status = v);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: isSaving ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                )
              : const Text('Save'),
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

    // Filter group teams to exclude those already added to the match
    final matchTeamIds = widget.match.teams.map((t) => t.id).toSet();
    final availableTeams = widget.group.teams?.where((t) => !matchTeamIds.contains(t.id)).toList() ?? [];

    return AlertDialog(
      backgroundColor: AppColors.surface,
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
                  decoration: _inputDecoration('Select Team'),
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
                  decoration: _inputDecoration('Slot Number (optional)'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _laneCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Lane/Drop Point (optional)'),
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
