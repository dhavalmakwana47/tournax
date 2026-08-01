import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tournament_meta_entity.dart';

class TournamentStatusFilterRow extends StatelessWidget {
  const TournamentStatusFilterRow({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.statusOptions,
  });

  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;
  final List<MetaOption>? statusOptions;

  Color _getStatusColor(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return AppColors.draftStatus;
      case 'upcoming':
        return AppColors.upcomingStatus;
      case 'ongoing':
      case 'live':
      case 'active':
      case 'in_progress':
        return AppColors.liveStatus;
      case 'completed':
        return AppColors.completedStatus;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {'value': 'all', 'label': 'All', 'color': AppColors.primary},
    ];

    if (statusOptions != null && statusOptions!.isNotEmpty) {
      for (final opt in statusOptions!) {
        items.add({
          'value': opt.value,
          'label': opt.label,
          'color': _getStatusColor(opt.value),
        });
      }
    } else {
      items.addAll([
        {'value': 'draft', 'label': 'Draft', 'color': AppColors.draftStatus},
        {'value': 'published', 'label': 'Published', 'color': AppColors.upcomingStatus},
        {'value': 'live', 'label': 'Live', 'color': AppColors.liveStatus},
        {'value': 'completed', 'label': 'Completed', 'color': AppColors.completedStatus},
      ]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items.map((statusItem) {
          final value = statusItem['value'] as String;
          final label = statusItem['label'] as String;
          final dotColor = statusItem['color'] as Color;
          final isSelected = selectedStatus.toLowerCase() == value.toLowerCase() ||
              selectedStatus.toLowerCase() == label.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TournamentStatusChip(
              label: label,
              dotColor: dotColor,
              isSelected: isSelected,
              onTap: () => onStatusSelected(value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TournamentStatusChip extends StatelessWidget {
  const TournamentStatusChip({
    super.key,
    required this.label,
    required this.dotColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color dotColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.inputFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardBorder.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? Colors.white : dotColor)
                            .withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
