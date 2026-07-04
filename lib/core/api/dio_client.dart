import 'package:dio/dio.dart';
import '../routes/app_router.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
      ),
    )
      ..interceptors.add(_AuthInterceptor(_storage))
      ..interceptors.add(_LoggingInterceptor())
      ..interceptors.add(_UnauthenticatedInterceptor(_storage))
      ..interceptors.add(_ErrorInterceptor());
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    appLogger.d('[AUTH] token=${token != null ? "present" : "null"} for ${options.uri}');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d('[REQ] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.d('[RES] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e('[ERR] ${err.type} ${err.requestOptions.uri}', error: err);
    handler.next(err);
  }
}

class _UnauthenticatedInterceptor extends Interceptor {
  _UnauthenticatedInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      appLogger.w('[AUTH] 401 received — clearing session and redirecting to login.');
      await _storage.clearAll();
      authNotifier.setToken(null);
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException.timeout(),
      DioExceptionType.connectionError => ApiException.noInternet(),
      DioExceptionType.badResponse => _parseBadResponse(err),
      _ => ApiException.unexpected(),
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.message,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _parseBadResponse(DioException err) {
    final data = err.response?.data;
    final statusCode = err.response?.statusCode ?? 0;
    final serverMessage = data?['message'] as String?;

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
}
