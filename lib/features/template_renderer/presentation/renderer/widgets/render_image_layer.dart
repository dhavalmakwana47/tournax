import 'package:flutter/material.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/layer_model.dart';

class RenderImageLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderImageLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  BoxFit _getBoxFit(ImageFitMode mode) {
    switch (mode) {
      case ImageFitMode.contain: return BoxFit.contain;
      case ImageFitMode.cover: return BoxFit.cover;
      case ImageFitMode.fill: return BoxFit.fill;
      case ImageFitMode.fitWidth: return BoxFit.fitWidth;
      case ImageFitMode.fitHeight: return BoxFit.fitHeight;
      case ImageFitMode.none: return BoxFit.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = layer.style;
    String finalUrl = layer.assetUrl;

    if (layer.variableKey != null && variables.containsKey(layer.variableKey)) {
      finalUrl = variables[layer.variableKey]!;
    } else {
      variables.forEach((k, v) {
        finalUrl = finalUrl.replaceAll(k, v);
      });
    }

    Widget imageWidget;
    if (finalUrl.startsWith('http://') || finalUrl.startsWith('https://')) {
      imageWidget = Image.network(
        finalUrl,
        fit: _getBoxFit(layer.imageFit),
        errorBuilder: (context, error, stackTrace) {
          if (finalUrl.contains('10.151.118.115:8000')) {
            final fallback = finalUrl.replaceAll('10.151.118.115:8000', '127.0.0.1:8000');
            return Image.network(fallback, fit: _getBoxFit(layer.imageFit), errorBuilder: (_, __, ___) => _buildPlaceholder());
          }
          return _buildPlaceholder();
        },
      );
    } else if (finalUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        finalUrl,
        fit: _getBoxFit(layer.imageFit),
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: Opacity(
          opacity: style.opacity,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: layer.width,
      height: layer.height,
      color: Colors.white10,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white38, size: 32),
      ),
    );
  }
}
