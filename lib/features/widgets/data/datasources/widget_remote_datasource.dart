import 'package:dio/dio.dart';
import '../models/widget_category_model.dart';
import '../models/widget_template_model.dart';

class WidgetRemoteDataSource {
  final Dio _dio;

  WidgetRemoteDataSource(this._dio);

  /// Fetch template list from API
  Future<List<WidgetTemplateModel>> getTemplates({String? type, String? category}) async {
    try {
      final response = await _dio.get(
        '/widgets/templates',
        queryParameters: {
          if (type != null) 'type': type,
          if (category != null) 'category': category,
        },
      );

      final List data = response.data['data'] ?? [];
      return data.map((json) => WidgetTemplateModel.fromJson(json)).toList();
    } catch (e, stack) {
      // Print diagnostic error info
      print('WidgetRemoteDataSource error fetching templates: $e\n$stack');
      return [];
    }
  }

  /// Fetch categories list from API
  Future<List<WidgetCategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/widgets/categories');
      final List data = response.data['data'] ?? [];
      return data.map((json) => WidgetCategoryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch single template details with optional ETag
  Future<WidgetTemplateModel?> getTemplateBySlug(String slug, {String? etag}) async {
    try {
      final options = Options(
        headers: etag != null ? {'If-None-Match': etag} : null,
      );

      final response = await _dio.get('/v1/widgets/templates/$slug', options: options);

      if (response.statusCode == 304) {
        return null; // Not modified
      }

      final data = response.data['data'] ?? response.data;
      return WidgetTemplateModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Sync client version manifest
  Future<Map<String, dynamic>> syncManifest(Map<String, String> localVersions) async {
    try {
      final response = await _dio.post(
        '/v1/widgets/sync-manifest',
        data: {'versions': localVersions},
      );

      return response.data['data'] ?? {};
    } catch (e) {
      return {};
    }
  }
}
