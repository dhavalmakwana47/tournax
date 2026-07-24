import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/round_controller.dart';

class RoundListPage extends ConsumerStatefulWidget {
  const RoundListPage({
    super.key,
    required this.tournament,
    required this.stageId,
  });

  final TournamentEntity tournament;
  final int stageId;

  @override
  ConsumerState<RoundListPage> createState() => _RoundListPageState();
}

class _RoundListPageState extends ConsumerState<RoundListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roundControllerProvider(widget.stageId).notifier).fetchRounds();
    });
  }

  Future<void> _confirmDelete(RoundEntity round) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Delete Round', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${round.name}"? This action cannot be undone.',
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
        .read(roundControllerProvider(widget.stageId).notifier)
        .deleteRound(round.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Round deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref.read(roundControllerProvider(widget.stageId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to delete round.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showCreateRoundDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final roundNumCtrl = TextEditingController();
    final groupNumCtrl = TextEditingController(text: '1');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Create Round',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Round Name', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dialogInputDecoration(hint: 'e.g. Round 1'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Round name is required.' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Round Number (optional)', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: roundNumCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dialogInputDecoration(hint: 'e.g. 1'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Number of Groups', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: groupNumCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dialogInputDecoration(hint: 'e.g. 1'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop({
                  'name': nameCtrl.text.trim(),
                  'roundNumber': int.tryParse(roundNumCtrl.text),
                  'numberOfGroups': int.tryParse(groupNumCtrl.text) ?? 1,
                });
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((result) async {
      if (result == null || !mounted) return;

      final success = await ref
          .read(roundControllerProvider(widget.stageId).notifier)
          .createRound(
            name: result['name'] as String,
            roundNumber: result['roundNumber'] as int?,
            numberOfGroups: result['numberOfGroups'] as int?,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Round created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final msg = ref.read(roundControllerProvider(widget.stageId)).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg ?? 'Failed to create round.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
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
    final state = ref.watch(roundControllerProvider(widget.stageId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoundDialog,
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
            'Rounds',
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

  Widget _buildBody(RoundState state) {
    return switch (state.listStatus) {
      RoundListStatus.initial || RoundListStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      RoundListStatus.empty => _EmptyState(onAdd: _showCreateRoundDialog),
      RoundListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(roundControllerProvider(widget.stageId).notifier)
              .fetchRounds(),
        ),
      RoundListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(roundControllerProvider(widget.stageId).notifier)
              .fetchRounds(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Quick Stats Overview Container
                _QuickStatsOverview(
                  tournament: widget.tournament,
                  roundsCount: state.rounds.length,
                  totalGroups: state.rounds.fold(0, (acc, r) => acc + r.numberOfGroups),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tournament Rounds Section Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tournament Rounds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: _showCreateRoundDialog,
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
                              'Add Round',
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

                // Rounds List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.rounds.length,
                  itemBuilder: (context, index) {
                    final round = state.rounds[index];
                    return _RoundCard(
                      index: index,
                      round: round,
                      onShowLeaderboard: () => context.pushNamed(
                        AppRoutes.leaderboard,
                        extra: LeaderboardArgs(
                          tournament: widget.tournament,
                          type: LeaderboardType.round,
                          id: round.id,
                          name: round.name,
                        ),
                      ),
                      onDelete: () => _confirmDelete(round),
                      onEdit: () => context.pushNamed(
                        AppRoutes.editRound,
                        extra: EditRoundArgs(
                          tournament: widget.tournament,
                          stageId: widget.stageId,
                          roundId: round.id,
                        ),
                      ),
                      onManageGroups: () => context.pushNamed(
                        AppRoutes.groupList,
                        extra: GroupArgs(
                          tournament: widget.tournament,
                          roundId: round.id,
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
    required this.roundsCount,
    required this.totalGroups,
  });

  final TournamentEntity tournament;
  final int roundsCount;
  final int totalGroups;

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
            icon: Icons.repeat_rounded,
            iconBg: const Color(0xFF6C5CE7),
            value: '$roundsCount',
            label: 'Total Rounds',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.grid_view_rounded,
            iconBg: const Color(0xFF00CEC9),
            value: '$totalGroups',
            label: 'Total Groups',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _StatItem(
            icon: Icons.access_time_rounded,
            iconBg: const Color(0xFF00B894),
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

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.index,
    required this.round,
    required this.onShowLeaderboard,
    required this.onEdit,
    required this.onDelete,
    required this.onManageGroups,
  });

  final int index;
  final RoundEntity round;
  final VoidCallback onShowLeaderboard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageGroups;

  @override
  Widget build(BuildContext context) {
    final orderNum = round.roundNumber > 0 ? round.roundNumber : index + 1;
    final statusLower = round.status.toLowerCase();
    final statusColor = switch (statusLower) {
      'active' || 'in_progress' => AppColors.primary,
      'completed' => AppColors.upcomingStatus,
      _ => AppColors.draftStatus,
    };
    final statusLabel = round.status.toUpperCase();

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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Glowing Status Bar Indicator Strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: Circular Order Badge + Name + Date + Status Badge + Popup Menu
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

                            // Title Column: Round Name + Date Row
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    round.name,
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
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          round.createdAt != null
                                              ? _formatDateShort(round.createdAt!)
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
                                    if (val == 'leaderboard') onShowLeaderboard();
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
                                            'Edit Round',
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
                                            'Delete Round',
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

                        // Round Bottom Stats Row: Round # | Groups
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.repeat_rounded,
                                  size: 14,
                                  color: AppColors.draftStatus,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Round #${round.roundNumber}',
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
                                  Icons.grid_view_rounded,
                                  size: 14,
                                  color: AppColors.upcomingStatus,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${round.numberOfGroups} Groups',
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

                        // Dedicated Manage Groups Action Button Row
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
                                onTap: onManageGroups,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Manage Groups',
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
              ],
            ),
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
                Icons.repeat_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Rounds Added Yet',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create rounds to organize groups and matches.',
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
                          'Add First Round',
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
