import 'package:flutter/material.dart';
import 'enums.dart';

Color parseColor(int hex) {
  if (hex == 0) return const Color(0x00000000);
  final int a = (hex >> 24) & 0xFF;
  final int r = (hex >> 16) & 0xFF;
  final int g = (hex >> 8) & 0xFF;
  final int b = hex & 0xFF;
  final int alpha = (a == 0 && (r != 0 || g != 0 || b != 0)) ? 255 : a;
  return Color.fromARGB(alpha, r, g, b);
}

/// Styling attributes applied to a layer.
class LayerStyle {
  final int fillColorHex;
  final bool isGradientFill;
  final List<int> gradientColorsHex;
  final List<double> gradientStops;
  final double gradientAngle; // In degrees
  final int borderColorHex;
  final double borderWidth;
  final double borderRadius;
  final int shadowColorHex;
  final double shadowDx;
  final double shadowDy;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final double opacity; // 0.0 to 1.0
  final BlendMode blendMode;
  final double padding;
  final double margin;

  // Text specific styles
  final String fontFamily;
  final double fontSize;
  final int fontWeightValue; // 100 to 900
  final bool isItalic;
  final bool isUnderline;
  final int textColorHex;
  final double letterSpacing;
  final double wordSpacing;
  final double lineHeight;
  final double textStrokeWidth;
  final int textStrokeColorHex;
  final TextAlign textAlign;
  final TextTransformMode textTransform;

  const LayerStyle({
    this.fillColorHex = 0xFF3B82F6,
    this.isGradientFill = false,
    this.gradientColorsHex = const [0xFF3B82F6, 0xFF8B5CF6],
    this.gradientStops = const [0.0, 1.0],
    this.gradientAngle = 45.0,
    this.borderColorHex = 0x00000000,
    this.borderWidth = 0.0,
    this.borderRadius = 0.0,
    this.shadowColorHex = 0x40000000,
    this.shadowDx = 0.0,
    this.shadowDy = 4.0,
    this.shadowBlurRadius = 10.0,
    this.shadowSpreadRadius = 0.0,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
    this.padding = 0.0,
    this.margin = 0.0,
    this.fontFamily = 'Inter',
    this.fontSize = 24.0,
    this.fontWeightValue = 600,
    this.isItalic = false,
    this.isUnderline = false,
    this.textColorHex = 0xFFFFFFFF,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.lineHeight = 1.2,
    this.textStrokeWidth = 0.0,
    this.textStrokeColorHex = 0xFF000000,
    this.textAlign = TextAlign.left,
    this.textTransform = TextTransformMode.none,
  });

  LayerStyle copyWith({
    int? fillColorHex,
    bool? isGradientFill,
    List<int>? gradientColorsHex,
    List<double>? gradientStops,
    double? gradientAngle,
    int? borderColorHex,
    double? borderWidth,
    double? borderRadius,
    int? shadowColorHex,
    double? shadowDx,
    double? shadowDy,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? opacity,
    BlendMode? blendMode,
    double? padding,
    double? margin,
    String? fontFamily,
    double? fontSize,
    int? fontWeightValue,
    bool? isItalic,
    bool? isUnderline,
    int? textColorHex,
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    double? textStrokeWidth,
    int? textStrokeColorHex,
    TextAlign? textAlign,
    TextTransformMode? textTransform,
  }) {
    return LayerStyle(
      fillColorHex: fillColorHex ?? this.fillColorHex,
      isGradientFill: isGradientFill ?? this.isGradientFill,
      gradientColorsHex: gradientColorsHex ?? this.gradientColorsHex,
      gradientStops: gradientStops ?? this.gradientStops,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColorHex: shadowColorHex ?? this.shadowColorHex,
      shadowDx: shadowDx ?? this.shadowDx,
      shadowDy: shadowDy ?? this.shadowDy,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeightValue: fontWeightValue ?? this.fontWeightValue,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      textColorHex: textColorHex ?? this.textColorHex,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      textStrokeWidth: textStrokeWidth ?? this.textStrokeWidth,
      textStrokeColorHex: textStrokeColorHex ?? this.textStrokeColorHex,
      textAlign: textAlign ?? this.textAlign,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fillColorHex': fillColorHex,
      'isGradientFill': isGradientFill,
      'gradientColorsHex': gradientColorsHex,
      'gradientStops': gradientStops,
      'gradientAngle': gradientAngle,
      'borderColorHex': borderColorHex,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'shadowColorHex': shadowColorHex,
      'shadowDx': shadowDx,
      'shadowDy': shadowDy,
      'shadowBlurRadius': shadowBlurRadius,
      'shadowSpreadRadius': shadowSpreadRadius,
      'opacity': opacity,
      'blendMode': blendMode.index,
      'padding': padding,
      'margin': margin,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeightValue': fontWeightValue,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'textColorHex': textColorHex,
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      'lineHeight': lineHeight,
      'textStrokeWidth': textStrokeWidth,
      'textStrokeColorHex': textStrokeColorHex,
      'textAlign': textAlign.index,
      'textTransform': textTransform.index,
    };
  }

