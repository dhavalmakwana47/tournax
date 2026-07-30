import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/layer_model.dart';
import '../../../domain/models/layer_style.dart';
import '../../../domain/models/enums.dart';

class RenderShapeLayer extends StatelessWidget {
  final LayerModel layer;

  const RenderShapeLayer({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    final style = layer.style;
    final bool isCircle = layer.shapeType == ShapeType.circle;

    Decoration decoration;
    final List<Color> gradientColors =
        style.gradientColorsHex.map((c) => parseColor(c)).toList();

    if (style.isGradientFill && gradientColors.length >= 2) {
      final double rad = style.gradientAngle * (math.pi / 180);
      decoration = BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(style.borderRadius),
        gradient: LinearGradient(
          colors: gradientColors,
          stops: style.gradientStops.length == gradientColors.length ? style.gradientStops : null,
          begin: Alignment(math.cos(rad), math.sin(rad)),
          end: Alignment(-math.cos(rad), -math.sin(rad)),
        ),
        border: style.borderWidth > 0
            ? Border.all(
                color: parseColor(style.borderColorHex),
                width: style.borderWidth,
              )
            : null,
        boxShadow: style.shadowColorHex != 0x00000000 && style.shadowBlurRadius > 0
            ? [
                BoxShadow(
                  color: parseColor(style.shadowColorHex),
                  offset: Offset(style.shadowDx, style.shadowDy),
                  blurRadius: style.shadowBlurRadius,
                  spreadRadius: style.shadowSpreadRadius,
                )
              ]
            : null,
      );
    } else {
      decoration = BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(style.borderRadius),
        color: parseColor(style.fillColorHex),
        border: style.borderWidth > 0
            ? Border.all(
                color: parseColor(style.borderColorHex),
                width: style.borderWidth,
              )
            : null,
        boxShadow: style.shadowColorHex != 0x00000000 && style.shadowBlurRadius > 0
            ? [
                BoxShadow(
                  color: parseColor(style.shadowColorHex),
                  offset: Offset(style.shadowDx, style.shadowDy),
                  blurRadius: style.shadowBlurRadius,
                  spreadRadius: style.shadowSpreadRadius,
                )
              ]
            : null,
      );
    }

    if (layer.shapeType == ShapeType.polygon) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Opacity(
          opacity: style.opacity,
          child: CustomPaint(
            painter: _PolygonBadgePainter(
              color: parseColor(style.fillColorHex),
              borderColor: parseColor(style.borderColorHex),
              borderWidth: style.borderWidth,
            ),
          ),
        ),
      );
    }

    if (layer.shapeType == ShapeType.triangle) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Opacity(
          opacity: style.opacity,
          child: CustomPaint(
            painter: _TrianglePainter(
              color: parseColor(style.fillColorHex),
              borderColor: parseColor(style.borderColorHex),
              borderWidth: style.borderWidth,
            ),
          ),
        ),
      );
    }

    if (layer.shapeType == ShapeType.line || layer.shapeType == ShapeType.divider) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Center(
          child: Container(
            height: style.borderWidth > 0 ? style.borderWidth : 2.0,
            width: layer.width,
            color: parseColor(style.fillColorHex),
          ),
        ),
      );
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Opacity(
        opacity: style.opacity,
        child: Container(decoration: decoration),
      ),
    );
  }
}

class _PolygonBadgePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _PolygonBadgePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.height * 0.4, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - size.height * 0.4, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0) {
      final strokePaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _TrianglePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0) {
      final strokePaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
