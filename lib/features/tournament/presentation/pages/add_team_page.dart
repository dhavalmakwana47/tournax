import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/team_controller.dart';

class AddTeamPage extends ConsumerStatefulWidget {
  const AddTeamPage({super.key, required this.tournament});

  final TournamentEntity tournament;

  @override
  ConsumerState<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends ConsumerState<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref
        .read(teamControllerProvider(widget.tournament.id).notifier)
        .resetCreateTeamStatus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(teamControllerProvider(widget.tournament.id).notifier)
        .createTeam(_nameCtrl.text.trim());

    if (!success && mounted) {
      _formKey.currentState!.validate();
    }

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamControllerProvider(widget.tournament.id));
    final isLoading = state.createTeamStatus == TeamActionStatus.loading;
    final fieldErrors = state.fieldErrors;

    ref.listen(teamControllerProvider(widget.tournament.id), (_, next) {
      if (next.createTeamStatus == TeamActionStatus.error &&
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
            const Text('Add Team', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel(label: 'Team Name'),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. Team Alpha'),
                validator: (v) =>
                    Validators.required(v) ?? fieldErrors['name'],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
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
                    : const Text('Create Team',
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
