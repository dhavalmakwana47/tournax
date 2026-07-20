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
              foregroundColor: AppColors.textPrimary,
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
        title: const Text('Create Round', style: AppTextStyles.titleMedium),
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
              foregroundColor: AppColors.textPrimary,
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
    final state = ref.watch(roundControllerProvider(widget.stageId));

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
            const Text('Rounds', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: _showCreateRoundDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Round'),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.rounds.length,
            itemBuilder: (_, i) => _RoundCard(
              round: state.rounds[i],
              onShowLeaderboard: () => context.pushNamed(
                AppRoutes.leaderboard,
                extra: LeaderboardArgs(
                  tournament: widget.tournament,
                  type: LeaderboardType.round,
                  id: state.rounds[i].id,
                  name: state.rounds[i].name,
                ),
              ),
              onDelete: () => _confirmDelete(state.rounds[i]),
              onManageGroups: () => context.pushNamed(
                AppRoutes.groupList,
                extra: GroupArgs(tournament: widget.tournament, roundId: state.rounds[i].id),
              ),
            ),
          ),
        ),
    };
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.round,
    required this.onShowLeaderboard,
    required this.onDelete,
    required this.onManageGroups,
  });

  final RoundEntity round;
  final VoidCallback onShowLeaderboard;
  final VoidCallback onDelete;
  final VoidCallback onManageGroups;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.repeat_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(round.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusBadge(status: round.status),
                    Text('Round: #${round.roundNumber}', style: AppTextStyles.bodySmall),
                    Text('Groups: ${round.numberOfGroups}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onShowLeaderboard,
                icon: const Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.warning),
                tooltip: 'Round Standings',
              ),
              IconButton(
                onPressed: onManageGroups,
                icon: const Icon(Icons.grid_view_rounded, size: 20, color: AppColors.primary),
                tooltip: 'Manage Groups',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                tooltip: 'Delete Round',
              ),
            ],
          ),
        ],
      ),
    );
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
          const Icon(Icons.repeat_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No rounds yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add the first round to get started.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Round'),
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
