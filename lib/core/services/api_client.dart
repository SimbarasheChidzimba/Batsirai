import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/config/app_config.dart';
import 'secure_storage_service.dart';

/// API Client using Dio with interceptors for authentication
class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient(this._secureStorage) {
    // Use safe base URL (prevents placeholder URLs)
    final baseUrl = AppConfig.safeBaseUrl;
    // Log the base URL being used
    print('🔧 API Client initialized with baseUrl: $baseUrl');
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configure SSL certificate validation
    // For development: Allow bad certificates (hostname mismatch, self-signed, etc.)
    // For production: Use strict validation
    final allowBadCertificates = bool.fromEnvironment(
      'ALLOW_BAD_CERTIFICATES',
      defaultValue: false,
    ) || !bool.fromEnvironment('dart.vm.product');

    if (allowBadCertificates) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // In development, allow bad certificates
          // WARNING: This is insecure and should only be used in development
          print('⚠️  WARNING: Allowing bad certificate for $host:$port');
          print('   Certificate: ${cert.subject}');
          return true;
        };
        return client;
      };
    }

    // Add request interceptor to attach auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log the full URL being called
          final fullUrl = '${options.baseUrl}${options.path}';
          print('🌐 API Request: ${options.method} $fullUrl');
          print('   Base URL: ${options.baseUrl}');
          print('   Path: ${options.path}');
          print('   Full URL: $fullUrl');
          if (options.data != null) {
            print('📤 Request Data: ${options.data}');
          }
          print('📋 Headers: ${options.headers}');
          
          final token = await _secureStorage.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Log detailed error information
          final fullUrl = '${error.requestOptions.baseUrl}${error.requestOptions.path}';
          print('❌ API Error Interceptor:');
          print('  Full URL: $fullUrl');
          print('  Method: ${error.requestOptions.method}');
          print('  Type: ${error.type}');
          print('  Message: ${error.message}');
          print('  Error: ${error.error}');
          print('  Response: ${error.response?.data}');
          print('  Status Code: ${error.response?.statusCode}');
          print('  Request Data: ${error.requestOptions.data}');
          
          // Handle 401 unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // TODO: Handle token refresh or logout
          }
          return handler.next(error);
        },
      ),
    );

    // Add logger in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;
}