  static int _parseHex(dynamic val, int defaultVal) {
    if (val == null) return defaultVal;
    if (val is int) return val.toUnsigned(32);
    if (val is num) return val.toInt().toUnsigned(32);
    final str = val.toString().trim();
    if (str.isEmpty) return defaultVal;

    final parsedInt = int.tryParse(str);
    if (parsedInt != null) return parsedInt.toUnsigned(32);

    var cleanHex = str.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    if (cleanHex.length == 8) {
      final parsed = int.tryParse(cleanHex, radix: 16);
      if (parsed != null) return parsed.toUnsigned(32);
    }
    return defaultVal;
  }

  static TextAlign _parseTextAlign(dynamic val, [TextAlign defaultAlign = TextAlign.left]) {
    if (val == null) return defaultAlign;
    if (val is int) {
      return val >= 0 && val < TextAlign.values.length ? TextAlign.values[val] : defaultAlign;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < TextAlign.values.length ? TextAlign.values[i] : defaultAlign;
    }
    final str = val.toString().trim().toLowerCase();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < TextAlign.values.length ? TextAlign.values[parsedInt] : defaultAlign;
    }
    switch (str) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

  static BlendMode _parseBlendMode(dynamic val, [BlendMode defaultMode = BlendMode.srcOver]) {
    if (val == null) return defaultMode;
    if (val is int) {
      return val >= 0 && val < BlendMode.values.length ? BlendMode.values[val] : defaultMode;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < BlendMode.values.length ? BlendMode.values[i] : defaultMode;
    }
    final str = val.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < BlendMode.values.length ? BlendMode.values[parsedInt] : defaultMode;
    }
    final normalized = str.toLowerCase();
    for (final b in BlendMode.values) {
      if (b.name.toLowerCase() == normalized) return b;
    }
    return defaultMode;
  }

  static int _parseFontWeight(dynamic val, [int defaultVal = 600]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is num) return val.toInt();
    final str = val.toString().trim().toLowerCase();
    final parsed = int.tryParse(str);
    if (parsed != null) return parsed;
    if (str.contains('bold')) return 700;
    if (str.contains('light')) return 300;
    if (str.contains('medium')) return 500;
    if (str.contains('regular') || str.contains('normal')) return 400;
    if (str.contains('thin')) return 100;
    return defaultVal;
  }

  factory LayerStyle.fromJson(Map<dynamic, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);

    final dynamic rawGradColors = json['gradientColorsHex'] ?? json['gradient_colors_hex'] ?? json['gradientColors'] ?? json['gradient_colors'];
    List<int> colors = const [0xFF3B82F6, 0xFF8B5CF6];
    if (rawGradColors is List) {
      colors = rawGradColors.map((e) => _parseHex(e, 0xFFFFFFFF)).toList();
    }

    final dynamic rawGradStops = json['gradientStops'] ?? json['gradient_stops'];
    List<double> stops = const [0.0, 1.0];
    if (rawGradStops is List) {
      stops = rawGradStops.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
    }

    final fillVal = json['fillColorHex'] ?? json['fill_color_hex'] ?? json['fillColor'] ?? json['fill_color'];
    final borderVal = json['borderColorHex'] ?? json['border_color_hex'] ?? json['borderColor'] ?? json['border_color'];
    final shadowVal = json['shadowColorHex'] ?? json['shadow_color_hex'] ?? json['shadowColor'] ?? json['shadow_color'];
    final textVal = json['textColorHex'] ?? json['text_color_hex'] ?? json['textColor'] ?? json['text_color'];
    final textStrokeVal = json['textStrokeColorHex'] ?? json['text_stroke_color_hex'] ?? json['textStrokeColor'] ?? json['text_stroke_color'];

    return LayerStyle(
      fillColorHex: _parseHex(fillVal, 0xFF3B82F6),
      isGradientFill: (json['isGradientFill'] ?? json['is_gradient_fill']) as bool? ?? false,
      gradientColorsHex: colors,
      gradientStops: stops,
      gradientAngle: ((json['gradientAngle'] ?? json['gradient_angle']) as num?)?.toDouble() ?? 45.0,
      borderColorHex: _parseHex(borderVal, 0x00000000),
      borderWidth: ((json['borderWidth'] ?? json['border_width']) as num?)?.toDouble() ?? 0.0,
      borderRadius: ((json['borderRadius'] ?? json['border_radius']) as num?)?.toDouble() ?? 0.0,
      shadowColorHex: _parseHex(shadowVal, 0x40000000),
      shadowDx: ((json['shadowDx'] ?? json['shadow_dx']) as num?)?.toDouble() ?? 0.0,
      shadowDy: ((json['shadowDy'] ?? json['shadow_dy']) as num?)?.toDouble() ?? 4.0,
      shadowBlurRadius: ((json['shadowBlurRadius'] ?? json['shadow_blur_radius']) as num?)?.toDouble() ?? 10.0,
      shadowSpreadRadius: ((json['shadowSpreadRadius'] ?? json['shadow_spread_radius']) as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode: _parseBlendMode(json['blendMode'] ?? json['blend_mode']),
      padding: (json['padding'] as num?)?.toDouble() ?? 0.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
      fontFamily: (json['fontFamily'] ?? json['font_family'])?.toString() ?? 'Inter',
      fontSize: ((json['fontSize'] ?? json['font_size']) as num?)?.toDouble() ?? 24.0,
      fontWeightValue: _parseFontWeight(json['fontWeightValue'] ?? json['font_weight_value'] ?? json['fontWeight'] ?? json['font_weight']),
      isItalic: (json['isItalic'] ?? json['is_italic']) as bool? ?? false,
      isUnderline: (json['isUnderline'] ?? json['is_underline']) as bool? ?? false,
      textColorHex: _parseHex(textVal, 0xFFFFFFFF),
      letterSpacing: ((json['letterSpacing'] ?? json['letter_spacing']) as num?)?.toDouble() ?? 0.0,
      wordSpacing: ((json['wordSpacing'] ?? json['word_spacing']) as num?)?.toDouble() ?? 0.0,
      lineHeight: ((json['lineHeight'] ?? json['line_height']) as num?)?.toDouble() ?? 1.2,
      textStrokeWidth: ((json['textStrokeWidth'] ?? json['text_stroke_width']) as num?)?.toDouble() ?? 0.0,
      textStrokeColorHex: _parseHex(textStrokeVal, 0xFF000000),
      textAlign: _parseTextAlign(json['textAlign'] ?? json['text_align']),
      textTransform: TextTransformMode.fromDynamic(json['textTransform'] ?? json['text_transform']),
    );
  }
}
