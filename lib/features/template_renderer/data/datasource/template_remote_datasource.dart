import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../domain/models/template_model.dart';

abstract class TemplateRemoteDatasource {
  Future<List<TemplateModel>> fetchTemplates({String? categoryType});
}

class TemplateRemoteDatasourceImpl implements TemplateRemoteDatasource {
  final ApiClient apiClient;

  TemplateRemoteDatasourceImpl(this.apiClient);

  @override
  Future<List<TemplateModel>> fetchTemplates({String? categoryType}) async {
    final Map<String, dynamic>? queryParams =
        categoryType != null ? {'category_type': categoryType} : null;

    try {
      final response = await apiClient.get(
        ApiConstants.templates,
        queryParameters: queryParams,
      );
      if (response['success'] == true) {
        final dataList = (response['data'] is List) ? (response['data'] as List) : [];
        final parsed = dataList
            .whereType<Map>()
            .map((item) => TemplateModel.fromJson(item))
            .toList();
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (e) {
      print('Fetch templates primary URL error: $e');
    }

    // Try fallback production URL if local IP server fails/times out
    try {
      final fallbackDio = Dio(BaseOptions(
        baseUrl: 'https://tournax.in/api/v1',
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));
      final res = await fallbackDio.get(
        '/templates',
        queryParameters: queryParams,
      );
      if (res.data is Map && res.data['success'] == true) {
        final dataList = (res.data['data'] is List) ? (res.data['data'] as List) : [];
        return dataList
            .whereType<Map>()
            .map((item) => TemplateModel.fromJson(item))
            .toList();
      }
    } catch (fallbackError) {
      print('Fetch templates fallback URL error: $fallbackError');
    }

    return [];
  }
}
