import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/event.dart';
import '../../data/providers/events_repository_provider.dart';

// All events provider - fetches from API
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  try {
    print('🔄 eventsProvider: Fetching events...');
    final repository = ref.watch(eventsRepositoryProvider);
    final events = await repository.listEvents();
    print('✅ eventsProvider: Got ${events.length} events');
    return events;
  } catch (e, stack) {
    print('❌ eventsProvider Error: $e');
    print('   Stack: $stack');
    rethrow;
  }
});

// Upcoming events provider - filters from API data
final upcomingEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) {
      print('🔄 upcomingEventsProvider: Filtering ${events.length} events');
      final now = DateTime.now();
      final filtered = events.where((e) => 
        e.status == EventStatus.upcoming && 
        e.startDate.isAfter(now)
      ).toList();
      print('✅ upcomingEventsProvider: ${filtered.length} upcoming events');
      return AsyncValue.data(filtered);
    },
    loading: () {
      print('⏳ upcomingEventsProvider: Loading...');
      return const AsyncValue.loading();
    },
    error: (error, stack) {
      print('❌ upcomingEventsProvider Error: $error');
      print('   Stack: $stack');
      return AsyncValue.error(error, stack);
    },
  );
});

// Featured events provider - filters from API data
final featuredEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) => events.where((e) => e.isFeatured).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Today's events provider - filters from API data
final todayEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) => events.where((e) => e.isToday).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// This weekend events provider - filters from API data
final thisWeekendEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) => events.where((e) => e.isThisWeekend).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Event by ID provider - fetches from API
final eventByIdProvider = FutureProvider.family<Event?, String>((ref, id) async {
  try {
    final repository = ref.watch(eventsRepositoryProvider);
    return await repository.getEventDetail(id);
  } catch (e) {
    // If API fails, fallback to checking cached events list
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(
      data: (events) => events.where((e) => e.id == id).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );
  }
});

// Events by category provider
final eventsByCategoryProvider = Provider.family<List<Event>, EventCategory>(
  (ref, category) {
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(
      data: (events) => events.where((e) => e.category == category).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Nearby events provider - filters from API data by location
final nearbyEventsProvider = FutureProvider.family<List<Event>, (double, double)>(
  (ref, location) async {
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(
      data: (events) {
        // Simple distance calculation (can be improved with proper geolocation)
        final userLat = location.$1;
        final userLng = location.$2;
        
        // Filter events within reasonable distance (e.g., 50km)
        return events.where((e) {
          final distance = _calculateDistance(
            userLat, userLng, 
            e.latitude, e.longitude
          );
          return distance <= 50.0; // 50km radius
        }).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Helper function to calculate distance between two coordinates (Haversine formula)
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * (math.pi / 180.0);

// Event search query provider
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered events provider
final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(upcomingEventsProvider);
  final searchQuery = ref.watch(eventSearchQueryProvider);
  final selectedCategories = ref.watch(selectedEventCategoriesProvider);
  final selectedDateFilter = ref.watch(selectedDateFilterProvider);

  return eventsAsync.when(
    data: (events) {
      var filtered = List<Event>.from(events);

      // Search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((e) =>
                e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.venueName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase())))
            .toList();
      }

      // Category filter
      if (selectedCategories.isNotEmpty) {
        filtered = filtered.where((e) => selectedCategories.contains(e.category)).toList();
      }

      // Date filter
      if (selectedDateFilter != null) {
        filtered = _filterByDateRange(filtered, selectedDateFilter);
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Helper function to filter by date range
List<Event> _filterByDateRange(List<Event> events, EventDateFilter filter) {
  final now = DateTime.now();
  
  switch (filter) {
    case EventDateFilter.today:
      return events.where((e) => e.isToday).toList();
    
    case EventDateFilter.tomorrow:
      return events.where((e) => e.isTomorrow).toList();
    
    case EventDateFilter.thisWeekend:
      return events.where((e) => e.isThisWeekend).toList();
    
    case EventDateFilter.thisWeek:
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      return events.where((e) => e.startDate.isBefore(endOfWeek)).toList();
    
    case EventDateFilter.thisMonth:
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      return events.where((e) => e.startDate.isBefore(endOfMonth)).toList();
  }
}

// Filter enums and providers
enum EventDateFilter {
  today,
  tomorrow,
  thisWeekend,
  thisWeek,
  thisMonth,
}

final selectedEventCategoriesProvider = StateProvider<List<EventCategory>>((ref) => []);
final selectedDateFilterProvider = StateProvider<EventDateFilter?>((ref) => null);

// Provider to extract available categories from API events
final availableEventCategoriesProvider = Provider<List<EventCategory>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) {
      // Extract unique categories from events
      final categories = events.map((e) => e.category).toSet().toList();
      // Sort by category name for consistent display
      categories.sort((a, b) {
        final eventA = Event(
          id: '',
          title: '',
          description: '',
          images: [],
          category: a,
          status: EventStatus.upcoming,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          venueName: '',
          venueAddress: '',
          latitude: 0,
          longitude: 0,
          ticketTiers: [],
        );
        final eventB = Event(
          id: '',
          title: '',
          description: '',
          images: [],
          category: b,
          status: EventStatus.upcoming,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          venueName: '',
          venueAddress: '',
          latitude: 0,
          longitude: 0,
          ticketTiers: [],
        );
        return eventA.categoryName.compareTo(eventB.categoryName);
      });
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
