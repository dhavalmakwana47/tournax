import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/team_controller.dart';

class TeamListPage extends ConsumerStatefulWidget {
  const TeamListPage({super.key, required this.tournament});

  final TournamentEntity tournament;

  @override
  ConsumerState<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends ConsumerState<TeamListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(teamControllerProvider(widget.tournament.id).notifier)
          .fetchTeams();
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
            const Text('Teams', style: AppTextStyles.titleMedium),
            Text(
              widget.tournament.name,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: () => context.pushNamed(
                AppRoutes.addTeam,
                extra: widget.tournament,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Team'),
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
    return switch (state.listStatus) {
      TeamListStatus.initial ||
      TeamListStatus.loading =>
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      TeamListStatus.empty => _EmptyTeamsState(
          onAddTeam: () => context.pushNamed(
            AppRoutes.addTeam,
            extra: widget.tournament,
          ),
        ),
      TeamListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(teamControllerProvider(widget.tournament.id).notifier)
              .fetchTeams(),
        ),
      TeamListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(teamControllerProvider(widget.tournament.id).notifier)
              .fetchTeams(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.teams.length,
            itemBuilder: (_, i) => _TeamCard(
              team: state.teams[i],
              tournament: widget.tournament,
            ),
          ),
        ),
    };
  }
}

class _TeamCard extends ConsumerWidget {
  const _TeamCard({required this.team, required this.tournament});

  final TeamEntity team;
  final TournamentEntity tournament;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Team', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to delete "${team.name}"? This action cannot be undone.',
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
        .deleteTeam(team.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team deleted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final msg = ref
          .read(teamControllerProvider(tournament.id))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'Failed to delete team.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref.watch(teamControllerProvider(tournament.id)
            .select((s) => s.deleteTeamStatus)) ==
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
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.groups_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${team.playerCount} player${team.playerCount == 1 ? '' : 's'}',
                  style: AppTextStyles.bodySmall,
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
                AppRoutes.editTeam,
                extra: EditTeamArgs(
                  tournament: tournament,
                  team: team,
                ),
              ),
              icon: const Icon(Icons.edit_rounded,
                  size: 18, color: AppColors.textSecondary),
              tooltip: 'Edit Team',
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_rounded,
                  size: 18, color: AppColors.error),
              tooltip: 'Delete Team',
            ),
          ],
          TextButton.icon(
            onPressed: () => context.pushNamed(
              AppRoutes.playerList,
              extra: PlayerListArgs(
                tournament: tournament,
                team: team,
              ),
            ),
            icon: const Icon(Icons.people_rounded,
                size: 16, color: AppColors.primary),
            label: const Text('Players',
                style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _EmptyTeamsState extends StatelessWidget {
  const _EmptyTeamsState({required this.onAddTeam});

  final VoidCallback onAddTeam;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.groups_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No teams yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Add the first team to get started.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAddTeam,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Team'),
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

/// Remove private args class — using shared AddPlayerArgs from route_args.dart
