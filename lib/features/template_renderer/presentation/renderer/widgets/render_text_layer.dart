import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/layer_model.dart';
import '../../../domain/models/layer_style.dart';
import '../../../domain/models/enums.dart';

class RenderTextLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderTextLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  String _resolveText() {
    String content = layer.text;

    if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
      final rawKey = layer.variableKey!;
      final wrappedKey = rawKey.startsWith('{{') ? rawKey : '{{$rawKey}}';
      final cleanKey = rawKey.replaceAll('{{', '').replaceAll('}}', '');

      if (variables.containsKey(wrappedKey)) {
        content = variables[wrappedKey]!;
      } else if (variables.containsKey(rawKey)) {
        content = variables[rawKey]!;
      } else if (variables.containsKey(cleanKey)) {
        content = variables[cleanKey]!;
      } else {
        // Try alias e.g. team_name_1 -> team_1
        if (cleanKey.startsWith('team_name_')) {
          final numStr = cleanKey.substring('team_name_'.length);
          final altKey = '{{team_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
        } else if (cleanKey.startsWith('team_') && !cleanKey.startsWith('team_name_')) {
          final numStr = cleanKey.substring('team_'.length);
          final altKey = '{{team_name_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
        }
      }
    }

    // Substitute embedded variable tags like {{team_name}} or {{team_1}}
    variables.forEach((key, value) {
      content = content.replaceAll(key, value);
      final unbraced = key.replaceAll('{{', '').replaceAll('}}', '');
      if (unbraced.isNotEmpty) {
        content = content.replaceAll('{{$unbraced}}', value);
      }
    });

    switch (layer.style.textTransform) {
      case TextTransformMode.uppercase:
        return content.toUpperCase();
      case TextTransformMode.lowercase:
        return content.toLowerCase();
      case TextTransformMode.capitalize:
        return content.split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
      case TextTransformMode.none:
        return content;
    }
  }

  TextStyle _buildTextStyle() {
    final style = layer.style;
    final FontWeight weight = FontWeight.values[
        ((style.fontWeightValue / 100).round() - 1).clamp(0, 8)];

    final Color fontColor = parseColor(style.textColorHex);

    TextStyle textStyle;
    try {
      textStyle = GoogleFonts.getFont(
        style.fontFamily,
        fontSize: style.fontSize,
        fontWeight: weight,
        fontStyle: style.isItalic ? FontStyle.italic : FontStyle.normal,
        color: fontColor,
        letterSpacing: style.letterSpacing,
        wordSpacing: style.wordSpacing,
        height: style.lineHeight,
      );
    } catch (_) {
      textStyle = TextStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        fontWeight: weight,
        fontStyle: style.isItalic ? FontStyle.italic : FontStyle.normal,
        color: fontColor,
        letterSpacing: style.letterSpacing,
        wordSpacing: style.wordSpacing,
        height: style.lineHeight,
      );
    }

    if (style.isUnderline) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }

    if (style.shadowColorHex != 0x00000000 && style.shadowBlurRadius > 0) {
      textStyle = textStyle.copyWith(
        shadows: [
          Shadow(
            color: parseColor(style.shadowColorHex),
            offset: Offset(style.shadowDx, style.shadowDy),
            blurRadius: style.shadowBlurRadius,
          ),
        ],
      );
    }

    return textStyle;
  }

  @override
  Widget build(BuildContext context) {
    final text = _resolveText();
    final baseTextStyle = _buildTextStyle();
    final style = layer.style;

    Widget child = Text(
      text,
      textAlign: style.textAlign,
      style: baseTextStyle,
    );

    // Text stroke support using Stack
    if (style.textStrokeWidth > 0) {
      final strokeStyle = baseTextStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.textStrokeWidth
          ..color = parseColor(style.textStrokeColorHex),
      );

      child = Stack(
        children: [
          Text(text, textAlign: style.textAlign, style: strokeStyle),
          Text(text, textAlign: style.textAlign, style: baseTextStyle),
        ],
      );
    }

    // Gradient text support only if explicitly enabled
    if (style.isGradientFill && style.gradientColorsHex.length >= 2) {
      final colors = style.gradientColorsHex.map((c) => parseColor(c)).toList();
      child = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: colors,
            stops: style.gradientStops.length == colors.length ? style.gradientStops : null,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Text(
          text,
          textAlign: style.textAlign,
          style: baseTextStyle.copyWith(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Align(
        alignment: _mapTextAlign(style.textAlign),
        child: child,
      ),
    );
  }

  Alignment _mapTextAlign(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.justify:
      case TextAlign.start:
      case TextAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }
}
