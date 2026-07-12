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
import '../controller/tournament_controller.dart';

class EditTournamentPage extends ConsumerStatefulWidget {
  const EditTournamentPage({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  ConsumerState<EditTournamentPage> createState() => _EditTournamentPageState();
}

class _EditTournamentPageState extends ConsumerState<EditTournamentPage> {
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

  TournamentEntity? _original;
  bool _prefilled = false;

  static String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

  static String? _normalizeDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    return dt != null ? _formatDateTime(dt.toLocal()) : raw;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final metaFuture = ref
        .read(tournamentControllerProvider.notifier)
        .fetchTournamentMeta();

    final tournamentFuture = ref
        .read(tournamentControllerProvider.notifier)
        .showTournament(widget.tournamentId);

    final results = await Future.wait([metaFuture, tournamentFuture]);
    if (!mounted) return;

    final tournament = results[1] as TournamentEntity?;
    if (tournament == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load tournament details.'),
          backgroundColor: AppColors.error,
        ),
      );
      context.pop();
      return;
    }

    _original = tournament;
    final meta = ref.read(tournamentControllerProvider).meta;

    _nameCtrl.text = tournament.name;
    _descCtrl.text = tournament.description ?? '';
    _maxTeamsCtrl.text = tournament.maxTeams.toString();
    _maxPlayersCtrl.text = tournament.maxPlayersPerTeam.toString();
    _startDateCtrl.text = _normalizeDateTime(tournament.startDate) ?? '';
    _endDateCtrl.text = _normalizeDateTime(tournament.endDate) ?? '';
    _regStartCtrl.text = _normalizeDateTime(tournament.registrationStart) ?? '';
    _regEndCtrl.text = _normalizeDateTime(tournament.registrationEnd) ?? '';
    _rulesCtrl.text = tournament.rules ?? '';
    _checkInEnabled = tournament.checkInEnabled;
    _allowSubstitute = tournament.allowSubstitute;
    _autoQualify = tournament.autoQualify;

    if (meta != null) {
      _mode = _findOption(meta.modes, tournament.mode) ??
          (meta.modes.isNotEmpty ? meta.modes.first : null);
      _tournamentType =
          _findOption(meta.tournamentTypes, tournament.tournamentType) ??
              (meta.tournamentTypes.isNotEmpty
                  ? meta.tournamentTypes.first
                  : null);
      if (tournament.leaderboardType != null) {
        _leaderboardType =
            _findOption(meta.leaderboardTypes, tournament.leaderboardType!);
      }
      _leaderboardType ??=
          meta.leaderboardTypes.isNotEmpty ? meta.leaderboardTypes.first : null;
    }

