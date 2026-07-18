import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/point_system_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/point_system_controller.dart';

class PointSystemPage extends ConsumerStatefulWidget {
  const PointSystemPage({
    super.key,
    required this.tournament,
    required this.groupId,
  });

  final TournamentEntity tournament;
  final int groupId;

  @override
  ConsumerState<PointSystemPage> createState() => _PointSystemPageState();
}

class _PointSystemPageState extends ConsumerState<PointSystemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _killPointCtrl = TextEditingController(text: '1.0');
  final _descCtrl = TextEditingController();

  // Local state representing the placement rules being edited
  final List<Map<String, dynamic>> _rules = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pointSystemControllerProvider(widget.groupId).notifier).loadPointSystems();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _killPointCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _initializeFields(PointSystemEntity? custom) {
    if (_initialized) return;
    if (custom != null) {
      _nameCtrl.text = custom.name;
      _codeCtrl.text = custom.code;
      _killPointCtrl.text = custom.killPoint.toString();
      _descCtrl.text = custom.description ?? '';
      _rules.clear();
      for (final r in custom.rules) {
        _rules.add({
          'placement': r.placement,
          'placement_points': r.placementPoints,
          'controller': TextEditingController(text: r.placementPoints.toString()),
        });
      }
      _rules.sort((a, b) => (a['placement'] as int).compareTo(b['placement'] as int));
    } else {
      _loadPreset('bgmi_15');
    }
    _initialized = true;
  }

  void _loadPreset(String type) {
    setState(() {
      if (type == 'bgmi_15') {
        _nameCtrl.text = 'BGMI 15-Point System';
        _codeCtrl.text = 'bgmi_15';
        _killPointCtrl.text = '1.0';
        _descCtrl.text = 'Standard BGMI 15-point placement rules';
        
        final bgmiPoints = [15.0, 12.0, 10.0, 8.0, 6.0, 4.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0];
        _rules.clear();
        for (int i = 0; i < bgmiPoints.length; i++) {
          _rules.add({
            'placement': i + 1,
            'placement_points': bgmiPoints[i],
            'controller': TextEditingController(text: bgmiPoints[i].toString()),
          });
        }
      } else if (type == 'pmgc_10') {
        _nameCtrl.text = 'PMGC 10-Point System';
        _codeCtrl.text = 'pmgc_10';
        _killPointCtrl.text = '1.0';
        _descCtrl.text = 'Standard PMGC 10-point placement rules';

        final pmgcPoints = [10.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        _rules.clear();
        for (int i = 0; i < pmgcPoints.length; i++) {
          _rules.add({
            'placement': i + 1,
            'placement_points': pmgcPoints[i],
            'controller': TextEditingController(text: pmgcPoints[i].toString()),
          });
        }
      }
    });
  }

  void _addPlacementRow() {
    setState(() {
      final nextPlacement = _rules.isEmpty ? 1 : (_rules.last['placement'] as int) + 1;
      _rules.add({
        'placement': nextPlacement,
        'placement_points': 0.0,
        'controller': TextEditingController(text: '0.0'),
      });
    });
  }

  void _removePlacementRow(int index) {
    setState(() {
      final controller = _rules[index]['controller'] as TextEditingController;
      controller.dispose();
      _rules.removeAt(index);
      // Re-index placements sequentially
      for (int i = 0; i < _rules.length; i++) {
        _rules[i]['placement'] = i + 1;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ruleDataList = <Map<String, dynamic>>[];
    for (final r in _rules) {
      final ctrl = r['controller'] as TextEditingController;
      final pts = double.tryParse(ctrl.text.trim()) ?? 0.0;
      ruleDataList.add({
        'placement': r['placement'] as int,
        'placement_points': pts,
      });
    }

    if (ruleDataList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one placement rule.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(pointSystemControllerProvider(widget.groupId).notifier)
        .saveCustomPointSystem(
          name: _nameCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
          killPoint: double.tryParse(_killPointCtrl.text.trim()) ?? 1.0,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          rules: ruleDataList,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Point system configured successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Point System', style: AppTextStyles.titleMedium),
        content: const Text(
          'Are you sure you want to delete this custom configuration? The group will revert to using global defaults.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(pointSystemControllerProvider(widget.groupId).notifier)
        .resetToDefault();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Point system reset to defaults.'),
          backgroundColor: AppColors.success,
        ),
      );
      _initialized = false;
      ref.read(pointSystemControllerProvider(widget.groupId).notifier).loadPointSystems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pointSystemControllerProvider(widget.groupId));
    final isLoading = state.status == PointSystemActionStatus.loading;
    final isSaving = state.saveStatus == PointSystemActionStatus.loading;
    final isDeleting = state.deleteStatus == PointSystemActionStatus.loading;
    final fieldErrors = state.fieldErrors;

    if (state.status == PointSystemActionStatus.success) {
      _initializeFields(state.customPointSystem);
    }

    ref.listen(pointSystemControllerProvider(widget.groupId), (_, next) {
      if (next.saveStatus == PointSystemActionStatus.error && next.errorMessage != null) {
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
            const Text('Configure Points', style: AppTextStyles.titleMedium),
            Text(widget.tournament.name, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          if (state.customPointSystem != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.error),
              tooltip: 'Reset to Defaults',
              onPressed: isDeleting ? null : _resetToDefault,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading explaining presets
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Quick Load Presets',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _loadPreset('bgmi_15'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primary),
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                  ),
                                  child: const Text('BGMI 15-Pt'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _loadPreset('pmgc_10'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.accent),
                                    foregroundColor: AppColors.accent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                  ),
                                  child: const Text('PMGC 10-Pt'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Configuration metadata fields
                    const _SectionHeading(title: 'Metadata Settings'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Point System Name').copyWith(
                        errorText: fieldErrors['name'],
                      ),
                      validator: (v) => Validators.required(v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _codeCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Unique Code (e.g. custom_15)').copyWith(
                        errorText: fieldErrors['code'],
                      ),
                      validator: (v) => Validators.required(v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _killPointCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Points per Kill').copyWith(
                        errorText: fieldErrors['kill_point'],
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (v) => Validators.required(v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 2,
                      decoration: _inputDecoration('Description (optional)').copyWith(
                        errorText: fieldErrors['description'],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Placement rules editor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeading(title: 'Placement Rules'),
                        TextButton.icon(
                          onPressed: _addPlacementRow,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Place'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Rules List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rules.length,
                      itemBuilder: (context, idx) {
                        final r = _rules[idx];
                        final place = r['placement'] as int;
                        final ctrl = r['controller'] as TextEditingController;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _placeSuffix(place),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: ctrl,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    hintText: '0.0',
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                onPressed: () => _removePlacementRow(idx),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Text('Save Configuration', style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _placeSuffix(int place) {
    if (place == 1) return '1st Place';
    if (place == 2) return '2nd Place';
    if (place == 3) return '3rd Place';
    return '${place}th Place';
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium,
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
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      );
}
