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

  String _resolveUrl() {
    String finalUrl = layer.assetUrl;

    final cleanName = layer.name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    final layerNameKey = '{{$cleanName}}';

    if (variables.containsKey(layerNameKey) && variables[layerNameKey]!.isNotEmpty) {
      return variables[layerNameKey]!;
    }

    if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
      final rawKey = layer.variableKey!;
      final wrappedKey = rawKey.startsWith('{{') ? rawKey : '{{$rawKey}}';
      final cleanKey = rawKey.replaceAll('{{', '').replaceAll('}}', '');

      if (variables.containsKey(wrappedKey) && variables[wrappedKey]!.isNotEmpty) {
        return variables[wrappedKey]!;
      } else if (variables.containsKey(rawKey) && variables[rawKey]!.isNotEmpty) {
        return variables[rawKey]!;
      } else if (variables.containsKey(cleanKey) && variables[cleanKey]!.isNotEmpty) {
        return variables[cleanKey]!;
      }
    }

    variables.forEach((k, v) {
      finalUrl = finalUrl.replaceAll(k, v);
    });

    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    final style = layer.style;
    final String finalUrl = _resolveUrl();

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
    // If layer has no image URL or asset, render nothing to avoid dark placeholder box artifacts
    if (layer.assetUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final isTeamLogo = layer.type == LayerType.teamLogo || (layer.variableKey?.contains('team_logo') ?? false);
    return Container(
      width: layer.width,
      height: layer.height,
      decoration: BoxDecoration(
        color: isTeamLogo ? Colors.amber.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(layer.style.borderRadius),
      ),
    );
  }
}
