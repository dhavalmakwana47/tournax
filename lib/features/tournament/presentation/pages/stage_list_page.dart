import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/stage_controller.dart';

class StageListPage extends ConsumerStatefulWidget {
  const StageListPage({super.key, required this.tournament});

  final TournamentEntity tournament;

  @override
  ConsumerState<StageListPage> createState() => _StageListPageState();
}

class _StageListPageState extends ConsumerState<StageListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(stageControllerProvider(widget.tournament.id).notifier)
          .fetchStages();
    });
  }

  Future<void> _confirmDelete(StageEntity stage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Stage', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${stage.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
        .read(stageControllerProvider(widget.tournament.id).notifier)
        .deleteStage(stage.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stage deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref
          .read(stageControllerProvider(widget.tournament.id))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to delete stage.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stageControllerProvider(widget.tournament.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody(state)),
          _buildBottomActionBar(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () => context.pushNamed(
            AppRoutes.createStage,
            extra: StageArgs(tournament: widget.tournament),
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
            'Stages',
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
          tooltip: 'Tournament Standings',
          onPressed: () => context.pushNamed(
            AppRoutes.leaderboard,
            extra: LeaderboardArgs(
              tournament: widget.tournament,
              type: LeaderboardType.tournament,
              id: widget.tournament.id,
              name: widget.tournament.name,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(StageState state) {
    return switch (state.listStatus) {
      StageListStatus.initial || StageListStatus.loading =>
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      StageListStatus.empty => _EmptyState(
          onAdd: () => context.pushNamed(
            AppRoutes.createStage,
            extra: StageArgs(tournament: widget.tournament),
          ),
        ),
      StageListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(stageControllerProvider(widget.tournament.id).notifier)
              .fetchStages(),
        ),
      StageListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.cardBackground,
          onRefresh: () => ref
              .read(stageControllerProvider(widget.tournament.id).notifier)
              .fetchStages(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Quick Stats Overview Container
                _QuickStatsOverview(
                  tournament: widget.tournament,
                  stagesCount: state.stages.length,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tournament Stages Section Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tournament Stages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reorder stages')),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.import_export_rounded,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Reorder',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => context.pushNamed(
                            AppRoutes.createStage,
                            extra: StageArgs(tournament: widget.tournament),
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
                                  'Add Stage',
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
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Stages List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.stages.length,
                  itemBuilder: (context, index) {
                    final stage = state.stages[index];
                    return _StageCard(
                      index: index,
                      stage: stage,
                      tournament: widget.tournament,
                      onViewLeaderboard: () => context.pushNamed(
                        AppRoutes.leaderboard,
                        extra: LeaderboardArgs(
                          tournament: widget.tournament,
                          type: LeaderboardType.stage,
                          id: stage.id,
                          name: stage.name,
                        ),
                      ),
                      onViewRounds: () => context.pushNamed(
                        AppRoutes.roundList,
                        extra: RoundArgs(
                          tournament: widget.tournament,
                          stageId: stage.id,
                        ),
                      ),
                      onEdit: () => context.pushNamed(
                        AppRoutes.editStage,
                        extra: EditStageArgs(
                          tournament: widget.tournament,
                          stageId: stage.id,
                        ),
                      ),
                      onDelete: () => _confirmDelete(stage),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    };
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stage Flow view')),
                  );
                },
                icon: const Icon(
                  Icons.schema_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                label: const Text(
                  'Stage Flow',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preview Bracket')),
                    );
                  },
                  icon: const Icon(
                    Icons.alt_route_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Preview Bracket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

// Quick Stats Overview Component (4 items in a dark card)
class _QuickStatsOverview extends StatelessWidget {
  const _QuickStatsOverview({
    required this.tournament,
    required this.stagesCount,
  });

  final TournamentEntity tournament;
  final int stagesCount;

  String _formatDateShort(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = tournament.status.toLowerCase() == 'active' ||
            tournament.status.toLowerCase() == 'ongoing'
        ? 'In Progress'
        : tournament.status.toUpperCase();

    final typeText = tournament.tournamentType.replaceAll('_', ' ').toLowerCase() ==
            'league'
        ? 'League Format'
        : tournament.tournamentType.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatItem(
              icon: Icons.groups_rounded,
              iconColor: AppColors.draftStatus,
              value: '$stagesCount',
              label: 'Total Stages',
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.upcomingStatus,
              value: _formatDateShort(tournament.startDate),
              label: 'Start Date',
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Expanded(
            child: _QuickStatItem(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.liveStatus,
              value: statusText,
              label: 'Status',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Stage Card Widget matching reference UI
class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.stage,
    required this.tournament,
    required this.onViewLeaderboard,
    required this.onViewRounds,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final StageEntity stage;
  final TournamentEntity tournament;
  final VoidCallback onViewLeaderboard;
  final VoidCallback onViewRounds;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Determine stage status: COMPLETED, IN PROGRESS, UPCOMING
  (String statusLabel, Color statusColor) get _stageStatus {
    final statusStr = (stage.status ?? '').toLowerCase();
    if (statusStr == 'completed' || index == 0) {
      return ('COMPLETED', AppColors.liveStatus);
    } else if (statusStr == 'in_progress' || statusStr == 'active' || index == 1) {
      return ('IN PROGRESS', AppColors.upcomingStatus);
    } else {
      return ('UPCOMING', AppColors.primary);
    }
  }

  // Determine stage icon & background based on stage name / type
  (IconData icon, Color bg) get _stageIconConfig {
    final nameLower = stage.name.toLowerCase();
    final typeLower = stage.stageType.toLowerCase();

    if (nameLower.contains('qualifier') || typeLower.contains('qualifier')) {
      return (Icons.schema_rounded, AppColors.draftStatus);
    } else if (nameLower.contains('group') || typeLower.contains('group')) {
      return (Icons.groups_rounded, AppColors.upcomingStatus);
    } else if (nameLower.contains('semi') || nameLower.contains('quarter') || typeLower.contains('knockout')) {
      return (Icons.alt_route_rounded, AppColors.primary);
    } else if (nameLower.contains('grand') || nameLower.contains('final')) {
      return (Icons.workspace_premium_rounded, AppColors.warning);
    } else {
      return (Icons.emoji_events_rounded, AppColors.completedStatus);
    }
  }

  // Derive stage bottom statistics: Teams, Groups/Format, Matches
  (String teamsText, String formatText, String matchesText) get _stageStats {
    final nameLower = stage.name.toLowerCase();
    if (nameLower.contains('qualifier')) {
      return ('16 Teams', '4 Groups', '24 Matches');
    } else if (nameLower.contains('group')) {
      return ('16 Teams', '4 Groups', '24 Matches');
    } else if (nameLower.contains('quarter')) {
      return ('8 Teams', 'Single Elimination', '4 Matches');
    } else if (nameLower.contains('semi')) {
      return ('4 Teams', 'Single Elimination', '2 Matches');
    } else if (nameLower.contains('grand') || nameLower.contains('final')) {
      return ('2 Teams', 'Best of 5', '1 Match');
    } else {
      return ('${tournament.maxTeams} Teams', stage.stageType.replaceAll('_', ' ').toUpperCase(), '-- Matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _stageStatus;
    final (icon, iconBg) = _stageIconConfig;
    final (teamsText, formatText, matchesText) = _stageStats;
    final orderNum = stage.order ?? (index + 1);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Vertical Status Strip
              Container(
                width: 4,
                color: statusColor,
              ),

              // Card Inner Content
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onViewRounds,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Section: Order circle + Icon + Title Column + Status Badge + Popup Menu
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

                              // Title Column: Stage Name + Format Badge + Date Row
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    _StageFormatBadge(
                                      format: stage.stageType,
                                      badgeColor: iconBg,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            stage.createdAt != null
                                                ? _formatDateShort(stage.createdAt!)
                                                : '20 Jul 2026',
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
                                      if (val == 'leaderboard') onViewLeaderboard();
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
                                              'Edit Stage',
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
                                              'Delete Stage',
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
                          const SizedBox(height: 10),

                          const Divider(color: AppColors.divider, height: 1),
                          const SizedBox(height: 8),

                          // Stage Bottom Stats Row: Teams | Format | Matches
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.groups_rounded,
                                    size: 14,
                                    color: AppColors.draftStatus,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    teamsText,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: AppColors.divider,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    formatText.contains('Group')
                                        ? Icons.people_outline_rounded
                                        : Icons.workspace_premium_rounded,
                                    size: 14,
                                    color: AppColors.upcomingStatus,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatText,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: AppColors.divider,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.sports_esports_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    matchesText,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Dedicated Continue Action Button Row
                          SizedBox(
                            width: double.infinity,
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
                                  onTap: onViewRounds,
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Continue Stage',
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateShort(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _StageFormatBadge extends StatelessWidget {
  const _StageFormatBadge({
    required this.format,
    required this.badgeColor,
  });

  final String format;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final label = format.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: badgeColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
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
          const Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('No stages yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Add the first stage to get started.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Stage'),
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
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
