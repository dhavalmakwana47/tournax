import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controller/tournament_controller.dart';
import '../widgets/tournament_card.dart';

class TournamentListPage extends ConsumerStatefulWidget {
  const TournamentListPage({super.key});

  @override
  ConsumerState<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends ConsumerState<TournamentListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tournamentControllerProvider.notifier).fetchTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(AppRoutes.createTournament),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, color: AppColors.textPrimary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'CREATE TOURNAMENT',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: _buildBody(state)),
      ],
    );
  }

  Widget _buildBody(TournamentState state) {
    return switch (state.listStatus) {
      TournamentListStatus.initial ||
      TournamentListStatus.loading =>
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      TournamentListStatus.empty => _EmptyState(
          onRetry: () => ref
              .read(tournamentControllerProvider.notifier)
              .fetchTournaments(),
        ),
      TournamentListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(tournamentControllerProvider.notifier)
              .fetchTournaments(),
        ),
      TournamentListStatus.success => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(tournamentControllerProvider.notifier)
              .fetchTournaments(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: state.tournaments.length,
            itemBuilder: (_, i) =>
                TournamentCard(tournament: state.tournaments[i]),
          ),
        ),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          const Text('No tournaments yet', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Create your first tournament above.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          TextButton(onPressed: onRetry, child: const Text('Refresh')),
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
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
