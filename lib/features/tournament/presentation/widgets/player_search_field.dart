import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_search_result.dart';

class PlayerSearchField extends ConsumerStatefulWidget {
  const PlayerSearchField({
    super.key,
    required this.onSelected,
    this.initialSelection,
  });

  final void Function(PlayerSearchResult?) onSelected;
  final PlayerSearchResult? initialSelection;

  @override
  ConsumerState<PlayerSearchField> createState() => _PlayerSearchFieldState();
}

class _PlayerSearchFieldState extends ConsumerState<PlayerSearchField> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<PlayerSearchResult> _results = [];
  bool _loading = false;
  String? _error;
  PlayerSearchResult? _selected;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selected = widget.initialSelection;
      _ctrl.text = widget.initialSelection!.name;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_selected != null) {
      _selected = null;
      widget.onSelected(null);
    }
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = [];
        _showSuggestions = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value.trim()));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _showSuggestions = true;
    });
    try {
      final results =
          await ref.read(searchPlayerUseCaseProvider).call(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Search failed. Please try again.';
      });
    }
  }

  void _select(PlayerSearchResult result) {
    setState(() {
      _selected = result;
      _ctrl.text = result.name;
      _showSuggestions = false;
      _results = [];
    });
    _focusNode.unfocus();
    widget.onSelected(result);
  }

  void _clear() {
    setState(() {
      _selected = null;
      _ctrl.clear();
      _results = [];
      _showSuggestions = false;
      _error = null;
    });
    widget.onSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          style: const TextStyle(color: AppColors.textPrimary),
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search by name, username or email...',
            hintStyle: AppTextStyles.bodyMedium,
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
            suffixIcon: _selected != null
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: _clear,
                    tooltip: 'Clear selection',
                  )
                : _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.inputBorderFocused, width: 1.5),
            ),
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _SelectedPlayerChip(result: _selected!, onClear: _clear),
        ],
        if (_showSuggestions && !_loading && _error == null && _results.isEmpty)
          _SuggestionContainer(
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No players found.', style: AppTextStyles.bodyMedium),
            ),
          ),
        if (_showSuggestions && _error != null)
          _SuggestionContainer(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
          ),
        if (_showSuggestions && !_loading && _results.isNotEmpty)
          _SuggestionContainer(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) => _SuggestionTile(
                result: _results[i],
                onTap: () => _select(_results[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _SuggestionContainer extends StatelessWidget {
  const _SuggestionContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.result, required this.onTap});
  final PlayerSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.name, style: AppTextStyles.titleMedium),
            const SizedBox(height: 2),
            if (result.username != null)
              Text('@${result.username}', style: AppTextStyles.bodySmall),
            Text(result.email, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlayerChip extends StatelessWidget {
  const _SelectedPlayerChip({required this.result, required this.onClear});
  final PlayerSearchResult result;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(
                  [if (result.username != null) '@${result.username}', result.email].join(' · '),
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
