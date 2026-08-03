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
import '../../../../core/routes/route_args.dart';
import '../../../tournament/domain/entities/tournament_entity.dart';
import '../../../tournament/domain/entities/leaderboard_item_entity.dart';
import '../../domain/models/template_model.dart';
import '../controller/leaderboard_generator_controller.dart';
import '../renderer/template_renderer.dart';

class LeaderboardGeneratorPage extends ConsumerStatefulWidget {
  final TournamentEntity tournament;
  final LeaderboardArgs args;
  final List<LeaderboardItemEntity> items;

  const LeaderboardGeneratorPage({
    super.key,
    required this.tournament,
    required this.args,
    this.items = const [],
  });

  @override
  ConsumerState<LeaderboardGeneratorPage> createState() => _LeaderboardGeneratorPageState();
}

class _LeaderboardGeneratorPageState extends ConsumerState<LeaderboardGeneratorPage> {
  final GlobalKey _exportBoundaryKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardGeneratorControllerProvider.notifier).init(
            tournament: widget.tournament,
            args: widget.args,
            initialItems: widget.items,
          );
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Options',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'This leaderboard spans ${state.totalPages} pages',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.description_outlined, color: Colors.white70),
                  ),
                  title: Text(
                    'Current Page (Page ${state.currentPageIndex + 1})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Save only the active graphic shown on screen',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _downloadGraphic(state.selectedTemplate!);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.collections_outlined, color: AppColors.primary),
                  ),
                  title: Text(
                    'All ${state.totalPages} Pages',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Export & save graphics for all pages to Gallery',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _downloadAllPages(state, notifier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleShare(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
  ) async {
    if (state.selectedTemplate == null || _isSharing) return;

    if (state.totalPages <= 1) {
      await _shareGraphic(state.selectedTemplate!);
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share Options',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'This leaderboard spans ${state.totalPages} pages',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.image_outlined, color: Colors.white70),
                  ),
                  title: Text(
                    'Current Page (Page ${state.currentPageIndex + 1})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Share only the visible active graphic',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareGraphic(state.selectedTemplate!);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.grid_on_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    'All ${state.totalPages} Pages',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Export & share graphics for all pages together',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareAllPages(state, notifier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardGeneratorControllerProvider);
    final notifier = ref.read(leaderboardGeneratorControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111622),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Leaderboard Studio',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${widget.tournament.name} • ${widget.args.name}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share Graphic',
            icon: _isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.share_rounded, color: AppColors.primary, size: 22),
            onPressed: (_isSharing || state.selectedTemplate == null)
                ? null
                : () => _handleShare(state, notifier),
          ),
          IconButton(
            tooltip: 'Download Graphic',
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white, size: 24),
            onPressed: (_isDownloading || state.selectedTemplate == null)
                ? null
                : () => _handleDownload(state, notifier),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Horizontal Studio Template Selector Dock
                _buildTemplateSelectorDock(state, notifier),

                // Top Page Switcher (if multi-page)
                if (state.totalPages > 1)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF161C2C),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                          onPressed: state.currentPageIndex > 0
                              ? () => notifier.setPage(state.currentPageIndex - 1)
                              : null,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.pages_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'PAGE ${state.currentPageIndex + 1} OF ${state.totalPages}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          onPressed: state.currentPageIndex < state.totalPages - 1
                              ? () => notifier.setPage(state.currentPageIndex + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),

                // Main Interactive Canvas Preview Area (Top Half)
                Expanded(
                  flex: 5,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.3,
                    maxScale: 3.5,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: RepaintBoundary(
                            key: _exportBoundaryKey,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Builder(
                                builder: (ctx) {
                                  if (state.selectedTemplate != null) {
                                    return SizedBox(
                                      width: state.selectedTemplate!.canvasSpec.width,
                                      height: state.selectedTemplate!.canvasSpec.height,
                                      child: TemplateRenderer(
                                        template: state.selectedTemplate!,
                                        overrideVariables: state.currentVariables,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.cardBorder, Colors.transparent],
                    ),
                  ),
                ),

                // Graphic Details & Tag Replace Editor Panel (Bottom Half)
                Expanded(
                  flex: 5,
                  child: _buildCategorizedEditorPanel(state, notifier),
                ),
              ],
            ),
    );
  }

  Widget _buildTemplateSelectorDock(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
  ) {
    if (state.templates.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFF111622),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SELECT GRAPHIC TEMPLATE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${state.templates.length} Available',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: state.templates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final tpl = state.templates[index];
                final isSelected = tpl.id == state.selectedTemplate?.id;

                return GestureDetector(
                  onTap: () => notifier.selectTemplate(tpl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : const Color(0xFF1A2234),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tpl.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tpl.canvasSpec.width.toInt()}×${tpl.canvasSpec.height.toInt()} • ${tpl.category}',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadGraphic(TemplateModel template) async {
    setState(() => _isDownloading = true);
    try {
      final imageBytes = await _captureCanvasBytes();
      if (imageBytes == null) {
        throw Exception('Failed to render canvas image boundary.');
      }

      await Gal.putImageBytes(
        imageBytes,
        name: 'Leaderboard_${widget.args.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Leaderboard graphic saved to Gallery!'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save graphic: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _downloadAllPages(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
  ) async {
    setState(() => _isDownloading = true);
    final initialPage = state.currentPageIndex;

    try {
      int savedCount = 0;
      for (int i = 0; i < state.totalPages; i++) {
        notifier.setPage(i);
        await Future.delayed(const Duration(milliseconds: 300));

        final imageBytes = await _captureCanvasBytes();
        if (imageBytes != null) {
          await Gal.putImageBytes(
            imageBytes,
            name: 'Leaderboard_${widget.args.name.replaceAll(' ', '_')}_P${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
          );
          savedCount++;
        }
      }

      notifier.setPage(initialPage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Successfully saved $savedCount page graphics to Gallery!'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving page graphics: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareGraphic(TemplateModel template) async {
    setState(() => _isSharing = true);
    try {
      final imageBytes = await _captureCanvasBytes();
      if (imageBytes == null) {
        throw Exception('Failed to render canvas image for sharing.');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Leaderboard_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Leaderboard: ${widget.args.name} (${widget.tournament.name})',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share graphic: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAllPages(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
  ) async {
    setState(() => _isSharing = true);
    final initialPage = state.currentPageIndex;

    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> shareFiles = [];

      for (int i = 0; i < state.totalPages; i++) {
        notifier.setPage(i);
        await Future.delayed(const Duration(milliseconds: 300));

        final imageBytes = await _captureCanvasBytes();
        if (imageBytes != null) {
          final file = File('${tempDir.path}/Leaderboard_P${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(imageBytes);
          shareFiles.add(XFile(file.path));
        }
      }

      notifier.setPage(initialPage);

      if (shareFiles.isNotEmpty) {
        await Share.shareXFiles(
          shareFiles,
          text: 'Leaderboard (${state.totalPages} Pages): ${widget.args.name} (${widget.tournament.name})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing page graphics: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Widget _buildCategorizedEditorPanel(
    LeaderboardGeneratorState state,
    LeaderboardGeneratorController notifier,
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
              children: generalEntries.map(
                (entry) => _buildGeneralFieldCard(
                  entry,
                  state.selectedTemplate?.id,
                  notifier,
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralFieldCard(
    MapEntry<String, String> entry,
    String? templateId,
    LeaderboardGeneratorController notifier,
  ) {
    return _VariableFieldCardInput(
      key: ValueKey('${templateId}_${entry.key}'),
      variableKey: entry.key,
      value: entry.value,
      onChanged: (val) => notifier.updateVariable(entry.key, val),
    );
  }

  Future<Uint8List?> _captureCanvasBytes() async {
    try {
      final boundary = _exportBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing canvas bytes: $e');
      return null;
    }
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

  String _cleanLabel(String key) {
    String clean = key.replaceAll('{{', '').replaceAll('}}', '');
    clean = clean.replaceAll('_', ' ');
    return clean.toUpperCase();
  }

  IconData _getIconForKey(String key) {
    final clean = key.toLowerCase();
    if (clean.contains('tournament')) return Icons.emoji_events_outlined;
    if (clean.contains('title') || clean.contains('header')) return Icons.title_rounded;
    if (clean.contains('group')) return Icons.groups_outlined;
    if (clean.contains('date')) return Icons.calendar_today_rounded;
    if (clean.contains('organizer')) return Icons.business_center_outlined;
    if (clean.contains('sponsor') || clean.contains('logo')) return Icons.verified_outlined;
    return Icons.text_fields_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final label = _cleanLabel(widget.variableKey);
    final icon = _getIconForKey(widget.variableKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E283C)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Enter $label...',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white30),
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
              },
            ),
        ],
      ),
    );
  }
}
