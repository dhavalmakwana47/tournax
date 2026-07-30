import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/models/layer_model.dart';

class RenderQrLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderQrLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    String data = layer.qrData;
    variables.forEach((k, v) {
      data = data.replaceAll(k, v);
    });

    final style = layer.style;

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: QrImageView(
          data: data.isNotEmpty ? data : 'https://tournax.com',
          version: QrVersions.auto,
          size: layer.width,
          gapless: false,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
