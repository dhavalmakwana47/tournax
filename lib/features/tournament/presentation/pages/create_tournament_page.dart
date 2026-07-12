import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/tournament_meta_entity.dart';
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
  final _regStartCtrl = TextEditingController();
  final _regEndCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();

  MetaOption? _mode;
  MetaOption? _tournamentType;
  MetaOption? _leaderboardType;
  bool _checkInEnabled = false;
  bool _allowSubstitute = false;
  bool _autoQualify = false;

  static String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

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
    _regStartCtrl.dispose();
    _regEndCtrl.dispose();
    _rulesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(TextEditingController ctrl) async {
    final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardBackground,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardBackground,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    ctrl.text = _formatDateTime(dt);
    setState(() {});
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
          maxTeams: int.parse(_maxTeamsCtrl.text.trim()),
          maxPlayersPerTeam: int.parse(_maxPlayersCtrl.text.trim()),
          startDate: _startDateCtrl.text.trim(),
          endDate: _endDateCtrl.text.trim(),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          registrationStart: _regStartCtrl.text.trim().isEmpty
              ? null
              : _regStartCtrl.text.trim(),
          registrationEnd: _regEndCtrl.text.trim().isEmpty
              ? null
              : _regEndCtrl.text.trim(),
          checkInEnabled: _checkInEnabled,
          allowSubstitute: _allowSubstitute,
          autoQualify: _autoQualify,
          leaderboardType: _leaderboardType?.value,
          rules: _rulesCtrl.text.trim().isEmpty ? null : _rulesCtrl.text.trim(),
        );

    if (!mounted) return;
    if (!success) {
      _formKey.currentState!.validate();
    } else {
      Navigator.of(context).pop();
    }
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
      _leaderboardType ??=
          meta.leaderboardTypes.isNotEmpty ? meta.leaderboardTypes.first : null;
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
        title: const Text('Create Tournament', style: AppTextStyles.titleMedium),
      ),
      body: metaLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : metaError
              ? _MetaErrorState(
                  onRetry: () => ref
                      .read(tournamentControllerProvider.notifier)
                      .fetchTournamentMeta(),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _SectionHeader(title: 'Basic Info'),
                      const SizedBox(height: AppSpacing.sm),
                      _FormField(
                        label: 'Tournament Name',
                        child: TextFormField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          maxLength: 100,
                          decoration: _inputDec('e.g. Champions League 2025')
                              .copyWith(
                                  errorText: fieldErrors['name'],
                                  counterText: ''),
                          validator: Validators.tournamentName,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FormField(
                        label: 'Description (optional)',
                        child: TextFormField(
                          controller: _descCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          maxLength: 2000,
                          decoration: _inputDec('Brief description...')
                              .copyWith(
                                  errorText: fieldErrors['description'],
                                  counterText: ''),
                          validator: Validators.description,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionHeader(title: 'Format'),
                      const SizedBox(height: AppSpacing.sm),
                      if (meta != null && _mode != null)
                        _FormField(
                          label: 'Mode',
                          child: _DropdownField<MetaOption>(
                            value: _mode!,
                            items: meta.modes,
                            errorText: fieldErrors['mode'],
                            onChanged: (v) => setState(() => _mode = v),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      if (meta != null && _tournamentType != null)
                        _FormField(
                          label: 'Tournament Type',
                          child: _DropdownField<MetaOption>(
                            value: _tournamentType!,
                            items: meta.tournamentTypes,
                            errorText: fieldErrors['tournament_type'],
                            onChanged: (v) =>
                                setState(() => _tournamentType = v),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      if (meta != null && _leaderboardType != null)
                        _FormField(
                          label: 'Leaderboard Type',
                          child: _DropdownField<MetaOption>(
                            value: _leaderboardType!,
                            items: meta.leaderboardTypes,
                            errorText: fieldErrors['leaderboard_type'],
                            onChanged: (v) =>
                                setState(() => _leaderboardType = v),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Max Teams',
                              child: TextFormField(
                                controller: _maxTeamsCtrl,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration: _inputDec('e.g. 16').copyWith(
                                    errorText: fieldErrors['max_teams']),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: Validators.maxTeams,
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
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration: _inputDec('e.g. 4').copyWith(
                                    errorText:
                                        fieldErrors['max_players_per_team']),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: Validators.maxPlayersPerTeam,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionHeader(title: 'Schedule'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Start Date & Time',
                              child: TextFormField(
                                controller: _startDateCtrl,
                                readOnly: true,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration:
                                    _inputDec('yyyy-MM-dd HH:mm:ss').copyWith(
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  errorText: fieldErrors['start_date'],
                                ),
                                validator: Validators.futureDateTime,
                                onTap: () => _pickDateTime(_startDateCtrl),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _FormField(
                              label: 'End Date & Time',
                              child: TextFormField(
                                controller: _endDateCtrl,
                                readOnly: true,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration:
                                    _inputDec('yyyy-MM-dd HH:mm:ss').copyWith(
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  errorText: fieldErrors['end_date'],
                                ),
                                validator: Validators.endDateAfterStart(
                                    _startDateCtrl.text),
                                onTap: () => _pickDateTime(_endDateCtrl),
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
                              label: 'Registration Start (optional)',
                              child: TextFormField(
                                controller: _regStartCtrl,
                                readOnly: true,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration:
                                    _inputDec('yyyy-MM-dd HH:mm:ss').copyWith(
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  errorText: fieldErrors['registration_start'],
                                ),
                                onTap: () => _pickDateTime(_regStartCtrl),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _FormField(
                              label: 'Registration End (optional)',
                              child: TextFormField(
                                controller: _regEndCtrl,
                                readOnly: true,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                decoration:
                                    _inputDec('yyyy-MM-dd HH:mm:ss').copyWith(
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18),
                                  errorText: fieldErrors['registration_end'],
                                ),
                                validator: Validators.registrationEndAfterStart(
                                    _regStartCtrl.text),
                                onTap: () => _pickDateTime(_regEndCtrl),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionHeader(title: 'Settings'),
                      const SizedBox(height: AppSpacing.xs),
                      _ToggleTile(
                        label: 'Check-in Enabled',
                        value: _checkInEnabled,
                        onChanged: (v) => setState(() => _checkInEnabled = v),
                      ),
                      _ToggleTile(
                        label: 'Allow Substitute',
                        value: _allowSubstitute,
                        onChanged: (v) => setState(() => _allowSubstitute = v),
                      ),
                      _ToggleTile(
                        label: 'Auto Qualify',
                        value: _autoQualify,
                        onChanged: (v) => setState(() => _autoQualify = v),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionHeader(title: 'Rules'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _rulesCtrl,
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLength: 5000,
                        decoration: _inputDec('Tournament rules...')
                            .copyWith(
                                errorText: fieldErrors['rules'],
                                counterText: ''),
                        validator: Validators.rules,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
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
                            : const Text('Create Tournament',
                                style: AppTextStyles.labelLarge),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium,
        errorMaxLines: 3,
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
          borderSide:
              const BorderSide(color: AppColors.inputBorderFocused, width: 1.5),
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

class _MetaErrorState extends StatelessWidget {
  const _MetaErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSpacing.md),
          const Text('Failed to load options.',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onRetry,
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppSpacing.xs),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
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

  String _label(T item) => item is MetaOption ? item.label : item.toString();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: AppColors.cardBackground,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        errorText: errorText,
        errorMaxLines: 3,
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
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(_label(e))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: SwitchListTile(
        title: Text(label, style: AppTextStyles.bodyMedium),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
    );
  }
}
