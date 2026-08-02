import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_meta_entity.dart';
import '../controller/round_controller.dart';
import '../controller/tournament_controller.dart';

class EditRoundPage extends ConsumerStatefulWidget {
  const EditRoundPage({
    super.key,
    required this.tournament,
    required this.stageId,
    required this.roundId,
  });

  final TournamentEntity tournament;
  final int stageId;
  final int roundId;

  @override
  ConsumerState<EditRoundPage> createState() => _EditRoundPageState();
}

class _EditRoundPageState extends ConsumerState<EditRoundPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roundNumCtrl = TextEditingController();
  final _groupNumCtrl = TextEditingController();
  MetaOption? _roundStatusOption;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final metaFuture = () async {
      final metaStatus = ref.read(tournamentControllerProvider).metaStatus;
      if (metaStatus == TournamentMetaStatus.initial) {
        await ref
            .read(tournamentControllerProvider.notifier)
            .fetchTournamentMeta();
      }
    }();

    final roundFuture = ref
        .read(roundControllerProvider(widget.stageId).notifier)
        .showRound(widget.roundId);

    final results = await Future.wait([metaFuture, roundFuture]);
    if (!mounted) return;

    final round = results[1];
    if (round == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load round details.'),
          backgroundColor: AppColors.error,
        ),
      );
      context.pop();
      return;
    }

    final meta = ref.read(tournamentControllerProvider).meta;
    final roundStatuses = meta?.roundStatuses ?? TournamentMetaEntity.defaultRoundStatuses;

    _nameCtrl.text = round.name;
    _roundNumCtrl.text = round.roundNumber.toString();
    _groupNumCtrl.text = round.numberOfGroups.toString();

    MetaOption? matchedStatus;
    try {
      matchedStatus = roundStatuses.firstWhere((o) => o.value == round.status);
    } catch (_) {
      matchedStatus = roundStatuses.isNotEmpty ? roundStatuses.first : null;
    }

    setState(() {
      _roundStatusOption = matchedStatus;
      _prefilled = true;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roundNumCtrl.dispose();
    _groupNumCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref.read(roundControllerProvider(widget.stageId).notifier).resetUpdateStatus();

    if (!_formKey.currentState!.validate()) return;

    final roundNumRaw = _roundNumCtrl.text.trim();
    final roundNum = roundNumRaw.isEmpty ? null : int.tryParse(roundNumRaw);

    final groupNumRaw = _groupNumCtrl.text.trim();
    final groupNum = groupNumRaw.isEmpty ? null : int.tryParse(groupNumRaw);

    final success = await ref
        .read(roundControllerProvider(widget.stageId).notifier)
        .updateRound(
          roundId: widget.roundId,
          name: _nameCtrl.text.trim(),
          roundNumber: roundNum,
          numberOfGroups: groupNum,
          status: _roundStatusOption?.value ?? 'pending',
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Round updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundState = ref.watch(roundControllerProvider(widget.stageId));
    final tournamentState = ref.watch(tournamentControllerProvider);
    final isLoading = roundState.updateStatus == RoundActionStatus.loading;
    final fieldErrors = roundState.fieldErrors;
    final meta = tournamentState.meta;
    final roundStatuses = meta?.roundStatuses ?? TournamentMetaEntity.defaultRoundStatuses;

    ref.listen(roundControllerProvider(widget.stageId), (_, next) {
      if (next.updateStatus == RoundActionStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Round', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: !_prefilled
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel(label: 'Round Name'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. Round 1').copyWith(
                        errorText: fieldErrors['name'],
                      ),
                      validator: (v) => Validators.required(v),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FieldLabel(label: 'Round Number (optional)'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _roundNumCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. 1').copyWith(
                        errorText: fieldErrors['round_number'],
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FieldLabel(label: 'Number of Groups'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _groupNumCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. 1').copyWith(
                        errorText: fieldErrors['number_of_groups'],
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: (v) => Validators.required(v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FieldLabel(label: 'Status'),
                    const SizedBox(height: AppSpacing.xs),
                    if (_roundStatusOption != null)
                      DropdownButtonFormField<MetaOption>(
                        initialValue: _roundStatusOption,
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDecoration('Select status').copyWith(
                          errorText: fieldErrors['status'],
                        ),
                        items: roundStatuses
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _roundStatusOption = v);
                          }
                        },
                      )
                    else
                      TextFormField(
                        enabled: false,
                        decoration: _inputDecoration('No statuses available').copyWith(
                          errorText: fieldErrors['status'],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Text('Update Round', style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
          borderSide: const BorderSide(
              color: AppColors.inputBorderFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTextStyles.bodyMedium);
}
