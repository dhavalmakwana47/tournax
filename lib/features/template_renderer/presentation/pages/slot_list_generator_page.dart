import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tournament/domain/entities/tournament_entity.dart';
import '../../../tournament/domain/entities/group_entity.dart';
import '../../../tournament/domain/entities/match_entity.dart';
import '../../domain/models/template_model.dart';
import '../controller/slot_list_generator_controller.dart';
import '../renderer/template_renderer.dart';

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
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _exportBoundaryKey = GlobalKey();
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

  Future<void> _handleDownload(SlotListGeneratorState state, SlotListGeneratorController notifier) async {
    if (state.selectedTemplate == null) return;
    if (state.totalPages <= 1) {
      await _downloadGraphic(state.selectedTemplate!);
      return;
    }

    // Show options for multi-page templates
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'This match has ${widget.match.teams.length} teams spanning ${state.totalPages} template pages.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.collections_rounded, color: AppColors.primary, size: 22),
                  ),
                  title: Text(
                    'Download All ${state.totalPages} Pages',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Saves Page 1, Page 2... as separate images in Phone Gallery',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadAllPages(state, notifier);
                  },
                ),
                const Divider(color: AppColors.cardBorder),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.image_rounded, color: AppColors.textPrimary, size: 22),
                  ),
                  title: Text(
                    'Download Current Page (Page ${state.currentPageIndex + 1})',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Only saves visible Page ${state.currentPageIndex + 1} graphic',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadGraphic(state.selectedTemplate!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAllPages(SlotListGeneratorState state, SlotListGeneratorController notifier) async {
    setState(() => _isDownloading = true);
    try {
      int savedCount = 0;
      final originalPageIndex = state.currentPageIndex;

      if (!kIsWeb) {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: true);
        }
      }

      for (int pageIdx = 0; pageIdx < state.totalPages; pageIdx++) {
        notifier.selectPage(pageIdx);
        await Future.delayed(const Duration(milliseconds: 250));

        final boundary = _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) continue;

        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) continue;

        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final String fileName = 'SlotList_${widget.match.id}_Page${pageIdx + 1}_${DateTime.now().millisecondsSinceEpoch}';

        if (!kIsWeb) {
          await Gal.putImageBytes(pngBytes, name: fileName);
        }
        savedCount++;
      }

      // Restore original page selection
      notifier.selectPage(originalPageIndex);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved all $savedCount pages successfully to Phone Gallery!',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
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

  Future<void> _downloadGraphic(TemplateModel template) async {
    setState(() => _isDownloading = true);
    try {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Slot List Generator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              state.totalPages > 1
                  ? 'Multi-Page Graphic (${state.totalPages} Pages)'
                  : 'Customize layout & download graphic',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: (_isDownloading || state.selectedTemplate == null)
                  ? null
                  : () => _handleDownload(state, notifier),
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(_isDownloading ? 'Saving...' : (state.totalPages > 1 ? 'Download (${state.totalPages}P)' : 'Download')),
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
                // Invisible Offscreen RepaintBoundary overlay for full-res export
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
                              overrideVariables: state.currentVariables,
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

                    // Multi-Page Pagination Bar (Shown when totalPages > 1)
                    _buildPageNavigationBar(state, notifier),

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

  Widget _buildPageNavigationBar(SlotListGeneratorState state, SlotListGeneratorController notifier) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    final int current1Based = state.currentPageIndex + 1;
    final int startTeam = (state.currentPageIndex * state.slotsPerPage) + 1;
    final int endTeam = (startTeam + state.slotsPerPage - 1).clamp(1, widget.match.teams.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF131722),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Multi-Page Graphic ($current1Based / ${state.totalPages})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Teams $startTeam-$endTeam of ${widget.match.teams.length}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: state.currentPageIndex > 0 ? AppColors.textPrimary : Colors.white24,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: state.currentPageIndex > 0
                ? () => notifier.selectPage(state.currentPageIndex - 1)
                : null,
          ),
          Text(
            '$current1Based / ${state.totalPages}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: state.currentPageIndex < state.totalPages - 1 ? AppColors.textPrimary : Colors.white24,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: state.currentPageIndex < state.totalPages - 1
                ? () => notifier.selectPage(state.currentPageIndex + 1)
                : null,
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
                        overrideVariables: state.currentVariables,
                        customSize: Size(targetW, targetH),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Canvas: ${spec.width.toInt()} × ${spec.height.toInt()} (${state.selectedTemplate!.name})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  if (state.totalPages > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PAGE ${state.currentPageIndex + 1}/${state.totalPages}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorizedEditorPanel(SlotListGeneratorState state, SlotListGeneratorController notifier) {
    final vars = state.currentVariables;

    final generalEntries = vars.entries.where((e) {
      final key = e.key.toLowerCase();
      return !key.contains('team_') && !key.contains('team1') && !key.contains('team2');
    }).toList();

    var slotEntries = vars.entries.where((e) {
      final key = e.key.toLowerCase();
      return key.contains('team_') || key.contains('team1') || key.contains('team2');
    }).toList();

    if (_searchQuery.isNotEmpty) {
      slotEntries = slotEntries.where((e) {
        final label = e.key.toLowerCase();
        final val = e.value.toLowerCase();
        return label.contains(_searchQuery) || val.contains(_searchQuery);
      }).toList();
    }

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            color: AppColors.cardBackground,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('General Info (${generalEntries.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Slot Teams (${slotEntries.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: General Match Info
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
    return _VariableFieldCardInput(
      key: ValueKey('${templateId}_${entry.key}'),
      variableKey: entry.key,
      value: entry.value,
      onChanged: (val) => notifier.updateVariable(entry.key, val),
    );
  }
}

class _VariableFieldCardInput extends StatefulWidget {
  final String variableKey;
  final String value;
  final ValueChanged<String> onChanged;

  const _VariableFieldCardInput({
    super.key,
    required this.variableKey,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_VariableFieldCardInput> createState() => _VariableFieldCardInputState();
}

class _VariableFieldCardInputState extends State<_VariableFieldCardInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _VariableFieldCardInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelName = widget.variableKey
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
                  widget.variableKey,
                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
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
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
