import 'widget_layout_model.dart';
import 'widget_theme_model.dart';

class WidgetAssetItem {
  final String filename;
  final String url;
  final String? hash;
  final int sizeBytes;
  final String mime;

  const WidgetAssetItem({
    required this.filename,
    required this.url,
    this.hash,
    required this.sizeBytes,
    required this.mime,
  });

  factory WidgetAssetItem.fromJson(Map<String, dynamic> json) {
    return WidgetAssetItem(
      filename: json['filename'] ?? '',
      url: json['url'] ?? '',
      hash: json['hash'],
      sizeBytes: json['size_bytes'] ?? 0,
      mime: json['mime'] ?? 'image/png',
    );
  }
}

class WidgetTemplateModel {
  final int id;
  final String type;
  final String category;
  final String slug;
  final String name;
  final String? description;
  final bool isPremium;
  final String version;
  final String? checksumSha256;
  final String assetBaseUrl;
  final WidgetThemeModel theme;
  final WidgetLayoutModel layout;
  final Map<String, dynamic> typography;
  final Map<String, WidgetAssetItem> assets;

  const WidgetTemplateModel({
    required this.id,
    required this.type,
    required this.category,
    required this.slug,
    required this.name,
    this.description,
    required this.isPremium,
    required this.version,
    this.checksumSha256,
    required this.assetBaseUrl,
    required this.theme,
    required this.layout,
    required this.typography,
    required this.assets,
  });

  factory WidgetTemplateModel.fromJson(Map<String, dynamic> json) {
    Map<String, WidgetAssetItem> parsedAssets = {};
    if (json['assets'] is Map) {
      final rawAssets = json['assets'] as Map<String, dynamic>;
      parsedAssets = rawAssets.map(
        (key, val) => MapEntry(key, WidgetAssetItem.fromJson(val as Map<String, dynamic>)),
      );
    } else if (json['assets'] is List) {
      for (var item in (json['assets'] as List)) {
        if (item is Map<String, dynamic>) {
          final key = item['key'] ?? item['asset_key'] ?? 'asset_${parsedAssets.length}';
          parsedAssets[key] = WidgetAssetItem.fromJson(item);
        }
      }
    }

    return WidgetTemplateModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'slot_list',
      category: json['category'] ?? 'general',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isPremium: json['is_premium'] ?? false,
      version: json['version'] ?? '1.0.0',
      checksumSha256: json['checksum_sha256'],
      assetBaseUrl: json['asset_base_url'] ?? '',
      theme: WidgetThemeModel.fromJson(json['theme'] ?? {}),
      layout: WidgetLayoutModel.fromJson(json['layout'] ?? {}),
      typography: json['typography'] ?? {},
      assets: parsedAssets,
    );
  }
}
