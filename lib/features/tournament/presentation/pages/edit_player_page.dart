import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_search_result.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_meta_entity.dart';
import '../controller/team_controller.dart';
import '../controller/tournament_controller.dart';
import '../widgets/player_search_field.dart';

class EditPlayerPage extends ConsumerStatefulWidget {
  const EditPlayerPage({
    super.key,
    required this.tournament,
    required this.team,
    required this.player,
  });

  final TournamentEntity tournament;
  final TeamEntity team;
  final PlayerEntity player;

  @override
  ConsumerState<EditPlayerPage> createState() => _EditPlayerPageState();
}

class _EditPlayerPageState extends ConsumerState<EditPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gameUidCtrl = TextEditingController();
  MetaOption? _role;
  bool _prefilled = false;
  String? _resolvedRoleValue;
  Map<String, String> _fieldErrors = const {};
  int? _userId;
  PlayerSearchResult? _initialSearchSelection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureMeta();
      _loadPlayer();
    });
  }

  void _ensureMeta() {
    final metaStatus = ref.read(tournamentControllerProvider).metaStatus;
    if (metaStatus == TournamentMetaStatus.initial) {
      ref.read(tournamentControllerProvider.notifier).fetchTournamentMeta();
    }
  }

  Future<void> _loadPlayer() async {
    final fetched = await ref
        .read(teamControllerProvider(widget.tournament.id).notifier)
        .fetchPlayer(
          teamId: widget.team.id,
          playerId: widget.player.id,
        );

    if (!mounted) return;

    final source = fetched ?? widget.player;
    _nameCtrl.text = source.name;
    _gameUidCtrl.text = source.gameUid ?? '';
    _resolvedRoleValue = source.role;
    setState(() => _prefilled = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gameUidCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = const {});
    if (!_formKey.currentState!.validate()) return;

    final notifier =
        ref.read(teamControllerProvider(widget.tournament.id).notifier);
    notifier.resetUpdatePlayerStatus();

    final success = await notifier.updatePlayer(
      teamId: widget.team.id,
      playerId: widget.player.id,
      name: _nameCtrl.text.trim(),
      gameUid: _gameUidCtrl.text.trim().isEmpty
          ? null
          : _gameUidCtrl.text.trim(),
      role: _role?.value,
      userId: _userId,
    );

    if (!mounted) return;

    if (!success) {
      _formKey.currentState!.validate();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Player updated successfully.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamControllerProvider(widget.tournament.id));
    final tournamentState = ref.watch(tournamentControllerProvider);
    final isLoading = teamState.updatePlayerStatus == TeamActionStatus.loading;
    final meta = tournamentState.meta;
    final metaLoading =
        tournamentState.metaStatus == TournamentMetaStatus.loading;

    if (_prefilled && meta != null && _role == null &&
        meta.playerRoles.isNotEmpty) {
      _role = meta.playerRoles.firstWhere(
        (r) => r.value == _resolvedRoleValue,
        orElse: () => meta.playerRoles.first,
      );
    }

    ref.listen(teamControllerProvider(widget.tournament.id), (_, next) {
      if (next.updatePlayerStatus == TeamActionStatus.error) {
        if (next.fieldErrors.isNotEmpty) {
          setState(() => _fieldErrors = next.fieldErrors);
          _formKey.currentState!.validate();
        } else if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
            const Text('Edit Player', style: AppTextStyles.titleMedium),
            Text(widget.team.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: !_prefilled || metaLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Search Existing Player (optional)',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    PlayerSearchField(
                      initialSelection: _initialSearchSelection,
                      onSelected: (result) {
                        setState(() => _userId = result?.id);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Player Name', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. John Doe'),
                      validator: (v) =>
                          Validators.required(v) ?? _fieldErrors['name'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Game UID (optional)',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _gameUidCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. player#1234'),
                      validator: (_) => _fieldErrors['game_uid'],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Role (optional)', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    if (meta != null &&
                        meta.playerRoles.isNotEmpty &&
                        _role != null)
                      DropdownButtonFormField<MetaOption>(
                        initialValue: _role,
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDecoration('Select role').copyWith(
                          errorText: _fieldErrors['role'],
                        ),
                        items: meta.playerRoles
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.label),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _role = v),
                      )
                    else
                      TextFormField(
                        enabled: false,
                        decoration:
                            _inputDecoration('No roles available').copyWith(
                          errorText: _fieldErrors['role'],
                        ),
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
                          : const Text('Save Changes',
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
