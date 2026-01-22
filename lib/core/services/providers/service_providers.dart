import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../secure_storage_service.dart';
import '../api_client.dart';

/// Secure storage service provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});
