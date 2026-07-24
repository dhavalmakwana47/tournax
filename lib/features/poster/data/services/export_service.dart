import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<File?> capturePng({
    required GlobalKey repaintKey,
    bool transparent = false,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Boundary is null. Make sure the RepaintBoundary is attached.');
        return null;
      }

      // Calculate pixel ratio to target 2048x2048 resolution
      final double width = boundary.size.width;
      final double ratio = width > 0 ? (2048.0 / width) : 4.0;

      final image = await boundary.toImage(pixelRatio: ratio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Capture PNG error: $e');
      return null;
    }
  }

  Future<bool> saveToGallery(File file) async {
    try {
      final result = await ImageGallerySaverPlus.saveFile(file.path);
      return result != null && (result['isSuccess'] == true || result['isSuccess'] == 'true');
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return false;
    }
  }

  Future<void> sharePoster(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Check out this Tournament Slot List!');
    } catch (e) {
      debugPrint('Share poster error: $e');
    }
  }
}
