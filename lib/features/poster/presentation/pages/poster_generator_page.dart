import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/poster_template_model.dart';
import '../../data/services/export_service.dart';
import '../controller/poster_controller.dart';
import '../widgets/customization_panel.dart';
import '../widgets/poster_preview_widget.dart';
import '../../../widgets/presentation/controller/dynamic_widget_controller.dart';
import '../../../widgets/presentation/renderers/dynamic_slot_list_renderer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tournament/domain/entities/match_entity.dart';

class PosterGeneratorPage extends ConsumerStatefulWidget {
  const PosterGeneratorPage({
    super.key,
    required this.match,
  });

  final MatchEntity match;

  @override
  ConsumerState<PosterGeneratorPage> createState() => _PosterGeneratorPageState();
}

class _PosterGeneratorPageState extends ConsumerState<PosterGeneratorPage> {
  final GlobalKey _repaintKey = GlobalKey();
  final ExportService _exportService = ExportService();
  late PageController _carouselController;

  String _filterType = 'Free'; // 'Free', 'Premium', 'Custom'

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.72, initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dynamicWidgetControllerProvider.notifier).fetchTemplates();
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _openCustomizationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CustomizationPanel(match: widget.match),
      ),
    );
  }

  Future<void> _exportPoster(bool share) async {
    final notifier = ref.read(posterControllerProvider(widget.match).notifier);
    notifier.setExporting(true);

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // Short delay to ensure repaint boundary is fully updated
      await Future.delayed(const Duration(milliseconds: 300));

      final file = await _exportService.capturePng(
        repaintKey: _repaintKey,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading spinner

      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to render poster.'),
            backgroundColor: AppColors.error,
          ),
        );
        notifier.setExporting(false);
        return;
      }

      if (share) {
        await _exportService.sharePoster(file);
      } else {
        final success = await _exportService.saveToGallery(file);
        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poster saved to gallery successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Fallback message showing path if save fails on some devices without permissions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to app folder: ${file.path.split('/').last}'),
              action: SnackBarAction(
                label: 'SHARE',
                textColor: AppColors.primary,
                onPressed: () => _exportService.sharePoster(file),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('Export error: $e');
    } finally {
      notifier.setExporting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posterControllerProvider(widget.match));
    final dynamicState = ref.watch(dynamicWidgetControllerProvider);
    final dynamicNotifier = ref.read(dynamicWidgetControllerProvider.notifier);

    // Apply dynamic category filter on server templates
    final serverTemplates = dynamicState.templates;
    final selectedCategorySlug = dynamicState.selectedCategorySlug;

    final filteredTemplates = serverTemplates.where((t) {
      if (selectedCategorySlug == 'all') return true;
      if (selectedCategorySlug == 'premium') return t.isPremium;
      if (selectedCategorySlug == 'free') return !t.isPremium;
      return t.category.toLowerCase() == selectedCategorySlug.toLowerCase();
    }).toList();

    final selectedTemplate = dynamicState.selectedTemplate;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Slot list', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Color / Background sheet quick triggers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _openCustomizationSheet,
                    icon: const Icon(Icons.palette_outlined, size: 16),
                    label: const Text('Color'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _openCustomizationSheet,
                    icon: const Icon(Icons.wallpaper_rounded, size: 16),
                    label: const Text('Background'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Zoomable Interactive Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (selectedTemplate?.theme.primaryColor ?? AppColors.primary)
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.0,
                    child: Builder(
                      builder: (context) {
                        if (dynamicState.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }
                        if (selectedTemplate != null) {
                          return DynamicSlotListRenderer(
                            repaintKey: _repaintKey,
                            template: selectedTemplate,
                            customization: state.customization,
                            match: state.match,
                          );
                        }
                        return PosterPreviewWidget(
                          repaintKey: _repaintKey,
                          customization: state.customization,
                          template: state.selectedTemplate,
                          theme: state.selectedTheme,
                          match: state.match,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal snaps server templates carousel
            const SizedBox(height: 8),
            SizedBox(
              height: 96,
              child: filteredTemplates.isEmpty
                  ? Center(
                      child: Text(
                        dynamicState.isLoading
                            ? 'Loading server templates...'
                            : 'No templates available in this category',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    )
                  : PageView.builder(
                      controller: _carouselController,
                      itemCount: filteredTemplates.length,
                      onPageChanged: (index) {
                        dynamicNotifier.selectTemplate(filteredTemplates[index]);
                        ref.read(posterControllerProvider(widget.match).notifier).resetColorOverrides();
                      },
                      itemBuilder: (context, index) {
                        final t = filteredTemplates[index];
                        final isSelected = selectedTemplate?.slug == t.slug;

                        return AnimatedScale(
                          scale: isSelected ? 1.0 : 0.88,
                          duration: const Duration(milliseconds: 250),
                          child: GestureDetector(
                            onTap: () {
                              _carouselController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                              dynamicNotifier.selectTemplate(t);
                              ref.read(posterControllerProvider(widget.match).notifier).resetColorOverrides();
                            },
                            child: Hero(
                              tag: 'template_${t.slug}',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? t.theme.primaryColor
                                        : AppColors.divider,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (t.assets.containsKey('background'))
                                        Image.network(
                                          t.assets['background']!.url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: t.theme.backgroundColor,
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [t.theme.backgroundColor, Colors.black],
                                            ),
                                          ),
                                          child: const Icon(Icons.color_lens_outlined, color: Colors.white24, size: 36),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Text(
                                            t.name,
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Dynamic Server Categories Selector
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildCategoryChip(
                    label: 'All',
                    slug: 'all',
                    isSelected: dynamicState.selectedCategorySlug == 'all',
                    onTap: () {
                      dynamicNotifier.selectCategory('all');
                      ref.read(posterControllerProvider(widget.match).notifier).resetColorOverrides();
                    },
                  ),
                  ...dynamicState.categories.map((cat) {
                    final isSelected = dynamicState.selectedCategorySlug.toLowerCase() == cat.slug.toLowerCase();
                    return _buildCategoryChip(
                      label: cat.name,
                      slug: cat.slug,
                      isSelected: isSelected,
                      onTap: () {
                        dynamicNotifier.selectCategory(cat.slug);
                        ref.read(posterControllerProvider(widget.match).notifier).resetColorOverrides();
                      },
                    );
                  }),
                ],
              ),
            ),

            // Action Export Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _exportPoster(false),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _exportPoster(true),
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.all(14),
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

  Widget _buildCategoryChip({
    required String label,
    required String slug,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white38,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
