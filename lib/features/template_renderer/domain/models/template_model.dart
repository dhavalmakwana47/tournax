import 'dart:convert';
import 'canvas_spec.dart';
import 'layer_model.dart';

/// Top-level root template model for dynamic template rendering in TournaX.
class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String categoryType;
  final int version;
  final String createdAt;
  final String updatedAt;
  final CanvasSpec canvasSpec;
  final List<LayerModel> layers;
  final Map<String, String> globalVariables;
  final Map<String, dynamic> metadata;
  final String? thumbnail;

  const TemplateModel({
    required this.id,
    required this.name,
    this.description = 'TournaX Dynamic Tournament Template',
    this.category = 'Tournament Overlay',
    this.categoryType = 'slot_list',
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.canvasSpec = const CanvasSpec(),
    this.layers = const [],
    this.globalVariables = const {},
    this.metadata = const {},
    this.thumbnail,
  });

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? categoryType,
    int? version,
    String? createdAt,
    String? updatedAt,
    CanvasSpec? canvasSpec,
    List<LayerModel>? layers,
    Map<String, String>? globalVariables,
    Map<String, dynamic>? metadata,
    String? thumbnail,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryType: categoryType ?? this.categoryType,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canvasSpec: canvasSpec ?? this.canvasSpec,
      layers: layers ?? this.layers,
      globalVariables: globalVariables ?? this.globalVariables,
      metadata: metadata ?? this.metadata,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'category_type': categoryType,
      'categoryType': categoryType,
      'version': version,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'canvasSpec': canvasSpec.toJson(),
      'layers': layers.map((e) => e.toJson()).toList(),
      'globalVariables': globalVariables,
      'metadata': metadata,
      'thumbnail': thumbnail,
    };
  }

  factory TemplateModel.fromJson(Map<dynamic, dynamic> rawJson) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(rawJson);
    Map<String, dynamic> root = Map<String, dynamic>.from(json);

    if (json.containsKey('json_data') && json['json_data'] != null) {
      if (json['json_data'] is String) {
        try {
          final decoded = jsonDecode(json['json_data'] as String);
          if (decoded is Map) {
            root.addAll(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      } else if (json['json_data'] is Map) {
        root.addAll(Map<String, dynamic>.from(json['json_data'] as Map));
      }
    }

    if (json['id'] != null) root['id'] = json['id'].toString();
    if (json['name'] != null) root['name'] = json['name'];
    if (json['thumbnail'] != null) root['thumbnail'] = json['thumbnail'];
    if (json['created_at'] != null) root['createdAt'] = json['created_at'];
    if (json['updated_at'] != null) root['updatedAt'] = json['updated_at'];
    if (json['category_type'] != null) root['category_type'] = json['category_type'];

    CanvasSpec spec = const CanvasSpec();
    final rawSpec = root['canvasSpec'] ?? root['canvas_spec'];
    if (rawSpec is Map) {
      spec = CanvasSpec.fromJson(Map<String, dynamic>.from(rawSpec as Map));
    } else if (json['width'] != null && json['height'] != null) {
      spec = CanvasSpec(
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );
    }

    List<LayerModel> parsedLayers = [];
    final rawLayers = root['layers'];
    if (rawLayers is List) {
      for (final item in rawLayers) {
        if (item is Map) {
          parsedLayers.add(LayerModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    Map<String, String> parsedGlobals = {};
    final rawGlobals = root['globalVariables'] ?? root['global_variables'];
    if (rawGlobals is Map) {
      (rawGlobals as Map).forEach((k, v) {
        parsedGlobals[k.toString()] = v.toString();
      });
    }

    Map<String, dynamic> parsedMetadata = {};
    if (root['metadata'] is Map) {
      parsedMetadata = Map<String, dynamic>.from(root['metadata'] as Map);
    }

    final String catType = root['category_type'] as String? ??
        root['categoryType'] as String? ??
        json['category_type'] as String? ??
        json['categoryType'] as String? ??
        'slot_list';

    return TemplateModel(
      id: root['id']?.toString() ?? json['id']?.toString() ?? '',
      name: root['name'] as String? ?? json['name'] as String? ?? 'Untitled Template',
      description: root['description'] as String? ?? 'TournaX Dynamic Tournament Template',
      category: root['category'] as String? ?? 'Tournament Overlay',
      categoryType: catType,
      version: (root['version'] as num?)?.toInt() ?? 1,
      createdAt: root['createdAt'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: root['updatedAt'] as String? ?? json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      canvasSpec: spec,
      layers: parsedLayers,
      globalVariables: parsedGlobals,
      metadata: parsedMetadata,
      thumbnail: root['thumbnail'] as String? ?? json['thumbnail'] as String?,
    );
  }
}
