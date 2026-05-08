import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException() : super('No internet connection. Check your network.');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Session expired. Please log in again.');
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message);
}

class UnknownException extends ApiException {
  const UnknownException(super.message);
}

/// Converts a DioException into a typed [ApiException].
ApiException mapDioException(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkException();
  }

  final statusCode = e.response?.statusCode;
  final backendMessage = _extractBackendMessage(e.response?.data);

  if (statusCode == 401) {
    return const UnauthorizedException();
  } else if (statusCode == 403) {
    return ForbiddenException(backendMessage ?? 'Access denied.');
  } else if (statusCode == 404) {
    return NotFoundException(backendMessage ?? 'Resource not found.');
  } else if (statusCode != null && statusCode >= 500) {
    return ServerException(
      backendMessage ?? 'Server error. Please try again later.',
    );
  } else {
    return UnknownException(
      backendMessage ?? 'An unexpected error occurred.',
    );
  }
}

String? _extractBackendMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message'] as String?;
  }
  return null;
}