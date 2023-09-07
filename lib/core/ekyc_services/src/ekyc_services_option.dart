import 'package:dio/dio.dart';

/// Configure Ekyc service
class EkycServicesOptions {
  EkycServicesOptions({
    required this.serverUrl,
    required this.httpOptions,
    this.interceptors = const [],
  });

  /// Url to your [Node Server]
  final String serverUrl;

  /// Configuration options for http client.
  /// Set timeout using [connectTimeout] and [recieveTimeout]
  final BaseOptions httpOptions;

  /// Interceptors to be added during init.
  /// For retry interceptor or logging
  final List<Interceptor> interceptors;
}
