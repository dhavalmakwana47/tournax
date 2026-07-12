import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/team_controller.dart';

class PlayerListPage extends ConsumerStatefulWidget {
  const PlayerListPage({
    super.key,
    required this.tournament,
    required this.team,
  });

  final TournamentEntity tournament;
  final TeamEntity team;

  @override
  ConsumerState<PlayerListPage> createState() => _PlayerListPageState();
}

class _PlayerListPageState extends ConsumerState<PlayerListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(teamControllerProvider(widget.tournament.id).notifier)
          .fetchPlayers(widget.team.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamControllerProvider(widget.tournament.id));

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
            const Text('Players', style: AppTextStyles.titleMedium),
            Text(widget.team.name, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.addPlayer,
                extra: AddPlayerArgs(
                  tournament: widget.tournament,
                  team: widget.team,
                ),
              ),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Player'),
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

  Widget _buildBody(TeamState state) {
    return switch (state.playerListStatus) {
      PlayerListStatus.initial ||
      PlayerListStatus.loading =>
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      PlayerListStatus.empty => _EmptyPlayersState(
          onAddPlayer: () => context.pushNamed(
            AppRoutes.addPlayer,
            extra: AddPlayerArgs(
              tournament: widget.tournament,
              team: widget.team,
            ),
          ),
        ),
      PlayerListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(teamControllerProvider(widget.tournament.id).notifier)
              .fetchPlayers(widget.team.id),
        ),
      PlayerListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(teamControllerProvider(widget.tournament.id).notifier)
              .fetchPlayers(widget.team.id),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.players.length,
            itemBuilder: (_, i) => _PlayerCard(
              player: state.players[i],
              tournament: widget.tournament,
              team: widget.team,
            ),
          ),
        ),
    };
  }
}

class _PlayerCard extends ConsumerWidget {
  const _PlayerCard(
      {required this.player,
      required this.tournament,
      required this.team});

  final PlayerEntity player;
  final TournamentEntity tournament;
  final TeamEntity team;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Player', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${player.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(teamControllerProvider(tournament.id).notifier)
        .deletePlayer(teamId: team.id, playerId: player.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Player deleted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref
          .read(teamControllerProvider(tournament.id))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to delete player.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref.watch(teamControllerProvider(tournament.id)
            .select((s) => s.deletePlayerStatus)) ==
        TeamActionStatus.loading;

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
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    if (player.role != null && player.role!.isNotEmpty)
                      _InfoChip(
                          icon: Icons.shield_rounded, label: player.role!),
                    if (player.gameUid != null && player.gameUid!.isNotEmpty)
                      _InfoChip(
                          icon: Icons.tag_rounded, label: player.gameUid!),
                  ],
                ),
              ],
            ),
          ),
          if (isDeleting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.error),
            )
          else ...[  
            IconButton(
              onPressed: () => context.pushNamed(
                AppRoutes.editPlayer,
                extra: EditPlayerArgs(
                  tournament: tournament,
                  team: team,
                  player: player,
                ),
              ),
              icon: const Icon(Icons.edit_rounded,
                  size: 18, color: AppColors.textSecondary),
              tooltip: 'Edit Player',
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_rounded,
                  size: 18, color: AppColors.error),
              tooltip: 'Delete Player',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _EmptyPlayersState extends StatelessWidget {
  const _EmptyPlayersState({required this.onAddPlayer});

  final VoidCallback onAddPlayer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No players yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add the first player to this team.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAddPlayer,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Player'),
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
