import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../domain/models/template_model.dart';

class PaginatedTemplates {
  final List<TemplateModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;

  const PaginatedTemplates({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });
}

abstract class TemplateRemoteDatasource {
  Future<PaginatedTemplates> fetchTemplates({
    String? categoryType,
    int page = 1,
    int perPage = 10,
  });
}

class TemplateRemoteDatasourceImpl implements TemplateRemoteDatasource {
  final ApiClient apiClient;

  TemplateRemoteDatasourceImpl(this.apiClient);

  @override
  Future<PaginatedTemplates> fetchTemplates({
    String? categoryType,
    int page = 1,
    int perPage = 10,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (categoryType != null && categoryType.isNotEmpty) 'category_type': categoryType,
      'page': page,
      'per_page': perPage,
      'limit': perPage,
    };

    try {
      final response = await apiClient.get(
        ApiConstants.templates,
        queryParameters: queryParams,
      );
      if (response is Map) {
        return _parsePaginatedTemplates(response, page, perPage);
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
      if (res.data is Map) {
        return _parsePaginatedTemplates(res.data as Map, page, perPage);
      }
    } catch (fallbackError) {
      print('Fetch templates fallback URL error: $fallbackError');
    }

    return PaginatedTemplates(items: [], hasMore: false, currentPage: page, lastPage: page);
  }

  PaginatedTemplates _parsePaginatedTemplates(Map<dynamic, dynamic> response, int page, int perPage) {
    dynamic rawData = response['data'];
    List<dynamic>? list;
    int currentPage = page;
    int lastPage = page;
    bool hasMore = false;

    if (rawData is List) {
      list = rawData;
      hasMore = list.length >= perPage;
    } else if (rawData is Map) {
      if (rawData['data'] is List) {
        list = rawData['data'] as List<dynamic>;
      }
      currentPage = _toInt(rawData['current_page'], page);
      lastPage = _toInt(rawData['last_page'], page);
      hasMore = currentPage < lastPage;
    }

    if (response['meta'] is Map) {
      final meta = response['meta'] as Map;
      currentPage = _toInt(meta['current_page'], currentPage);
      lastPage = _toInt(meta['last_page'], lastPage);
      hasMore = currentPage < lastPage;
    }

    final items = (list ?? [])
        .whereType<Map>()
        .map((item) => TemplateModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return PaginatedTemplates(
      items: items,
      hasMore: hasMore,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }
}
