import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/route_args.dart';
import '../../domain/entities/leaderboard_item_entity.dart';
import '../controller/leaderboard_controller.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({
    super.key,
    required this.args,
  });

  final LeaderboardArgs args;

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardControllerProvider(widget.args).notifier).fetchStandings();
    });
  }

  String _getTitle() {
    switch (widget.args.type) {
      case LeaderboardType.group:
        return '${widget.args.name} Standings';
      case LeaderboardType.round:
        return '${widget.args.name} Standings';
      case LeaderboardType.stage:
        return '${widget.args.name} Standings';
      case LeaderboardType.tournament:
        return 'Tournament Leaderboard';
      case LeaderboardType.match:
        return '${widget.args.name} Standings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardControllerProvider(widget.args));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _getTitle(),
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(leaderboardControllerProvider(widget.args).notifier)
            .fetchStandings(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(LeaderboardState state) {
    switch (state.status) {
      case LeaderboardStatus.initial:
      case LeaderboardStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case LeaderboardStatus.empty:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No standings available yet.',
                    style: AppTextStyles.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Submit match results to generate leaderboards.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      case LeaderboardStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage ?? 'An error occurred.',
                    style: AppTextStyles.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(leaderboardControllerProvider(widget.args).notifier)
                        .fetchStandings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        );
      case LeaderboardStatus.success:
        return _buildLeaderboardTable(state.items);
    }
  }

  Widget _buildLeaderboardTable(List<LeaderboardItemEntity> items) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              SizedBox(width: 40, child: Text('#', style: _headerStyle)),
              Expanded(child: Text('TEAM', style: _headerStyle)),
              SizedBox(width: 35, child: Text('M', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 35, child: Text('W', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 45, child: Text('K', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 50, child: Text('PTS', style: _headerStyle, textAlign: TextAlign.right)),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: AppColors.divider),
          itemBuilder: (context, index) {
            final item = items[index];
            final isLast = index == items.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(8))
                    : null,
              ),
              child: Row(
                children: [
                  // Rank Column
                  SizedBox(
                    width: 40,
                    child: _buildRankBadge(item.rank ?? (index + 1)),
                  ),
                  // Team Column
                  Expanded(
                    child: Text(
                      item.teamName ?? 'Unknown Team',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Matches played
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${item.matches}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Wins
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${item.wins}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Kills
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${item.kills}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Points
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${item.points}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        // Legend description
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legend',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              const _LegendRow(symbol: 'M', description: 'Matches Played'),
              const _LegendRow(symbol: 'W', description: 'Wins (1st placements in matches)'),
              const _LegendRow(symbol: 'K', description: 'Total Kill Finishes'),
              const _LegendRow(symbol: 'PTS', description: 'Total Points (Placement + Kills + Bonuses - Penalties)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const Center(
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFFFFD700), // Gold
          child: Text(
            '1',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    } else if (rank == 2) {
      return const Center(
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFFC0C0C0), // Silver
          child: Text(
            '2',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    } else if (rank == 3) {
      return const Center(
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFFCD7F32), // Bronze
          child: Text(
            '3',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    return Center(
      child: Text(
        '$rank',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
);

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.symbol,
    required this.description,
  });

  final String symbol;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              symbol,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
