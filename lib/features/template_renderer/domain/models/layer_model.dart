import 'enums.dart';
import 'layer_style.dart';

/// Single layer model within a template.
class LayerModel {
  final String id;
  final String name;
  final LayerType type;
  final String? parentId;
  final List<String> childrenIds;
  final bool isLocked;
  final bool isVisible;
  final int zIndex;

  // Transforms
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation; // In degrees
  final double scaleX;
  final double scaleY;
  final bool flipX;
  final bool flipY;

  // Style
  final LayerStyle style;

  // Specific Layer Payloads
  final String text;
  final String assetUrl;
  final String svgData;
  final String qrData;
  final String barcodeData;
  final ShapeType shapeType;
  final ImageFitMode imageFit;
  final String? variableKey;
  final bool isEditable;
  final Map<String, dynamic> metadata;

  const LayerModel({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.childrenIds = const [],
    this.isLocked = false,
    this.isVisible = true,
    this.zIndex = 0,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 200.0,
    this.height = 100.0,
    this.rotation = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.flipX = false,
    this.flipY = false,
    this.style = const LayerStyle(),
    this.text = 'Sample Text',
    this.assetUrl = '',
    this.svgData = '',
    this.qrData = 'https://tournax.com',
    this.barcodeData = '123456789012',
    this.shapeType = ShapeType.rectangle,
    this.imageFit = ImageFitMode.cover,
    this.variableKey,
    this.isEditable = true,
    this.metadata = const {},
  });

  LayerModel copyWith({
    String? id,
    String? name,
    LayerType? type,
    String? parentId,
    List<String>? childrenIds,
    bool? isLocked,
    bool? isVisible,
    int? zIndex,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scaleX,
    double? scaleY,
    bool? flipX,
    bool? flipY,
    LayerStyle? style,
    String? text,
    String? assetUrl,
    String? svgData,
    String? qrData,
    String? barcodeData,
    ShapeType? shapeType,
    ImageFitMode? imageFit,
    String? variableKey,
    bool? isEditable,
    Map<String, dynamic>? metadata,
  }) {
    return LayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      zIndex: zIndex ?? this.zIndex,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      style: style ?? this.style,
      text: text ?? this.text,
      assetUrl: assetUrl ?? this.assetUrl,
      svgData: svgData ?? this.svgData,
      qrData: qrData ?? this.qrData,
      barcodeData: barcodeData ?? this.barcodeData,
      shapeType: shapeType ?? this.shapeType,
      imageFit: imageFit ?? this.imageFit,
      variableKey: variableKey ?? this.variableKey,
      isEditable: isEditable ?? this.isEditable,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'isLocked': isLocked,
      'isVisible': isVisible,
      'zIndex': zIndex,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'scaleX': scaleX,
      'scaleY': scaleY,
      'flipX': flipX,
      'flipY': flipY,
      'style': style.toJson(),
      'text': text,
      'assetUrl': assetUrl,
      'svgData': svgData,
      'qrData': qrData,
      'barcodeData': barcodeData,
      'shapeType': shapeType.index,
      'imageFit': imageFit.index,
      'variableKey': variableKey,
      'is_editable': isEditable,
      'isEditable': isEditable,
      'metadata': metadata,
    };
  }

  factory LayerModel.fromJson(Map<dynamic, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);

    List<String> children = [];
    final rawChildren = json['childrenIds'] ?? json['children_ids'];
    if (rawChildren is List) {
      children = rawChildren.map((e) => e.toString()).toList();
    }

    LayerStyle parsedStyle = const LayerStyle();
    if (json['style'] is Map) {
      parsedStyle = LayerStyle.fromJson(json['style'] as Map);
    }

    Map<String, dynamic> parsedMeta = {};
    if (json['metadata'] is Map) {
      parsedMeta = Map<String, dynamic>.from(json['metadata'] as Map);
    }

    double parseDoubleVal(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? fallback;
    }

    int parseIntVal(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? fallback;
    }

    final rawType = json['type'];
    final rawShape = json['shapeType'] ?? json['shape_type'];
    final rawFit = json['imageFit'] ?? json['image_fit'];

    return LayerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Layer',
      type: LayerType.fromDynamic(rawType, LayerType.text),
      parentId: (json['parentId'] ?? json['parent_id'])?.toString(),
      childrenIds: children,
      isLocked: (json['isLocked'] ?? json['is_locked']) as bool? ?? false,
      isVisible: (json['isVisible'] ?? json['is_visible']) as bool? ?? true,
      zIndex: parseIntVal(json['zIndex'] ?? json['z_index'], 0),
      x: parseDoubleVal(json['x'], 0.0),
      y: parseDoubleVal(json['y'], 0.0),
      width: parseDoubleVal(json['width'], 200.0),
      height: parseDoubleVal(json['height'], 100.0),
      rotation: parseDoubleVal(json['rotation'], 0.0),
      scaleX: parseDoubleVal(json['scaleX'] ?? json['scale_x'], 1.0),
      scaleY: parseDoubleVal(json['scaleY'] ?? json['scale_y'], 1.0),
      flipX: (json['flipX'] ?? json['flip_x']) as bool? ?? false,
      flipY: (json['flipY'] ?? json['flip_y']) as bool? ?? false,
      style: parsedStyle,
      text: json['text']?.toString() ?? 'Sample Text',
      assetUrl: (json['assetUrl'] ?? json['asset_url'])?.toString() ?? '',
      svgData: (json['svgData'] ?? json['svg_data'])?.toString() ?? '',
      qrData: (json['qrData'] ?? json['qr_data'])?.toString() ?? 'https://tournax.com',
      barcodeData: (json['barcodeData'] ?? json['barcode_data'])?.toString() ?? '123456789012',
      shapeType: ShapeType.fromDynamic(rawShape, ShapeType.rectangle),
      imageFit: ImageFitMode.fromDynamic(rawFit, ImageFitMode.cover),
      variableKey: (json['variableKey'] ?? json['variable_key'])?.toString(),
      isEditable: (json['isEditable'] ?? json['is_editable']) as bool? ?? true,
      metadata: parsedMeta,
    );
  }
}
