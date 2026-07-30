import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/layer_model.dart';

class RenderBarcodeLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderBarcodeLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    String data = layer.barcodeData;
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
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: data.isNotEmpty ? data : '123456789012',
          width: layer.width,
          height: layer.height,
          color: Colors.black,
        ),
      ),
    );
  }
}
