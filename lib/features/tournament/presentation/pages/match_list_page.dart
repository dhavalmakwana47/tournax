import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/match_controller.dart';
import 'match_results_dialog.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
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

  void _showResultsDialog(MatchEntity match) {
    showDialog(
      context: context,
      builder: (ctx) => MatchResultsDialog(
        match: match,
        onSuccess: () {
          ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
        },
      ),
    );
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

    final totalMatches = state.matches.length;
    final liveMatches = state.matches.where((m) => m.status == 'live').length;
    final completedMatches = state.matches.where((m) => m.status == 'completed').length;

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
            const Text(
              'Matches & Fixtures',
              style: TextStyle(
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
        onPressed: () => _showMatchDialog(),
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref
                  .read(matchControllerProvider(widget.group.id).notifier)
                  .loadMatches(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Overview Quick Stats Card
                    _QuickStatsOverview(
                      groupName: widget.group.name,
                      totalMatches: totalMatches,
                      liveMatches: liveMatches,
                      completedMatches: completedMatches,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Scheduled Matches',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => _showMatchDialog(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
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
                              children: [
                                Icon(Icons.add_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Add Match',
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

                    if (state.matches.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.matches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, idx) {
                          final match = state.matches[idx];
                          return _MatchCard(
                            match: match,
                            tournament: widget.tournament,
                            group: widget.group,
                            onEdit: () => _showMatchDialog(match: match),
                            onDelete: () => _deleteMatch(match),
                            onResults: () => _showResultsDialog(match),
                            onManageTeams: () => context.pushNamed(
                              AppRoutes.matchTeamList,
                              extra: MatchTeamListArgs(
                                tournament: widget.tournament,
                                group: widget.group,
                                match: match,
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

  Widget _buildEmptyState() {
    return Container(
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
            size: 56,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Matches Scheduled',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "+ Add Match" to create match fixtures for this group.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showMatchDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add First Match'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsOverview extends StatelessWidget {
  const _QuickStatsOverview({
    required this.groupName,
    required this.totalMatches,
    required this.liveMatches,
    required this.completedMatches,
  });

  final String groupName;
  final int totalMatches;
  final int liveMatches;
  final int completedMatches;

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
            icon: Icons.sports_esports_rounded,
            iconBg: const Color(0xFF6C5CE7),
            value: '$totalMatches',
            label: 'Total Matches',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.sensors_rounded,
            iconBg: Colors.amber,
            value: '$liveMatches',
            label: 'Live',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            iconBg: AppColors.success,
            value: '$completedMatches',
            label: 'Completed',
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
  });

  final IconData icon;
  final Color iconBg;
  final String value;
  final String label;

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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
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

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.tournament,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onResults,
    required this.onManageTeams,
  });

  final MatchEntity match;
  final TournamentEntity tournament;
  final GroupEntity group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResults;
  final VoidCallback onManageTeams;

  @override
  Widget build(BuildContext context) {
    final teamsCount = match.teams.length;
    final statusLower = match.status.toLowerCase();
    final statusColor = switch (statusLower) {
      'completed' => AppColors.success,
      'live' => Colors.amber,
      'cancelled' => AppColors.error,
      _ => AppColors.primary,
    };

    final formattedDate = match.scheduledAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(match.scheduledAt!).toLocal())
        : 'Not scheduled';

    return Container(
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
                  // Header Row: Match Number + Map / Scheduled + Status + Popup Menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
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
                            '#${match.matchNumber}',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.name ?? 'Match ${match.matchNumber}',
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
                                  Icons.map_outlined,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  match.map ?? 'TBD Map',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status & Popup Menu
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
                              match.status.toUpperCase(),
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
                              if (val == 'standings') {
                                context.pushNamed(
                                  AppRoutes.leaderboard,
                                  extra: LeaderboardArgs(
                                    tournament: tournament,
                                    type: LeaderboardType.match,
                                    id: match.id,
                                    name: match.name ?? 'Match ${match.matchNumber}',
                                  ),
                                );
                              }
                              if (val == 'edit') onEdit();
                              if (val == 'delete') onDelete();
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'standings',
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
                                      'Edit Match',
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
                                      'Delete Match',
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

                  // Action Row: Teams (X), Scores / Results, Slot Poster
                  Row(
                    children: [
                      // Teams Button (Navigates to MatchTeamListPage)
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
                                      'Teams ($teamsCount)',
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
                      const SizedBox(width: 8),

                      // Results / Scores Button
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
                              onTap: onResults,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      match.status == 'completed'
                                          ? Icons.emoji_events_rounded
                                          : Icons.scoreboard_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      match.status == 'completed' ? 'Results' : 'Scores',
                                      style: const TextStyle(
                                        color: Colors.white,
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
                      const SizedBox(width: 8),

                      // Poster Generator Icon Action
                      InkWell(
                        onTap: () => context.pushNamed(
                          AppRoutes.posterGenerator,
                          extra: match,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(
                            Icons.photo_filter_rounded,
                            color: AppColors.upcomingStatus,
                            size: 18,
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
    final bool success;

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
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
