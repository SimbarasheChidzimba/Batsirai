import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/event.dart';
import '../data/mock_event_data.dart';

// All events provider
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return MockEventData.events;
});

// Upcoming events provider
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return MockEventData.getUpcomingEvents();
});

// Featured events provider
final featuredEventsProvider = FutureProvider<List<Event>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockEventData.getFeaturedEvents();
});

// Today's events provider
final todayEventsProvider = FutureProvider<List<Event>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockEventData.getTodayEvents();
});

// This weekend events provider
final thisWeekendEventsProvider = FutureProvider<List<Event>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockEventData.getThisWeekendEvents();
});

// Event by ID provider
final eventByIdProvider = Provider.family<Event?, String>((ref, id) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.when(
    data: (events) => events.where((e) => e.id == id).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
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

// Nearby events provider
final nearbyEventsProvider = FutureProvider.family<List<Event>, (double, double)>(
  (ref, location) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockEventData.getNearbyEvents(location.$1, location.$2);
  },
);

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
      var filtered = events;

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
