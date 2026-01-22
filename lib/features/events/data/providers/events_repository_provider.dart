import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/service_providers.dart';
import '../events_repository.dart';

/// Provider for EventsRepository
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsRepository(apiClient);
});
