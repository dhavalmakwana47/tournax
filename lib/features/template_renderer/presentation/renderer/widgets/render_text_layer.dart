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
        // Try alias e.g. team_name_1 -> team_1, team_wins_1 -> wins_1, etc.
        if (cleanKey.startsWith('team_name_')) {
          final numStr = cleanKey.substring('team_name_'.length);
          final altKey = '{{team_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
        } else if (cleanKey.startsWith('team_rank_')) {
          final numStr = cleanKey.substring('team_rank_'.length);
          final altKey = '{{rank_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
        } else if (cleanKey.startsWith('rank_')) {
          final numStr = cleanKey.substring('rank_'.length);
          final altKey = '{{team_rank_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
        } else if (cleanKey.startsWith('team_wins_') || cleanKey.startsWith('team_win_')) {
          final numStr = cleanKey.startsWith('team_wins_') ? cleanKey.substring('team_wins_'.length) : cleanKey.substring('team_win_'.length);
          final altKey = '{{wins_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
          if (!variables.containsKey(altKey)) {
            final altKey2 = '{{win_$numStr}}';
            if (variables.containsKey(altKey2)) content = variables[altKey2]!;
          }
          if (!variables.containsKey(altKey)) {
            final altKey3 = '{{wwcd_$numStr}}';
            if (variables.containsKey(altKey3)) content = variables[altKey3]!;
          }
        } else if (cleanKey.startsWith('wins_') || cleanKey.startsWith('win_') || cleanKey.startsWith('wwcd_')) {
          final numStr = cleanKey.contains('wins_')
              ? cleanKey.substring('wins_'.length)
              : (cleanKey.contains('win_') ? cleanKey.substring('win_'.length) : cleanKey.substring('wwcd_'.length));
          final altKey = '{{team_wins_$numStr}}';
          if (variables.containsKey(altKey)) content = variables[altKey]!;
          if (!variables.containsKey(altKey)) {
            final altKey2 = '{{team_win_$numStr}}';
            if (variables.containsKey(altKey2)) content = variables[altKey2]!;
          }
        } else if (cleanKey == 'team_wins' || cleanKey == 'team_win' || cleanKey == 'wins' || cleanKey == 'win' || cleanKey == 'wwcd') {
          if (variables.containsKey('{{team_win_1}}')) {
            content = variables['{{team_win_1}}']!;
          } else if (variables.containsKey('{{team_wins_1}}')) {
            content = variables['{{team_wins_1}}']!;
          } else if (variables.containsKey('{{win_1}}')) {
            content = variables['{{win_1}}']!;
          } else if (variables.containsKey('{{wins_1}}')) {
            content = variables['{{wins_1}}']!;
          } else if (variables.containsKey('{{wwcd_1}}')) {
            content = variables['{{wwcd_1}}']!;
          }
        } else if (cleanKey == 'team_matches' || cleanKey == 'matches') {
          if (variables.containsKey('{{team_matches_1}}')) {
            content = variables['{{team_matches_1}}']!;
          } else if (variables.containsKey('{{matches_1}}')) {
            content = variables['{{matches_1}}']!;
          }
        } else if (cleanKey == 'team_rank' || cleanKey == 'rank') {
          if (variables.containsKey('{{team_rank_1}}')) {
            content = variables['{{team_rank_1}}']!;
          } else if (variables.containsKey('{{rank_1}}')) {
            content = variables['{{rank_1}}']!;
          }
        } else if (cleanKey == 'team_kills' || cleanKey == 'kill_points' || cleanKey == 'kills') {
          if (variables.containsKey('{{team_kills_1}}')) {
            content = variables['{{team_kills_1}}']!;
          } else if (variables.containsKey('{{kills_1}}')) {
            content = variables['{{kills_1}}']!;
          }
        } else if (cleanKey == 'team_points' || cleanKey == 'placement_points') {
          if (variables.containsKey('{{team_points_1}}')) {
            content = variables['{{team_points_1}}']!;
          } else if (variables.containsKey('{{placement_points_1}}')) {
            content = variables['{{placement_points_1}}']!;
          }
        } else if (cleanKey == 'team_total_points' || cleanKey == 'total_points' || cleanKey == 'points' || cleanKey == 'pts') {
          if (variables.containsKey('{{team_total_points_1}}')) {
            content = variables['{{team_total_points_1}}']!;
          } else if (variables.containsKey('{{total_points_1}}')) {
            content = variables['{{total_points_1}}']!;
          } else if (variables.containsKey('{{pts_1}}')) {
            content = variables['{{pts_1}}']!;
          }
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
      Color shadowColor = parseColor(style.shadowColorHex);
      // Soften high-alpha dark shadows to prevent pitch-black circular blobs behind text
      if (shadowColor.a > 0.4) {
        shadowColor = shadowColor.withValues(alpha: 0.35);
      }
      textStyle = textStyle.copyWith(
        shadows: [
          Shadow(
            color: shadowColor,
            offset: Offset(style.shadowDx, style.shadowDy),
            blurRadius: style.shadowBlurRadius.clamp(0.0, 12.0),
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
        shadows: const [], // Prevent duplicate stacked shadows on stroke layer
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
      final gradientTextStyle = baseTextStyle.copyWith(
        color: Colors.white,
        shadows: const [], // Clear shadows inside ShaderMask to prevent dark circle shadow artifacts
      );

      final Widget gradientText = ShaderMask(
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
          style: gradientTextStyle,
        ),
      );

      if (baseTextStyle.shadows != null && baseTextStyle.shadows!.isNotEmpty) {
        child = Stack(
          alignment: _mapTextAlign(style.textAlign),
          children: [
            Text(
              text,
              textAlign: style.textAlign,
              style: TextStyle(
                fontFamily: baseTextStyle.fontFamily,
                fontSize: baseTextStyle.fontSize,
                fontWeight: baseTextStyle.fontWeight,
                fontStyle: baseTextStyle.fontStyle,
                color: Colors.transparent,
                shadows: baseTextStyle.shadows,
              ),
            ),
            gradientText,
          ],
        );
      } else {
        child = gradientText;
      }
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
