import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'tournament_badge.dart';

class TournamentProgressBar extends StatelessWidget {
  const TournamentProgressBar({
    super.key,
    required this.status,
    required this.stageText,
    required this.progressPercent,
  });

  final String status;
  final String stageText; // e.g. "Stage 1 of 5"
  final double progressPercent; // 0.0 to 1.0 (e.g. 0.20 = 20%)

  @override
  Widget build(BuildContext context) {
    final statusColor = TournamentBadge.getStatusColor(status);
    final percentInt = (progressPercent * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tournament Progress',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              stageText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$percentInt%',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 5,
                color: AppColors.background,
              ),
              FractionallySizedBox(
                widthFactor: progressPercent.clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

