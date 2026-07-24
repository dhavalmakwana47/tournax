class WidgetLayoutModel {
  final double aspectRatio;
  final int upTo16SlotsColumns;
  final int upTo24SlotsColumns;
  final int upTo32SlotsColumns;
  final double cardHeight;
  final double cardBorderRadius;
  final double cardBorderWidth;
  final double headerHeight;
  final double footerHeight;
  final double blurSigmaX;
  final double blurSigmaY;
  final bool blurEnabled;
  final double darkOverlayOpacity;
  final bool gradientEnabled;

  const WidgetLayoutModel({
    this.aspectRatio = 1.0,
    this.upTo16SlotsColumns = 2,
    this.upTo24SlotsColumns = 2,
    this.upTo32SlotsColumns = 3,
    this.cardHeight = 38.0,
    this.cardBorderRadius = 6.0,
    this.cardBorderWidth = 1.0,
    this.headerHeight = 70.0,
    this.footerHeight = 30.0,
    this.blurSigmaX = 8.0,
    this.blurSigmaY = 8.0,
    this.blurEnabled = true,
    this.darkOverlayOpacity = 0.45,
    this.gradientEnabled = true,
  });

  factory WidgetLayoutModel.fromJson(Map<String, dynamic> json) {
    final cols = json['columns_rule'] as Map<String, dynamic>? ?? {};
    final blur = json['blur_effect'] as Map<String, dynamic>? ?? {};
    final overlay = json['overlay'] as Map<String, dynamic>? ?? {};

    return WidgetLayoutModel(
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
      upTo16SlotsColumns: (cols['up_to_16_slots'] as num?)?.toInt() ?? 2,
      upTo24SlotsColumns: (cols['up_to_24_slots'] as num?)?.toInt() ?? 2,
      upTo32SlotsColumns: (cols['up_to_32_slots'] as num?)?.toInt() ?? 3,
      cardHeight: (json['card_height'] as num?)?.toDouble() ?? 38.0,
      cardBorderRadius: (json['card_border_radius'] as num?)?.toDouble() ?? 6.0,
      cardBorderWidth: (json['card_border_width'] as num?)?.toDouble() ?? 1.0,
      headerHeight: (json['header_height'] as num?)?.toDouble() ?? 70.0,
      footerHeight: (json['footer_height'] as num?)?.toDouble() ?? 30.0,
      blurSigmaX: (blur['sigma_x'] as num?)?.toDouble() ?? 8.0,
      blurSigmaY: (blur['sigma_y'] as num?)?.toDouble() ?? 8.0,
      blurEnabled: blur['enabled'] as bool? ?? true,
      darkOverlayOpacity: (overlay['dark_opacity'] as num?)?.toDouble() ?? 0.45,
      gradientEnabled: overlay['gradient_enabled'] as bool? ?? true,
    );
  }
}
