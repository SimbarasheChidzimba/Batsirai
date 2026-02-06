import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/service_providers.dart';
import '../restaurants_repository.dart';

final restaurantsRepositoryProvider = Provider<RestaurantsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RestaurantsRepository(apiClient);
});
