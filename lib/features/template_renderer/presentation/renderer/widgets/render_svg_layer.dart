import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/models/layer_model.dart';

class RenderSvgLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderSvgLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    String rawSvg = layer.svgData;
    variables.forEach((k, v) {
      rawSvg = rawSvg.replaceAll(k, v);
    });

    if (rawSvg.isEmpty && layer.assetUrl.isNotEmpty) {
      if (layer.assetUrl.startsWith('http://') || layer.assetUrl.startsWith('https://')) {
        return SizedBox(
          width: layer.width,
          height: layer.height,
          child: SvgPicture.network(
            layer.assetUrl,
            width: layer.width,
            height: layer.height,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    if (rawSvg.isEmpty) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Container(
          color: Colors.white10,
          child: const Center(child: Icon(Icons.code, color: Colors.white38)),
        ),
      );
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: SvgPicture.string(
        rawSvg,
        width: layer.width,
        height: layer.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
