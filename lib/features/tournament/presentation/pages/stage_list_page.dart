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
        title: const Text('Delete Stage', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${stage.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stages', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.createStage,
                extra: StageArgs(tournament: widget.tournament),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Stage'),
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

  Widget _buildBody(StageState state) {
    return switch (state.listStatus) {
      StageListStatus.initial ||
      StageListStatus.loading =>
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
          onRefresh: () => ref
              .read(stageControllerProvider(widget.tournament.id).notifier)
              .fetchStages(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.stages.length,
            itemBuilder: (_, i) => _StageCard(
              stage: state.stages[i],
              onEdit: () => context.pushNamed(
                AppRoutes.editStage,
                extra: EditStageArgs(
                  tournament: widget.tournament,
                  stageId: state.stages[i].id,
                ),
              ),
              onDelete: () => _confirmDelete(state.stages[i]),
            ),
          ),
        ),
    };
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.onEdit,
    required this.onDelete,
  });

  final StageEntity stage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
            child: const Icon(Icons.account_tree_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stage.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _TypeBadge(stageType: stage.stageType),
                    if (stage.order != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text('Order: ${stage.order}',
                          style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
                if (stage.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(stage.createdAt!),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMenu(context),
            icon: const Icon(Icons.more_vert_rounded,
                size: 20, color: AppColors.textSecondary),
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
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
        PopupMenuItem(value: 'edit', child: Text('Edit Stage')),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete Stage',
              style: TextStyle(color: AppColors.error)),
        ),
      ],
    ).then((value) {
      if (value == 'edit') onEdit();
      if (value == 'delete') onDelete();
    });
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.stageType});

  final String stageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        stageType.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
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
          const Icon(Icons.account_tree_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No stages yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add the first stage to get started.',
              style: AppTextStyles.bodyMedium),
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
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center),
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
