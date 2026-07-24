import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TournamentBadge extends StatelessWidget {
  const TournamentBadge({super.key, required this.status});

  final String status;

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.draftStatus;
      case 'upcoming':
        return AppColors.upcomingStatus;
      case 'live':
      case 'active':
      case 'ongoing':
        return AppColors.liveStatus;
      case 'completed':
      case 'finished':
        return AppColors.completedStatus;
      default:
        return AppColors.draftStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
