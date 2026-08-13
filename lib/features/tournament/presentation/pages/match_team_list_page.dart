import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/routes/app_router.dart';
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
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDragPointerMove(Offset globalPosition) {
    const double edgeThreshold = 140.0;
    const double scrollSpeed = 15.0;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double topEdge = edgeThreshold;
    final double bottomEdge = screenHeight - edgeThreshold;

    if (globalPosition.dy < topEdge) {
      _startAutoScroll(-scrollSpeed);
    } else if (globalPosition.dy > bottomEdge) {
      _startAutoScroll(scrollSpeed);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double offset) {
    if (_autoScrollTimer != null && _autoScrollTimer!.isActive) return;
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_scrollController.hasClients) return;
      final currentOffset = _scrollController.offset;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final newOffset = (currentOffset + offset).clamp(0.0, maxExtent);

      if (newOffset != currentOffset) {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
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
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Remove Team', style: AppTextStyles.titleMedium),
          ],
        ),
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
        AppToast.showSuccess(context, 'Removed "${team.name}" from match.');
      }
    }
  }

  Future<void> _autoAssignSlots(MatchEntity match, List<MatchTeamMemberEntity> teams) async {
    if (teams.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text('Auto-Slot Teams?', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Text(
          'Are you sure you want to automatically assign sequential slots (1..${teams.length}) to all teams in this match?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text('Auto-Slot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(matchControllerProvider(widget.group.id).notifier)
          .autoAssignSequentialSlots(matchId: match.id, teams: teams);

      if (success && mounted) {
        AppToast.showSuccess(context, 'Auto-assigned slots 1..${teams.length} successfully!');
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
        ? DateFormat('MMM d, yyyy • HH:mm').format(DateTime.parse(currentMatch.scheduledAt!).toLocal())
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.slotListGenerator,
                extra: SlotListGeneratorArgs(
                  tournament: widget.tournament,
                  group: widget.group,
                  match: currentMatch,
                ),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
              label: const Text(
                'Slot Graphic',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeamDialog(currentMatch),
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Add Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: Listener(
        onPointerMove: (event) => _handleDragPointerMove(event.position),
        onPointerUp: (_) => _stopAutoScroll(),
        onPointerCancel: (_) => _stopAutoScroll(),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(matchControllerProvider(widget.group.id).notifier).loadMatches(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Match Overview Banner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cardBackground,
                        AppColors.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Match #${currentMatch.matchNumber}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              currentMatch.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentMatch.name ?? 'Match ${currentMatch.matchNumber}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.map_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  currentMatch.map ?? 'TBD Map',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.groups_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${teams.length} Teams Assigned',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Interactive Drag & Drop Hint Banner
                if (teams.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hold & drag the ⠿ handle on any team card to reorder slots instantly.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Section Header Row with Slot Tools
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Match Slots',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${teams.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (teams.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => _autoAssignSlots(currentMatch, teams),
                            icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                            label: const Text(
                              'Auto-Slot (1..N)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.amber.withValues(alpha: 0.6)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.amber.withValues(alpha: 0.08),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Teams List with Reorderable Drag-and-Drop Slot Swapper
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            Icons.sports_esports_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Teams Assigned to Match',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add teams from the group to allocate match slots and drop locations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showAddTeamDialog(currentMatch),
                          icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            'Add First Team',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: teams.length,
                    onReorder: (oldIndex, newIndex) async {
                      final mutableTeams = List<MatchTeamMemberEntity>.from(teams);
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = mutableTeams.removeAt(oldIndex);
                      mutableTeams.insert(newIndex, item);

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 24),
                              SizedBox(width: 8),
                              Text('Confirm Slot Reorder', style: AppTextStyles.titleMedium),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to save the new slot order for "${item.name}"?',
                            style: AppTextStyles.bodyMedium,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Save Order'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        final success = await ref
                            .read(matchControllerProvider(widget.group.id).notifier)
                            .updateTeamListOrder(
                              matchId: currentMatch.id,
                              reorderedTeams: mutableTeams,
                            );

                        if (success && mounted) {
                          AppToast.showSuccess(context, 'Reordered match team slots successfully!');
                        }
                      }
                    },
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final displaySlot = team.slot != null ? '#${team.slot.toString().padLeft(2, '0')}' : 'TBD';

                      return Container(
                        key: ValueKey(team.id),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                                width: 5,
                                child: Container(color: AppColors.primary),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.drag_indicator_rounded,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Prominent Slot Badge
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 42),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, Color(0xFFFF8C00)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          displaySlot,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.shield_outlined,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  team.name,
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (team.lane != null && team.lane!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.06),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '🎯 Drop: ${team.lane}',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
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
                const SizedBox(height: 80), // Extra space for FloatingActionButton
              ],
            ),
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
  late final TextEditingController _slotCtrl;
  final _laneCtrl = TextEditingController();

  int? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    // Smart pre-fill next slot number
    final nextSlot = widget.match.teams.length + 1;
    _slotCtrl = TextEditingController(text: nextSlot.toString());
  }

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
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      title: const Row(
        children: [
          Icon(Icons.group_add_rounded, color: AppColors.primary, size: 24),
          SizedBox(width: 10),
          Text('Add Team to Match', style: AppTextStyles.titleMedium),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (availableTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'All group teams are already assigned to this match.',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
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
                    prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                  ),
                  items: availableTeams
                      .map((team) => DropdownMenuItem<int>(
                            value: team.id,
                            child: Text(team.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTeamId = v),
                  validator: (v) => v == null ? 'Please select a team' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _slotCtrl,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Slot Number').copyWith(
                    errorText: errors['slot'],
                    prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 20),
                    hintText: 'e.g. 1',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _laneCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Drop Location / Lane (optional)').copyWith(
                    errorText: errors['lane'],
                    prefixIcon: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                    hintText: 'e.g. Pochinki / Lane A',
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
          FilledButton.icon(
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
                      final teamName = availableTeams
                          .firstWhere((t) => t.id == _selectedTeamId, orElse: () => availableTeams.first)
                          .name;
                      widget.onSuccess();
                      Navigator.of(context).pop();
                      AppToast.showSuccess(context, 'Added "$teamName" to match successfully!');
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: isSaving
                ? const SizedBox.shrink()
                : const Icon(Icons.add_rounded, size: 18),
            label: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add Team'),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
