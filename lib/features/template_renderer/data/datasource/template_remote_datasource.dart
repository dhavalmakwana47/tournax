import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../domain/models/template_model.dart';

abstract class TemplateRemoteDatasource {
  Future<List<TemplateModel>> fetchTemplates();
}

class TemplateRemoteDatasourceImpl implements TemplateRemoteDatasource {
  final ApiClient apiClient;

  TemplateRemoteDatasourceImpl(this.apiClient);

  @override
  Future<List<TemplateModel>> fetchTemplates() async {
    try {
      final response = await apiClient.get(ApiConstants.templates);
      if (response['success'] == true) {
        final dataList = (response['data'] is List) ? (response['data'] as List) : [];
        return dataList
            .whereType<Map>()
            .map((item) => TemplateModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      // Fallback: If network error or empty server templates, return default slot list presets
      return [];
    }
  }
}
