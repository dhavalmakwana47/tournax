import 'package:equatable/equatable.dart';

class ApiException extends Equatable implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  factory ApiException.fromStatusCode(
    int statusCode, [
    String? serverMessage,
    Map<String, String> fieldErrors = const {},
  ]) {
    final message = serverMessage ?? _defaultMessage(statusCode);
    return ApiException(
        message: message, statusCode: statusCode, fieldErrors: fieldErrors);
  }

  factory ApiException.noInternet() =>
      const ApiException(message: 'No internet connection. Please check your network.');

  factory ApiException.timeout() =>
      const ApiException(message: 'Request timed out. Please try again.');

  factory ApiException.unexpected() =>
      const ApiException(message: 'An unexpected error occurred. Please try again.');

  static String _defaultMessage(int code) => switch (code) {
        400 => 'Bad request. Please check your input.',
        401 => 'Invalid credentials.',
        403 => 'Access denied.',
        404 => 'Resource not found.',
        422 => 'Validation failed. Please check your input.',
        429 => 'Too many requests. Please slow down.',
        500 => 'Server error. Please try again later.',
        _ => 'Something went wrong (Error $code).',
      };

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
