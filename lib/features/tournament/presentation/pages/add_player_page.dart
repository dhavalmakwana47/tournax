import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_meta_entity.dart';
import '../controller/team_controller.dart';
import '../controller/tournament_controller.dart';
import '../widgets/player_search_field.dart';

class AddPlayerPage extends ConsumerStatefulWidget {
  const AddPlayerPage({
    super.key,
    required this.tournament,
    required this.team,
  });

  final TournamentEntity tournament;
  final TeamEntity team;

  @override
  ConsumerState<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends ConsumerState<AddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gameUidCtrl = TextEditingController();
  MetaOption? _role;
  int? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metaStatus = ref.read(tournamentControllerProvider).metaStatus;
      if (metaStatus == TournamentMetaStatus.initial) {
        ref
            .read(tournamentControllerProvider.notifier)
            .fetchTournamentMeta();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gameUidCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref
        .read(teamControllerProvider(widget.tournament.id).notifier)
        .resetAddPlayerStatus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(teamControllerProvider(widget.tournament.id).notifier)
        .addPlayer(
          teamId: widget.team.id,
          name: _nameCtrl.text.trim(),
          gameUid: _gameUidCtrl.text.trim().isEmpty
              ? null
              : _gameUidCtrl.text.trim(),
          role: _role?.value,
          userId: _userId,
        );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamControllerProvider(widget.tournament.id));
    final tournamentState = ref.watch(tournamentControllerProvider);
    final isLoading = teamState.addPlayerStatus == TeamActionStatus.loading;
    final fieldErrors = teamState.fieldErrors;
    final meta = tournamentState.meta;
    final metaLoading =
        tournamentState.metaStatus == TournamentMetaStatus.loading;

    // Set default role once meta loads
    if (meta != null && _role == null && meta.playerRoles.isNotEmpty) {
      _role = meta.playerRoles.first;
    }

    ref.listen(teamControllerProvider(widget.tournament.id), (_, next) {
      if (next.addPlayerStatus == TeamActionStatus.error &&
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
            const Text('Add Player', style: AppTextStyles.titleMedium),
            Text(widget.team.name, style: AppTextStyles.bodySmall),
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
                    _FieldLabel(label: 'Search Existing Player (optional)'),
                    const SizedBox(height: AppSpacing.xs),
                    PlayerSearchField(
                      onSelected: (result) {
                        setState(() {
                          _userId = result?.id;
                          if (result != null && _nameCtrl.text.trim().isEmpty) {
                            _nameCtrl.text = result.name;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Player Name'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. John Doe').copyWith(
                        errorText: fieldErrors['name'],
                      ),
                      validator: (v) => Validators.required(v),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Game UID (optional)'),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _gameUidCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('e.g. player#1234').copyWith(
                        errorText: fieldErrors['game_uid'],
                      ),
                      validator: null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FieldLabel(label: 'Role (optional)'),
                    const SizedBox(height: AppSpacing.xs),
                    if (meta != null && meta.playerRoles.isNotEmpty && _role != null)
                      DropdownButtonFormField<MetaOption>(
                        initialValue: _role,
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDecoration('Select role').copyWith(
                          errorMaxLines: 3,
                          errorText: fieldErrors['role'],
                        ),
                        validator: null,
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
                          errorText: fieldErrors['role'],
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
                          : const Text('Add Player',
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
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTextStyles.bodyMedium);
}
