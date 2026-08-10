import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class TournamentSearchBar extends StatefulWidget {
  const TournamentSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Search tournaments...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  @override
  State<TournamentSearchBar> createState() => _TournamentSearchBarState();
}

class _TournamentSearchBarState extends State<TournamentSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    FocusScope.of(context).unfocus();
    widget.onSearch(widget.controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.cardBorder,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _triggerSearch(),
              onChanged: (val) {
                setState(() {});
                widget.onChanged?.call(val);
              },
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (hasText)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () {
                widget.controller.clear();
                setState(() {});
                widget.onSearch('');
                widget.onChanged?.call('');
              },
            ),
          if (widget.onFilterTap != null) ...[
            InkWell(
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.inputBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Dedicated Search Action Button
          ElevatedButton(
            onPressed: _triggerSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
