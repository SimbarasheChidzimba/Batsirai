import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/service_providers.dart';
import '../bookings_repository.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingsRepository(apiClient);
});
