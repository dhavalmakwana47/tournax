import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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

class _SlotListGeneratorPageState extends ConsumerState<SlotListGeneratorPage> {
  final GlobalKey _exportBoundaryKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

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
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) async {
    if (state.selectedTemplate == null) return;
    if (state.totalPages <= 1) {
      await _downloadGraphic(state.selectedTemplate!);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Export Options',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${widget.match.teams.length} teams across ${state.totalPages} template pages',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadAllPages(state, notifier);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.collections_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export All ${state.totalPages} Pages',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Saves all pages to your gallery as PNG files',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadGraphic(state.selectedTemplate!);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.image_rounded, color: AppColors.textPrimary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Page ${state.currentPageIndex + 1} Only',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Saves visible graphic for Teams ${(state.currentPageIndex * state.slotsPerPage) + 1}-${((state.currentPageIndex + 1) * state.slotsPerPage).clamp(1, widget.match.teams.length)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAllPages(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) async {
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

        final boundary =
            _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) continue;

        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) continue;

        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final String fileName =
            'SlotList_${widget.match.id}_Page${pageIdx + 1}_${DateTime.now().millisecondsSinceEpoch}';

        if (!kIsWeb) {
          await Gal.putImageBytes(pngBytes, name: fileName);
        }
        savedCount++;
      }

      notifier.selectPage(originalPageIndex);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saved all $savedCount pages to Phone Gallery!',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            behavior: SnackBarBehavior.floating,
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

      final boundary =
          _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Render boundary not initialized');

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to capture PNG byte data');

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final String fileName =
          'SlotList_${widget.match.id}_${DateTime.now().millisecondsSinceEpoch}';

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
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Graphic saved to Gallery!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _handleShare(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) async {
    if (state.selectedTemplate == null || _isSharing) return;

    setState(() => _isSharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary =
          _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Render boundary not initialized');

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to capture PNG byte data');

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final String fileName =
          'SlotList_${widget.match.id}_Page${state.currentPageIndex + 1}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.tournament.name} - ${widget.group.name} Slot List Graphic',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(slotListGeneratorControllerProvider);
    final notifier = ref.read(slotListGeneratorControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildHeaderBar(context, state, notifier),
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                  SizedBox(height: 16),
                  Text(
                    'Loading Graphic Engine...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Invisible Offscreen RepaintBoundary overlay for full-res capture
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

                // Main Interactive Viewport & Controller Interface
                Column(
                  children: [
                    // Horizontal Studio Template Selector Dock
                    _buildTemplateSelectorDock(state, notifier),

                    // Multi-Page Floating Dock (if multi-page graphic)
                    if (state.totalPages > 1) _buildMultiPageDock(state, notifier),

                    // Live Studio Stage & Graphic Preview Viewport
                    Expanded(
                      flex: 5,
                      child: _buildLivePreviewStage(state),
                    ),

                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppColors.cardBorder, Colors.transparent],
                        ),
                      ),
                    ),

                    // Categorized Interactive Editor Studio (Bottom Half)
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

  Widget _buildHeaderBar(
    BuildContext context,
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF101522),
        border: Border(bottom: BorderSide(color: Color(0xFF1C2436), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'Slot Generator',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.match.name ?? 'Match ${widget.match.matchNumber}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                ),
                tooltip: 'Share Graphic',
                icon: _isSharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 18),
                onPressed: (_isSharing || state.selectedTemplate == null)
                    ? null
                    : () => _handleShare(state, notifier),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF8800)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: (_isDownloading || state.selectedTemplate == null)
                      ? null
                      : () => _handleDownload(state, notifier),
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                  label: Text(
                    _isDownloading
                        ? 'Saving...'
                        : (state.totalPages > 1 ? 'Export (${state.totalPages}P)' : 'Export'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelectorDock(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) {
    if (state.templates.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF0F1420),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: state.templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tpl = state.templates[index];
          final isSelected = tpl.id == state.selectedTemplate?.id;

          return InkWell(
            onTap: () => notifier.selectTemplate(tpl),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : const Color(0xFF161D2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white10,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.grid_view_rounded : Icons.crop_original_rounded,
                    size: 14,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tpl.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMultiPageDock(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) {
    final int current1Based = state.currentPageIndex + 1;
    final int startTeam = (state.currentPageIndex * state.slotsPerPage) + 1;
    final int endTeam =
        (startTeam + state.slotsPerPage - 1).clamp(1, widget.match.teams.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: const Color(0xFF090D14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.collections_bookmark_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Multi-Page Graphic',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: state.currentPageIndex > 0
                ? () => notifier.selectPage(state.currentPageIndex - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$current1Based / ${state.totalPages}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: state.currentPageIndex < state.totalPages - 1
                ? AppColors.textPrimary
                : Colors.white24,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: state.currentPageIndex < state.totalPages - 1
                ? () => notifier.selectPage(state.currentPageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewStage(SlotListGeneratorState state) {
    if (state.selectedTemplate == null) {
      return const Center(
        child: Text(
          'No template selected',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
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
          color: const Color(0xFF070A11),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.all(40),
                      clipBehavior: Clip.none,
                      child: Center(
                        child: Container(
                          width: targetW,
                          height: targetH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 16,
                                spreadRadius: 4,
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
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          tooltip: 'Reset Zoom',
                          icon: const Icon(Icons.center_focus_strong_rounded, color: Colors.white70, size: 18),
                          onPressed: () {
                            _transformationController.value = Matrix4.identity();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Canvas: ${spec.width.toInt()} × ${spec.height.toInt()} (${state.selectedTemplate!.name})',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (state.totalPages > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PAGE ${state.currentPageIndex + 1}/${state.totalPages}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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

  Widget _buildCategorizedEditorPanel(
    SlotListGeneratorState state,
    SlotListGeneratorController notifier,
  ) {
    final vars = state.currentVariables;

    const allowedKeysOrder = [
      '{{tournament_name}}',
      '{{group_name}}',
      '{{match_name}}',
      '{{date}}',
      '{{organizer_name}}',
      '{{organizer_logo}}',
      '{{sponsor_logo}}',
    ];

    final generalEntries = <MapEntry<String, String>>[];
    for (final key in allowedKeysOrder) {
      generalEntries.add(MapEntry(key, vars[key] ?? ''));
    }

    return Container(
      color: const Color(0xFF0F1420),
      child: Column(
        children: [
          // Studio Editor Header
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF131A2A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E283C), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Graphic Details (${generalEntries.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Reset defaults',
                  icon: const Icon(Icons.restart_alt_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: () => notifier.resetVariablesToDefaults(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _buildSlotPrefixCard(state.slotPrefix, notifier),
                const SizedBox(height: 8),
                ...generalEntries.map(
                  (entry) => _buildGeneralFieldCard(
                    entry,
                    state.selectedTemplate?.id,
                    notifier,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotPrefixCard(String prefix, SlotListGeneratorController notifier) {
    return _SlotPrefixInputCard(
      initialPrefix: prefix,
      onChanged: (val) => notifier.updateSlotPrefix(val),
    );
  }

  Widget _buildGeneralFieldCard(
    MapEntry<String, String> entry,
    String? templateId,
    SlotListGeneratorController notifier,
  ) {
    return _VariableFieldCardInput(
      key: ValueKey('${templateId}_${entry.key}'),
      variableKey: entry.key,
      value: entry.value,
      slotNumber: null,
      onChanged: (val) => notifier.updateVariable(entry.key, val),
    );
  }
}

class _VariableFieldCardInput extends StatefulWidget {
  final String variableKey;
  final String value;
  final int? slotNumber;
  final ValueChanged<String> onChanged;

  const _VariableFieldCardInput({
    super.key,
    required this.variableKey,
    required this.value,
    this.slotNumber,
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
    final cleanLabel = widget.variableKey
        .replaceAll('{{', '')
        .replaceAll('}}', '')
        .replaceAll('_', ' ')
        .toUpperCase();

    final isSlot = widget.slotNumber != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141C2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E2A40)),
        ),
        child: Row(
          children: [
            if (isSlot) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${widget.slotNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSlot ? 'SLOT ${widget.slotNumber} TEAM NAME' : cleanLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 34,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF0F1522),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFF223049)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFF223049)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: widget.onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotPrefixInputCard extends StatefulWidget {
  final String initialPrefix;
  final ValueChanged<String> onChanged;

  const _SlotPrefixInputCard({
    required this.initialPrefix,
    required this.onChanged,
  });

  @override
  State<_SlotPrefixInputCard> createState() => _SlotPrefixInputCardState();
}

class _SlotPrefixInputCardState extends State<_SlotPrefixInputCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPrefix);
  }

  @override
  void didUpdateWidget(covariant _SlotPrefixInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPrefix != widget.initialPrefix && !_focusNode.hasFocus) {
      _controller.text = widget.initialPrefix;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.label_rounded, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'SLOT PREFIX',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(Adds prefix before dynamic {{slot}} e.g. "SLOT #")',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. SLOT #, S-, SLOT ',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF0F1522),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF223049)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF223049)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
