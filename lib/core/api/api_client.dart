import 'package:dio/dio.dart';
import '../utils/app_logger.dart';
import 'dio_client.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._dioClient);

  final DioClient _dioClient;

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      throw _resolveException(e);
    } catch (e, st) {
      appLogger.e('ApiClient.post unexpected', error: e, stackTrace: st);
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      throw _resolveException(e);
    } catch (e, st) {
      appLogger.e('ApiClient.put unexpected', error: e, stackTrace: st);
      throw ApiException(message: e.toString());
    }
  }

  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _dioClient.dio.delete<void>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _resolveException(e);
    } catch (e, st) {
      appLogger.e('ApiClient.delete unexpected', error: e, stackTrace: st);
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      throw _resolveException(e);
    } catch (e, st) {
      appLogger.e('ApiClient.get unexpected', error: e, stackTrace: st);
      throw ApiException(message: e.toString());
    }
  }

  ApiException _resolveException(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    if (e.response != null) {
      final data = e.response?.data;
      final serverMessage = data?['message'] as String?;
      final statusCode = e.response!.statusCode ?? 0;
      // Parse per-field validation errors from Laravel 422 response
      Map<String, String> fieldErrors = const {};
      if (statusCode == 422 && data?['errors'] is Map) {
        final raw = data!['errors'] as Map;
        fieldErrors = raw.map((key, value) {
          final first = (value is List && value.isNotEmpty)
              ? value.first.toString()
              : value.toString();
          return MapEntry(key.toString(), first);
        });
      }
      return ApiException.fromStatusCode(statusCode, serverMessage, fieldErrors);
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException.timeout(),
      DioExceptionType.connectionError => ApiException.noInternet(),
      _ => ApiException.unexpected(),
    };
  }
}