    setState(() => _prefilled = true);
  }

  MetaOption? _findOption(List<MetaOption> options, String value) {
    try {
      return options.firstWhere((o) => o.value == value);
    } catch (_) {
      return null;
    }
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

  /// Builds the update payload with only changed fields + tournament_id.
  Map<String, dynamic> _buildPayload() {
    final o = _original!;
    final payload = <String, dynamic>{'tournament_id': widget.tournamentId};

    final name = _nameCtrl.text.trim();
    if (name != o.name) payload['name'] = name;

    final desc = _descCtrl.text.trim();
    final origDesc = o.description ?? '';
    if (desc != origDesc) payload['description'] = desc.isEmpty ? null : desc;

    if (_mode != null && _mode!.value != o.mode) payload['mode'] = _mode!.value;

    if (_tournamentType != null && _tournamentType!.value != o.tournamentType) {
      payload['tournament_type'] = _tournamentType!.value;
    }

    final maxTeams = int.tryParse(_maxTeamsCtrl.text.trim());
    if (maxTeams != null && maxTeams != o.maxTeams) {
      payload['max_teams'] = maxTeams;
    }

    final maxPlayers = int.tryParse(_maxPlayersCtrl.text.trim());
    if (maxPlayers != null && maxPlayers != o.maxPlayersPerTeam) {
      payload['max_players_per_team'] = maxPlayers;
    }

    final startDate = _startDateCtrl.text.trim();
    if (startDate.isNotEmpty && startDate != (o.startDate ?? '')) {
      payload['start_date'] = startDate;
    }

    final endDate = _endDateCtrl.text.trim();
    if (endDate.isNotEmpty && endDate != (o.endDate ?? '')) {
      payload['end_date'] = endDate;
    }

    final regStart = _regStartCtrl.text.trim();
    if (regStart != (o.registrationStart ?? '')) {
      payload['registration_start'] = regStart.isEmpty ? null : regStart;
    }

    final regEnd = _regEndCtrl.text.trim();
    if (regEnd != (o.registrationEnd ?? '')) {
      payload['registration_end'] = regEnd.isEmpty ? null : regEnd;
    }

    if (_checkInEnabled != o.checkInEnabled) {
      payload['check_in_enabled'] = _checkInEnabled;
    }
    if (_allowSubstitute != o.allowSubstitute) {
      payload['allow_substitute'] = _allowSubstitute;
    }
    if (_autoQualify != o.autoQualify) {
      payload['auto_qualify'] = _autoQualify;
    }

    if (_leaderboardType != null &&
        _leaderboardType!.value != (o.leaderboardType ?? '')) {
      payload['leaderboard_type'] = _leaderboardType!.value;
    }

    final rules = _rulesCtrl.text.trim();
    if (rules != (o.rules ?? '')) {
      payload['rules'] = rules.isEmpty ? null : rules;
    }

    return payload;
  }

  Future<void> _submit() async {
    ref.read(tournamentControllerProvider.notifier).resetUpdateStatus();
    if (!_formKey.currentState!.validate()) return;

    final payload = _buildPayload();
    final success = await ref
        .read(tournamentControllerProvider.notifier)
        .updateTournament(payload);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament updated successfully.'),
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
    final state = ref.watch(tournamentControllerProvider);
    final isLoading = state.updateStatus == TournamentUpdateStatus.loading;
    final fieldErrors = state.fieldErrors;
    final meta = state.meta;

    ref.listen(tournamentControllerProvider, (_, next) {
      if (next.updateStatus == TournamentUpdateStatus.error &&
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
        title: const Text('Edit Tournament', style: AppTextStyles.titleMedium),
      ),
      body: !_prefilled
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
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
                      onChanged: (_) => _clearFieldError('name'),
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
                      onChanged: (_) => _clearFieldError('description'),
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
                        onChanged: (v) {
                          setState(() => _mode = v);
                          _clearFieldError('mode');
                        },
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
                        onChanged: (v) {
                          setState(() => _tournamentType = v);
                          _clearFieldError('tournament_type');
                        },
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
                        onChanged: (v) {
                          setState(() => _leaderboardType = v);
                          _clearFieldError('leaderboard_type');
                        },
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: _inputDec('e.g. 16').copyWith(
                                errorText: fieldErrors['max_teams']),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: Validators.maxTeams,
                            onChanged: (_) => _clearFieldError('max_teams'),
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: _inputDec('e.g. 4').copyWith(
                                errorText:
                                    fieldErrors['max_players_per_team']),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: Validators.maxPlayersPerTeam,
                            onChanged: (_) =>
                                _clearFieldError('max_players_per_team'),
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
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
                            style:
                                const TextStyle(color: AppColors.textPrimary),
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
                            errorText: fieldErrors['rules'], counterText: ''),
                    validator: Validators.rules,
                    onChanged: (_) => _clearFieldError('rules'),
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
                        : const Text('Update Tournament',
                            style: AppTextStyles.labelLarge),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
    );
  }

  void _clearFieldError(String key) {
    final errors = ref.read(tournamentControllerProvider).fieldErrors;
    if (errors.containsKey(key)) {
      // Trigger re-validate to clear the inline error on next build.
      setState(() {});
    }
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.primary)),
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
