import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tournament/domain/entities/tournament_entity.dart';
import '../../../tournament/domain/entities/group_entity.dart';
import '../../../tournament/domain/entities/match_entity.dart';
import '../controller/slot_list_generator_controller.dart';
import '../renderer/template_renderer.dart';
import '../../domain/models/template_model.dart';

class SlotListGeneratorPage extends ConsumerStatefulWidget {
  final TournamentEntity tournament;
  final GroupEntity group;
  final MatchEntity match;

  const SlotListGeneratorPage({
    super.key,
    required this.tournament,
    required this.group,
    required this.match,
  });

  @override
  ConsumerState<SlotListGeneratorPage> createState() => _SlotListGeneratorPageState();
}

class _SlotListGeneratorPageState extends ConsumerState<SlotListGeneratorPage> with SingleTickerProviderStateMixin {
  final GlobalKey _exportBoundaryKey = GlobalKey();
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isDownloading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(slotListGeneratorControllerProvider.notifier).init(
            tournament: widget.tournament,
            group: widget.group,
            match: widget.match,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _downloadGraphic(TemplateModel template) async {
    setState(() => _isDownloading = true);
    try {
      // Delay briefly to ensure boundary repaint is complete
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary = _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Render boundary not initialized');

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to capture PNG byte data');

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final String fileName = 'SlotList_${widget.match.id}_${DateTime.now().millisecondsSinceEpoch}';

      if (!kIsWeb) {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: true);
        }
        await Gal.putImageBytes(pngBytes, name: fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved successfully to Phone Gallery!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(slotListGeneratorControllerProvider);
    final notifier = ref.read(slotListGeneratorControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Slot List Generator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              'Customize layout & download graphic',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: (_isDownloading || state.selectedTemplate == null)
                  ? null
                  : () => _downloadGraphic(state.selectedTemplate!),
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(_isDownloading ? 'Saving...' : 'Download'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // Invisible Offscreen RepaintBoundary overlay with OverflowBox (Unclipped 1080x1350 layout for full-res export)
                if (state.selectedTemplate != null)
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.01,
                      child: OverflowBox(
                        minWidth: state.selectedTemplate!.canvasSpec.width,
                        maxWidth: state.selectedTemplate!.canvasSpec.width,
                        minHeight: state.selectedTemplate!.canvasSpec.height,
                        maxHeight: state.selectedTemplate!.canvasSpec.height,
                        alignment: Alignment.topLeft,
                        child: RepaintBoundary(
                          key: _exportBoundaryKey,
                          child: SizedBox(
                            width: state.selectedTemplate!.canvasSpec.width,
                            height: state.selectedTemplate!.canvasSpec.height,
                            child: TemplateRenderer(
                              template: state.selectedTemplate!,
                              overrideVariables: state.variables,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Main Interactive Viewport Layout
                Column(
                  children: [
                    // Top Bar: Template Picker Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          const Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Template:',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TemplateModel>(
                                  dropdownColor: AppColors.surface,
                                  value: state.selectedTemplate,
                                  isExpanded: true,
                                  items: state.templates.map((tpl) {
                                    return DropdownMenuItem<TemplateModel>(
                                      value: tpl,
                                      child: Text(
                                        tpl.name,
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (tpl) {
                                    if (tpl != null) notifier.selectTemplate(tpl);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Middle: Live Viewport Preview Container
                    Expanded(
                      flex: 5,
                      child: _buildLivePreviewViewport(state),
                    ),

                    Container(height: 1, color: AppColors.cardBorder),

                    // Bottom: User-Friendly Categorized Text Fields Editor Panel
                    Expanded(
                      flex: 5,
                      child: _buildCategorizedEditorPanel(state, notifier),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLivePreviewViewport(SlotListGeneratorState state) {
    if (state.selectedTemplate == null) {
      return const Center(child: Text('No template selected', style: TextStyle(color: AppColors.textSecondary)));
    }

    final spec = state.selectedTemplate!.canvasSpec;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth - 24;
        final double maxH = constraints.maxHeight - 24;

        double targetW = maxW;
        double targetH = targetW * (spec.height / spec.width);

        if (targetH > maxH) {
          targetH = maxH;
          targetW = targetH * (spec.width / spec.height);
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF09090B),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: targetW,
                    height: targetH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TemplateRenderer(
                        template: state.selectedTemplate!,
                        overrideVariables: state.variables,
                        customSize: Size(targetW, targetH),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Template Canvas: ${spec.width.toInt()} × ${spec.height.toInt()} (${state.selectedTemplate!.name})',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorizedEditorPanel(SlotListGeneratorState state, SlotListGeneratorController notifier) {
    final allEntries = state.variables.entries.toList();

    // Group 1: General Match Info (tournament, group, match, date)
    final generalEntries = allEntries.where((e) {
      final k = e.key.toLowerCase();
      return k.contains('tournament') || k.contains('group') || k.contains('match') || k.contains('date') || k.contains('prize');
    }).toList();

    // Group 2: Team Slots (team_1 ... team_N)
    final slotEntries = allEntries.where((e) {
      final k = e.key.toLowerCase();
      return !generalEntries.contains(e);
    }).where((e) {
      if (_searchQuery.isEmpty) return true;
      final label = e.key.toLowerCase();
      final val = e.value.toLowerCase();
      return label.contains(_searchQuery) || val.contains(_searchQuery);
    }).toList();

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Tab Header
          Container(
            color: AppColors.cardBackground,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'General Info (${generalEntries.length})'),
                Tab(text: 'Slot Teams (${slotEntries.length})'),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: General Info
                ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: generalEntries.length,
                  itemBuilder: (context, index) {
                    final entry = generalEntries[index];
                    return _buildFieldCard(entry, state.selectedTemplate?.id, notifier);
                  },
                ),

                // Tab 2: Slot Team Names
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search slot team name...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSecondary),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: slotEntries.length,
                        itemBuilder: (context, index) {
                          final entry = slotEntries[index];
                          return _buildFieldCard(entry, state.selectedTemplate?.id, notifier);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(MapEntry<String, String> entry, String? templateId, SlotListGeneratorController notifier) {
    final labelName = entry.key
        .replaceAll('{{', '')
        .replaceAll('}}', '')
        .replaceAll('_', ' ')
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  labelName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: entry.value,
            key: ValueKey('${templateId}_${entry.key}'),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (val) => notifier.updateVariable(entry.key, val),
          ),
        ],
      ),
    );
  }
}
