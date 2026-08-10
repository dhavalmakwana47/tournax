import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';
import '../controller/match_result_controller.dart';

class MatchResultsDialog extends ConsumerStatefulWidget {
  const MatchResultsDialog({
    super.key,
    required this.match,
    required this.onSuccess,
  });

  final MatchEntity match;
  final VoidCallback onSuccess;

  @override
  ConsumerState<MatchResultsDialog> createState() => _MatchResultsDialogState();
}

class _MatchResultsDialogState extends ConsumerState<MatchResultsDialog> {
  final _formKey = GlobalKey<FormState>();

  // Input controllers mapped by team ID
  final Map<int, TextEditingController> _rankCtrls = {};
  final Map<int, TextEditingController> _killsCtrls = {};
  final Map<int, TextEditingController> _bonusCtrls = {};
  final Map<int, TextEditingController> _penaltyCtrls = {};
  final Map<int, TextEditingController> _survivalCtrls = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(matchResultControllerProvider(widget.match.id).notifier).fetchResults();
      _populateControllersFromState();
    });
  }

  void _initializeControllers() {
    for (var i = 0; i < widget.match.teams.length; i++) {
      final team = widget.match.teams[i];
      _getRankCtrl(team.id, i + 1);
      _getKillsCtrl(team.id);
      _getBonusCtrl(team.id);
      _getPenaltyCtrl(team.id);
      _getSurvivalCtrl(team.id);
    }
  }

  TextEditingController _getRankCtrl(int teamId, int defaultRank) {
    return _rankCtrls.putIfAbsent(teamId, () => TextEditingController(text: defaultRank.toString()));
  }

  TextEditingController _getKillsCtrl(int teamId) {
    return _killsCtrls.putIfAbsent(teamId, () => TextEditingController(text: '0'));
  }

  TextEditingController _getBonusCtrl(int teamId) {
    return _bonusCtrls.putIfAbsent(teamId, () => TextEditingController(text: '0'));
  }

  TextEditingController _getPenaltyCtrl(int teamId) {
    return _penaltyCtrls.putIfAbsent(teamId, () => TextEditingController(text: '0'));
  }

  TextEditingController _getSurvivalCtrl(int teamId) {
    return _survivalCtrls.putIfAbsent(teamId, () => TextEditingController(text: '0'));
  }

  void _populateControllersFromState() {
    if (!mounted) return;
    final state = ref.read(matchResultControllerProvider(widget.match.id));
    final existingResults = state.results;

    for (var i = 0; i < widget.match.teams.length; i++) {
      final team = widget.match.teams[i];
      final matchResult = existingResults.where((r) => r.teamId == team.id).firstOrNull;

      if (matchResult != null) {
        _getRankCtrl(team.id, i + 1).text = matchResult.rank.toString();
        _getKillsCtrl(team.id).text = matchResult.kills.toString();
        _getBonusCtrl(team.id).text = matchResult.bonusPoints.toString();
        _getPenaltyCtrl(team.id).text = matchResult.penaltyPoints.toString();
        _getSurvivalCtrl(team.id).text = matchResult.survivalTime.toString();
      } else {
        _getRankCtrl(team.id, i + 1).text = (i + 1).toString();
        _getKillsCtrl(team.id).text = '0';
        _getBonusCtrl(team.id).text = '0';
        _getPenaltyCtrl(team.id).text = '0';
        _getSurvivalCtrl(team.id).text = '0';
      }
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var ctrl in _rankCtrls.values) {
      ctrl.dispose();
    }
    for (var ctrl in _killsCtrls.values) {
      ctrl.dispose();
    }
    for (var ctrl in _bonusCtrls.values) {
      ctrl.dispose();
    }
    for (var ctrl in _penaltyCtrls.values) {
      ctrl.dispose();
    }
    for (var ctrl in _survivalCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final resultsList = <TeamResultEntity>[];
    for (var i = 0; i < widget.match.teams.length; i++) {
      final team = widget.match.teams[i];
      final rank = int.tryParse(_getRankCtrl(team.id, i + 1).text) ?? (i + 1);
      final kills = int.tryParse(_getKillsCtrl(team.id).text) ?? 0;
      final bonus = int.tryParse(_getBonusCtrl(team.id).text) ?? 0;
      final penalty = int.tryParse(_getPenaltyCtrl(team.id).text) ?? 0;
      final survival = int.tryParse(_getSurvivalCtrl(team.id).text) ?? 0;

      resultsList.add(
        TeamResultEntity(
          matchId: widget.match.id,
          teamId: team.id,
          rank: rank,
          kills: kills,
          bonusPoints: bonus,
          penaltyPoints: penalty,
          survivalTime: survival,
        ),
      );
    }

    final success = await ref
        .read(matchResultControllerProvider(widget.match.id).notifier)
        .saveResults(resultsList);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match results submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onSuccess();
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteResults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Results', style: AppTextStyles.titleMedium),
        content: const Text(
          'Are you sure you want to delete match results? This will reset status to scheduled and clear standings points.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await ref
        .read(matchResultControllerProvider(widget.match.id).notifier)
        .clearResults();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match results cleared successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onSuccess();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchResultControllerProvider(widget.match.id));
    final isLoading = state.status == MatchResultStatus.loading;
    final isSaving = state.saveStatus == MatchResultStatus.loading;
    final isDeleting = state.deleteStatus == MatchResultStatus.loading;
    final screenSize = MediaQuery.of(context).size;

    ref.listen(matchResultControllerProvider(widget.match.id), (prev, next) {
      if (prev?.status == MatchResultStatus.loading && next.status == MatchResultStatus.success) {
        _populateControllersFromState();
      }
    });

    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.all(AppSpacing.md),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      actionsPadding: const EdgeInsets.all(AppSpacing.md),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Match #${widget.match.matchNumber} Results',
                  style: AppTextStyles.titleMedium,
                ),
                if (widget.match.map != null)
                  Text(
                    'Map: ${widget.match.map}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (state.results.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'COMPLETED',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: 450,
          maxHeight: screenSize.height * 0.7,
        ),
        width: screenSize.width * 0.9,
        child: isLoading
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.match.teams.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Text(
                            'No teams in this match. Please assign teams to the match first.',
                            style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.match.teams.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final team = widget.match.teams[index];
                            final rankCtrl = _getRankCtrl(team.id, index + 1);
                            final killsCtrl = _getKillsCtrl(team.id);
                            final bonusCtrl = _getBonusCtrl(team.id);
                            final penaltyCtrl = _getPenaltyCtrl(team.id);

                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      // Rank
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Rank', style: _labelStyle),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller: rankCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                              decoration: _inputDecoration(),
                                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      // Kills
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Kills', style: _labelStyle),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller: killsCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                              decoration: _inputDecoration(),
                                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      // Bonus Points
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Bonus Pts', style: _labelStyle),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller: bonusCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                              decoration: _inputDecoration(),
                                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      // Penalty Points
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Penalty Pts', style: _labelStyle),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller: penaltyCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                              decoration: _inputDecoration(),
                                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        Row(
          children: [
            if (state.results.isNotEmpty)
              TextButton(
                onPressed: isDeleting || isSaving ? null : _deleteResults,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: AppColors.error, strokeWidth: 2),
                      )
                    : const Text('Delete Results'),
              ),
            const Spacer(),
            TextButton(
              onPressed: isSaving || isDeleting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (widget.match.teams.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: isSaving || isDeleting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}

const TextStyle _labelStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 11,
  fontWeight: FontWeight.bold,
);
