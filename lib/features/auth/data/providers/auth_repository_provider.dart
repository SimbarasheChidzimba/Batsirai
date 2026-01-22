import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/service_providers.dart';
import '../auth_repository.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient, secureStorage);
});
