import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/tournament/domain/entities/tournament_meta_entity.dart';
import '../controller/tournament_controller.dart';

class CreateTournamentPage extends ConsumerStatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  ConsumerState<CreateTournamentPage> createState() =>
      _CreateTournamentPageState();
}

class _CreateTournamentPageState extends ConsumerState<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _maxTeamsCtrl = TextEditingController();
  final _maxPlayersCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  MetaOption? _mode;
  MetaOption? _tournamentType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tournamentControllerProvider.notifier).fetchTournamentMeta();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _maxTeamsCtrl.dispose();
    _maxPlayersCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardBackground,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    ref.read(tournamentControllerProvider.notifier).resetCreateStatus();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(tournamentControllerProvider.notifier)
        .createTournament(
          name: _nameCtrl.text.trim(),
          mode: _mode!.value,
          tournamentType: _tournamentType!.value,
          maxTeams: int.parse(_maxTeamsCtrl.text),
          maxPlayersPerTeam: int.parse(_maxPlayersCtrl.text),
          startDate: _startDateCtrl.text,
          endDate: _endDateCtrl.text,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );

    if (!success && mounted) {
      _formKey.currentState!.validate();
    }

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentControllerProvider);
    final isLoading = state.createStatus == TournamentCreateStatus.loading;
    final fieldErrors = state.fieldErrors;
    final meta = state.meta;
    final metaLoading = state.metaStatus == TournamentMetaStatus.loading;
    final metaError = state.metaStatus == TournamentMetaStatus.error;

    if (meta != null) {
      _mode ??= meta.modes.isNotEmpty ? meta.modes.first : null;
      _tournamentType ??=
          meta.tournamentTypes.isNotEmpty ? meta.tournamentTypes.first : null;
    }

    ref.listen(tournamentControllerProvider, (_, next) {
      if (next.createStatus == TournamentCreateStatus.error &&
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Tournament',
            style: AppTextStyles.titleMedium),
      ),
      body: _buildBody(
        metaLoading: metaLoading,
        metaError: metaError,
        isLoading: isLoading,
        fieldErrors: fieldErrors,
        meta: meta,
      ),
    );
  }

  Widget _buildBody({
    required bool metaLoading,
    required bool metaError,
    required bool isLoading,
    required Map<String, String> fieldErrors,
    required dynamic meta,
  }) {
    if (metaLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (metaError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text('Failed to load options.',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => ref
                  .read(tournamentControllerProvider.notifier)
                  .fetchTournamentMeta(),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final modes = meta?.modes ?? const <MetaOption>[];
    final tournamentTypes = meta?.tournamentTypes ?? const <MetaOption>[];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _FormField(
            label: 'Tournament Name',
            child: TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('e.g. Champions League 2025'),
              validator: (v) =>
                  Validators.required(v) ?? fieldErrors['name'],
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Mode',
            child: _mode == null
                ? const SizedBox.shrink()
                : _DropdownField<MetaOption>(
                    value: _mode!,
                    items: modes,
                    errorText: fieldErrors['mode'],
                    onChanged: (v) => setState(() => _mode = v),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Tournament Type',
            child: _tournamentType == null
                ? const SizedBox.shrink()
                : _DropdownField<MetaOption>(
                    value: _tournamentType!,
                    items: tournamentTypes,
                    errorText: fieldErrors['tournament_type'],
                    onChanged: (v) => setState(() => _tournamentType = v),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Description (optional)',
            child: TextFormField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('Brief description...'),
              validator: (_) => fieldErrors['description'],
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Start Date',
                  child: TextFormField(
                    controller: _startDateCtrl,
                    readOnly: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 18),
                    ),
                    validator: (v) =>
                        Validators.required(v) ?? fieldErrors['start_date'],
                    onTap: () => _pickDate(_startDateCtrl),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FormField(
                  label: 'End Date',
                  child: TextFormField(
                    controller: _endDateCtrl,
                    readOnly: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textSecondary, size: 18),
                    ),
                    validator: (v) =>
                        Validators.required(v) ?? fieldErrors['end_date'],
                    onTap: () => _pickDate(_endDateCtrl),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Max Teams',
                  child: TextFormField(
                    controller: _maxTeamsCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('e.g. 16'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (v) =>
                        Validators.required(v) ?? fieldErrors['max_teams'],
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FormField(
                  label: 'Max Players / Team',
                  child: TextFormField(
                    controller: _maxPlayersCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('e.g. 11'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (v) =>
                        Validators.required(v) ??
                        fieldErrors['max_players_per_team'],
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.5),
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                : const Text('Create Tournament',
                    style: AppTextStyles.labelLarge),
          ),
        ],
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

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? errorText;

  String _displayLabel(T item) {
    if (item is MetaOption) return item.label;
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.cardBackground,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        errorText: errorText,
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
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(_displayLabel(e)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
