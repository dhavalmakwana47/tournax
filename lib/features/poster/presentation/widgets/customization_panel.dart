import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/poster_customization_model.dart';
import '../../data/models/poster_theme_model.dart';
import '../controller/poster_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tournament/domain/entities/match_entity.dart';

class CustomizationPanel extends ConsumerStatefulWidget {
  const CustomizationPanel({
    super.key,
    required this.match,
  });

  final MatchEntity match;

  @override
  ConsumerState<CustomizationPanel> createState() => _CustomizationPanelState();
}

class _CustomizationPanelState extends ConsumerState<CustomizationPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickEventLogo(PosterController notifier) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        notifier.updateEventLogo(file.path);
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
    }
  }

  Future<void> _pickBackground(PosterController notifier) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        notifier.updateCustomBg(file.path);
      }
    } catch (e) {
      debugPrint('Error picking background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posterControllerProvider(widget.match));
    final notifier = ref.read(posterControllerProvider(widget.match).notifier);
    final customization = state.customization;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Details', icon: Icon(Icons.edit_note_rounded)),
              Tab(text: 'Style', icon: Icon(Icons.palette_outlined)),
              Tab(text: 'Background', icon: Icon(Icons.wallpaper_rounded)),
            ],
          ),
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(customization, notifier),
                _buildStyleTab(state, notifier),
                _buildBackgroundTab(customization, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(PosterCustomizationModel customization, PosterController notifier) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Event Logo
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event Logo', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    customization.eventLogoPath != null ? 'Custom logo selected' : 'Default logo active',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (customization.eventLogoPath != null)
              TextButton(
                onPressed: () => notifier.updateEventLogo(null),
                child: const Text('Remove', style: TextStyle(color: AppColors.error)),
              ),
            ElevatedButton.icon(
              onPressed: () => _pickEventLogo(notifier),
              icon: const Icon(Icons.image_search_rounded, size: 16),
              label: const Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Text input fields
        _buildTextField(
          label: 'Event Name',
          initialValue: customization.eventName,
          onChanged: notifier.updateEventName,
        ),
        _buildTextField(
          label: 'Organiser Name',
          initialValue: customization.organizerName,
          onChanged: notifier.updateOrganizerName,
        ),
        _buildTextField(
          label: 'Subtitle Banner',
          initialValue: customization.subTitle,
          onChanged: notifier.updateSubTitle,
        ),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Week Label',
                initialValue: customization.week,
                onChanged: notifier.updateWeek,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                label: 'Round Label',
                initialValue: customization.round,
                onChanged: notifier.updateRound,
              ),
            ),
          ],
        ),

        _buildTextField(
          label: 'Watermark Credits',
          initialValue: customization.watermark,
          onChanged: notifier.updateWatermark,
        ),

        // Social Handles
        const SizedBox(height: AppSpacing.sm),
        const Text('Social Medias', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Instagram username',
                initialValue: customization.socialLinks['instagram'] ?? '',
                onChanged: (v) => notifier.updateSocialLink('instagram', v),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTextField(
                label: 'YouTube channel name',
                initialValue: customization.socialLinks['youtube'] ?? '',
                onChanged: (v) => notifier.updateSocialLink('youtube', v),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStyleTab(PosterState state, PosterController notifier) {
    final customization = state.customization;
    final fontOptions = ['Bebas Neue', 'Anton', 'Oswald', 'Montserrat', 'Poppins'];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Predefined Themes Selector
        const Text('Esports Theme Preset', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.themes.length,
            itemBuilder: (context, idx) {
              final t = state.themes[idx];
              final isSelected = state.selectedTheme.name == t.name;

              return GestureDetector(
                onTap: () => notifier.selectTheme(t),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? t.primaryColor.withValues(alpha: 0.2) : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? t.primaryColor : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: t.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.name,
                        style: TextStyle(
                          color: isSelected ? t.primaryColor : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Fonts Selector
        const Text('Typography (Google Fonts)', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: fontOptions.contains(customization.fontFamily) ? customization.fontFamily : fontOptions.first,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Select Typography'),
          items: fontOptions
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f, style: TextStyle(fontWeight: FontWeight.bold)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.updateFontFamily(v);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Color override custom picker simulation
        const Text('Custom Accent override', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCustomColorBox(
                label: 'Primary',
                currentColor: customization.primaryColorOverride ?? state.selectedTheme.primaryColor,
                onSelect: (color) => notifier.updateColors(color, customization.secondaryColorOverride),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomColorBox(
                label: 'Secondary',
                currentColor: customization.secondaryColorOverride ?? state.selectedTheme.secondaryColor,
                onSelect: (color) => notifier.updateColors(customization.primaryColorOverride, color),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCustomColorBox({
    required String label,
    required Color currentColor,
    required Function(Color) onSelect,
  }) {
    final list = [
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.purple,
      Colors.yellow,
      Colors.orange,
      Colors.white,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: list.map((color) {
              final isSame = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSame ? Colors.amber : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildBackgroundTab(PosterCustomizationModel customization, PosterController notifier) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Custom background file upload
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Custom Backdrop', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    customization.customBgPath != null ? 'Custom graphic uploaded' : 'Using Template Backdrop',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (customization.customBgPath != null)
              TextButton(
                onPressed: () => notifier.updateCustomBg(null),
                child: const Text('Clear', style: TextStyle(color: AppColors.error)),
              ),
            ElevatedButton.icon(
              onPressed: () => _pickBackground(notifier),
              icon: const Icon(Icons.wallpaper_rounded, size: 16),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Sliders
        _buildSlider(
          label: 'Background Blur Intensity',
          value: customization.blurAmountOverride ?? 0.0,
          min: 0.0,
          max: 10.0,
          onChanged: notifier.updateBlurAmount,
        ),
        _buildSlider(
          label: 'Background Image Opacity',
          value: customization.opacity,
          min: 0.0,
          max: 1.0,
          onChanged: notifier.updateOpacity,
        ),
        _buildSlider(
          label: 'Dark Overlay Shadow Tint',
          value: customization.darkOverlayOpacity,
          min: 0.0,
          max: 1.0,
          onChanged: notifier.updateDarkOverlayOpacity,
        ),

        // Gradient overlay toggle
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            title: const Text('Linear Gradient Overlay', style: AppTextStyles.bodyMedium),
            value: customization.showGradientOverlay,
            activeColor: AppColors.primary,
            onChanged: notifier.updateShowGradientOverlay,
          ),
        )
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(value.toStringAsFixed(1), style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.divider,
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );
}
