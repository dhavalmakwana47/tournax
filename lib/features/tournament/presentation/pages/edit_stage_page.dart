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

class EditStagePage extends ConsumerStatefulWidget {
  const EditStagePage({
    super.key,
    required this.tournament,
    required this.stageId,
  });

  final TournamentEntity tournament;
  final int stageId;

  @override
  ConsumerState<EditStagePage> createState() => _EditStagePageState();
}

class _EditStagePageState extends ConsumerState<EditStagePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  MetaOption? _stageType;
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

    final stageFuture = ref
        .read(stageControllerProvider(widget.tournament.id).notifier)
        .showStage(widget.stageId);

    final results = await Future.wait([metaFuture, stageFuture]);
    if (!mounted) return;

    final stage = results[1];
    if (stage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load stage details.'),
          backgroundColor: AppColors.error,
        ),
      );
      context.pop();
      return;
    }

    final meta = ref.read(tournamentControllerProvider).meta;
    _nameCtrl.text = stage.name;
    _orderCtrl.text = stage.order?.toString() ?? '';

    MetaOption? matched;
    if (meta != null) {
      try {
        matched = meta.stageTypes.firstWhere((o) => o.value == stage.stageType);
      } catch (_) {
        matched = meta.stageTypes.isNotEmpty ? meta.stageTypes.first : null;
      }
    }

    setState(() {
      _stageType = matched;
      _prefilled = true;
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
        .resetUpdateStatus();

    if (!_formKey.currentState!.validate()) return;

    final orderRaw = _orderCtrl.text.trim();
    final order = orderRaw.isEmpty ? null : int.tryParse(orderRaw);

    final success = await ref
        .read(stageControllerProvider(widget.tournament.id).notifier)
        .updateStage(
          stageId: widget.stageId,
          name: _nameCtrl.text.trim(),
          stageType: _stageType!.value,
          order: order,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stage updated'),
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
    final isLoading = stageState.updateStatus == StageActionStatus.loading;
    final fieldErrors = stageState.fieldErrors;
    final meta = tournamentState.meta;

    ref.listen(stageControllerProvider(widget.tournament.id), (_, next) {
      if (next.updateStatus == StageActionStatus.error &&
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
            const Text('Edit Stage', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: !_prefilled
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel(label: 'Stage Name'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLength: 100,
                      decoration: _inputDecoration('e.g. Group Stage').copyWith(
                        errorText: fieldErrors['name'],
                        counterText: '',
                      ),
                      validator: (v) => Validators.required(v),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FieldLabel(label: 'Stage Type'),
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
                    const _FieldLabel(label: 'Order (optional)'),
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
                          : const Text('Update Stage',
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
