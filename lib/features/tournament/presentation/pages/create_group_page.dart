import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/group_controller.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({
    super.key,
    required this.tournament,
    required this.roundId,
  });

  final TournamentEntity tournament;
  final int roundId;

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  String _status = 'pending';

  final List<String> _statusOptions = ['pending', 'active', 'completed'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref.read(groupControllerProvider(widget.roundId).notifier).resetCreateStatus();

    if (!_formKey.currentState!.validate()) return;

    final orderRaw = _orderCtrl.text.trim();
    final order = orderRaw.isEmpty ? null : int.tryParse(orderRaw);

    final success = await ref
        .read(groupControllerProvider(widget.roundId).notifier)
        .createGroup(
          name: _nameCtrl.text.trim(),
          displayOrder: order,
          status: _status,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group created successfully'),
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
    final groupState = ref.watch(groupControllerProvider(widget.roundId));
    final isLoading = groupState.createStatus == GroupActionStatus.loading;
    final fieldErrors = groupState.fieldErrors;

    ref.listen(groupControllerProvider(widget.roundId), (_, next) {
      if (next.createStatus == GroupActionStatus.error && next.errorMessage != null) {
        final isWarning = next.isWarning;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isWarning ? Icons.warning_amber_rounded : Icons.error_outline_rounded,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: isWarning ? AppColors.warning : AppColors.error,
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
            const Text('Create Group', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FieldLabel(label: 'Group Name'),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. Group A').copyWith(
                  errorText: fieldErrors['name'],
                ),
                validator: (v) => Validators.required(v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              const _FieldLabel(label: 'Display Order (optional)'),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _orderCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. 1').copyWith(
                  errorText: fieldErrors['display_order'],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              const _FieldLabel(label: 'Status'),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _inputDecoration('Select status').copyWith(
                  errorText: fieldErrors['status'],
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _status = v);
                  }
                },
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
                    : const Text('Create Group', style: AppTextStyles.labelLarge),
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
