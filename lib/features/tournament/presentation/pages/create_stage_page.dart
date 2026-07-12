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
import '../controller/stage_controller.dart';
import '../controller/tournament_controller.dart';

class CreateStagePage extends ConsumerStatefulWidget {
  const CreateStagePage({super.key, required this.tournament});

  final TournamentEntity tournament;

  @override
  ConsumerState<CreateStagePage> createState() => _CreateStagePageState();
}

class _CreateStagePageState extends ConsumerState<CreateStagePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  MetaOption? _stageType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metaStatus = ref.read(tournamentControllerProvider).metaStatus;
      if (metaStatus == TournamentMetaStatus.initial) {
        ref.read(tournamentControllerProvider.notifier).fetchTournamentMeta();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref
        .read(stageControllerProvider(widget.tournament.id).notifier)
        .resetCreateStatus();

    if (!_formKey.currentState!.validate()) return;

    final orderRaw = _orderCtrl.text.trim();
    final order = orderRaw.isEmpty ? null : int.tryParse(orderRaw);

    final success = await ref
        .read(stageControllerProvider(widget.tournament.id).notifier)
        .createStage(
          name: _nameCtrl.text.trim(),
          stageType: _stageType!.value,
          order: order,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stage created'),
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
    final stageState = ref.watch(stageControllerProvider(widget.tournament.id));
    final tournamentState = ref.watch(tournamentControllerProvider);
    final isLoading = stageState.createStatus == StageActionStatus.loading;
    final fieldErrors = stageState.fieldErrors;
    final meta = tournamentState.meta;
    final metaLoading =
        tournamentState.metaStatus == TournamentMetaStatus.loading;

    if (meta != null && _stageType == null && meta.stageTypes.isNotEmpty) {
      _stageType = meta.stageTypes.first;
    }

    ref.listen(stageControllerProvider(widget.tournament.id), (_, next) {
      if (next.createStatus == StageActionStatus.error &&
          next.errorMessage != null) {
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Stage', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: metaLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FieldLabel(label: 'Tournament'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      initialValue: widget.tournament.name,
                      readOnly: true,
                      style: const TextStyle(color: AppColors.textSecondary),
                      decoration: _inputDecoration('').copyWith(
                        suffixIcon: const Icon(Icons.lock_outline_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Stage Name'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. Group Stage').copyWith(
                        errorText: fieldErrors['name'],
                      ),
                      validator: (v) => Validators.required(v),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Stage Type'),
                    const SizedBox(height: AppSpacing.xs),
                    if (meta != null &&
                        meta.stageTypes.isNotEmpty &&
                        _stageType != null)
                      DropdownButtonFormField<MetaOption>(
                        initialValue: _stageType,
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDecoration('Select stage type').copyWith(
                          errorText: fieldErrors['stage_type'],
                        ),
                        items: meta.stageTypes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.label),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _stageType = v),
                        validator: (_) =>
                            _stageType == null ? 'Stage type is required.' : null,
                      )
                    else
                      TextFormField(
                        enabled: false,
                        decoration:
                            _inputDecoration('No stage types available').copyWith(
                          errorText: fieldErrors['stage_type'],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Order (optional)'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _orderCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. 1').copyWith(
                        errorText: fieldErrors['order'],
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
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
                          : const Text('Create Stage',
                              style: AppTextStyles.labelLarge),
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
