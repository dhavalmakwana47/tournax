import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/api_constants.dart';

class RemoteErrorLoggerService {
  RemoteErrorLoggerService._();
  static final RemoteErrorLoggerService instance = RemoteErrorLoggerService._();

  Future<void> sendErrorLog({
    required Object exception,
    StackTrace? stackTrace,
    String? route,
  }) async {
    try {
      final platform = kIsWeb
          ? 'web'
          : Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'ios'
                  : Platform.operatingSystem;

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logError}');

      final payload = {
        'error_message': exception.toString(),
        'stack_trace': stackTrace?.toString(),
        'platform': platform,
        'app_version': '1.0.0',
        'url_or_route': route ?? 'unknown',
      };

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Quietly ignore logging failures to avoid recursion or UI interruption
      debugPrint('Remote error logging failed: $e');
    }
  }
}
