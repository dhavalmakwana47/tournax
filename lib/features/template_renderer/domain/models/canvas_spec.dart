/// Canvas specification model for template renderer.
class CanvasSpec {
  final double width;
  final double height;
  final int backgroundColorHex;
  final String backgroundImageUrl;
  final bool showGrid;
  final double gridSize;

  const CanvasSpec({
    this.width = 1080.0,
    this.height = 1920.0,
    this.backgroundColorHex = 0xFF0F172A,
    this.backgroundImageUrl = '',
    this.showGrid = false,
    this.gridSize = 20.0,
  });

  CanvasSpec copyWith({
    double? width,
    double? height,
    int? backgroundColorHex,
    String? backgroundImageUrl,
    bool? showGrid,
    double? gridSize,
  }) {
    return CanvasSpec(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      showGrid: showGrid ?? this.showGrid,
      gridSize: gridSize ?? this.gridSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'backgroundColorHex': backgroundColorHex,
      'backgroundImageUrl': backgroundImageUrl,
      'showGrid': showGrid,
      'gridSize': gridSize,
    };
  }

  factory CanvasSpec.fromJson(Map<dynamic, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);

    int parseColorVal(dynamic val) {
      if (val == null) return 0xFF0F172A;
      if (val is int) return val.toUnsigned(32);
      if (val is num) return val.toInt().toUnsigned(32);
      final str = val.toString().trim();
      final parsedInt = int.tryParse(str);
      if (parsedInt != null) return parsedInt.toUnsigned(32);

      var cleanHex = str.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '').trim();
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      if (cleanHex.length == 8) {
        final parsed = int.tryParse(cleanHex, radix: 16);
        if (parsed != null) return parsed.toUnsigned(32);
      }
      return 0xFF0F172A;
    }

    final bgVal = json['backgroundColorHex'] ?? json['background_color_hex'] ?? json['backgroundColor'] ?? json['background_color'];
    final bgImgVal = json['backgroundImageUrl'] ?? json['background_image_url'] ?? json['backgroundImage'] ?? json['background_image'];

    return CanvasSpec(
      width: (json['width'] as num?)?.toDouble() ?? 1080.0,
      height: (json['height'] as num?)?.toDouble() ?? 1920.0,
      backgroundColorHex: parseColorVal(bgVal),
      backgroundImageUrl: bgImgVal?.toString() ?? '',
      showGrid: (json['showGrid'] ?? json['show_grid']) as bool? ?? false,
      gridSize: ((json['gridSize'] ?? json['grid_size']) as num?)?.toDouble() ?? 20.0,
    );
  }
}
