import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/booking.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/booking_service.dart';

// Restaurant Bookings State
class RestaurantBookingsNotifier extends StateNotifier<AsyncValue<List<RestaurantBooking>>> {
  RestaurantBookingsNotifier() : super(const AsyncValue.loading()) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    state = const AsyncValue.loading();
    try {
      // TODO: Replace with actual user ID from auth
      final bookings = await BookingService.getRestaurantBookings('');
      state = AsyncValue.data(bookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBooking(RestaurantBooking booking) async {
    try {
      final currentBookings = state.value ?? [];
      state = AsyncValue.data([...currentBookings, booking]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await BookingService.cancelRestaurantBooking(bookingId);
      final currentBookings = state.value ?? [];
      state = AsyncValue.data(
        currentBookings.map((booking) {
          if (booking.id == bookingId) {
            return booking.copyWith(status: BookingStatus.cancelled);
          }
          return booking;
        }).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => _loadBookings();
}

final restaurantBookingsProvider =
    StateNotifierProvider<RestaurantBookingsNotifier, AsyncValue<List<RestaurantBooking>>>((ref) {
  return RestaurantBookingsNotifier();
});

// Event Bookings State
class EventBookingsNotifier extends StateNotifier<AsyncValue<List<EventBooking>>> {
  EventBookingsNotifier() : super(const AsyncValue.loading()) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    state = const AsyncValue.loading();
    try {
      // TODO: Replace with actual user ID from auth
      final bookings = await BookingService.getEventBookings('');
      state = AsyncValue.data(bookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBooking(EventBooking booking) async {
    try {
      final currentBookings = state.value ?? [];
      state = AsyncValue.data([...currentBookings, booking]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await BookingService.cancelEventBooking(bookingId);
      final currentBookings = state.value ?? [];
      state = AsyncValue.data(
        currentBookings.map((booking) {
          if (booking.id == bookingId) {
            return booking.copyWith(status: BookingStatus.cancelled);
          }
          return booking;
        }).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => _loadBookings();
}

final eventBookingsProvider =
    StateNotifierProvider<EventBookingsNotifier, AsyncValue<List<EventBooking>>>((ref) {
  return EventBookingsNotifier();
});

// Legacy provider for backward compatibility (restaurant bookings only)
final bookingsProvider =
    StateNotifierProvider<RestaurantBookingsNotifier, AsyncValue<List<RestaurantBooking>>>((ref) {
  return RestaurantBookingsNotifier();
});

// User's restaurant bookings provider
final userRestaurantBookingsProvider = Provider<AsyncValue<List<RestaurantBooking>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final bookingsAsync = ref.watch(restaurantBookingsProvider);
  
  if (user == null) {
    return const AsyncValue.data([]);
  }
  
  return bookingsAsync.when(
    data: (bookings) => AsyncValue.data(
      bookings.where((b) => b.userId == user.id).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// User's event bookings provider
final userEventBookingsProvider = Provider<AsyncValue<List<EventBooking>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final bookingsAsync = ref.watch(eventBookingsProvider);
  
  if (user == null) {
    return const AsyncValue.data([]);
  }
  
  return bookingsAsync.when(
    data: (bookings) => AsyncValue.data(
      bookings.where((b) => b.userId == user.id).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Combined upcoming bookings (restaurant + event)
final upcomingBookingsProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final restaurantBookingsAsync = ref.watch(userRestaurantBookingsProvider);
  final eventBookingsAsync = ref.watch(userEventBookingsProvider);
  
  return restaurantBookingsAsync.when(
    data: (restaurantBookings) {
      return eventBookingsAsync.when(
        data: (eventBookings) {
          final now = DateTime.now();
          final upcoming = <dynamic>[];
          
          // Add upcoming restaurant bookings
          upcoming.addAll(
            restaurantBookings.where((b) =>
              b.status == BookingStatus.confirmed &&
              b.bookingDate.isAfter(now),
            ),
          );
          
          // Add upcoming event bookings
          upcoming.addAll(
            eventBookings.where((b) =>
              b.status == BookingStatus.confirmed &&
              b.eventDate.isAfter(now),
            ),
          );
          
          // Sort by date
          upcoming.sort((a, b) {
            final dateA = a is RestaurantBooking ? a.bookingDate : (a as EventBooking).eventDate;
            final dateB = b is RestaurantBooking ? b.bookingDate : (b as EventBooking).eventDate;
            return dateA.compareTo(dateB);
          });
          
          return AsyncValue.data(upcoming);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Combined past bookings (restaurant + event)
final pastBookingsProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final restaurantBookingsAsync = ref.watch(userRestaurantBookingsProvider);
  final eventBookingsAsync = ref.watch(userEventBookingsProvider);
  
  return restaurantBookingsAsync.when(
    data: (restaurantBookings) {
      return eventBookingsAsync.when(
        data: (eventBookings) {
          final now = DateTime.now();
          final past = <dynamic>[];
          
          // Add past restaurant bookings
          past.addAll(
            restaurantBookings.where((b) =>
              b.bookingDate.isBefore(now) || b.status == BookingStatus.completed,
            ),
          );
          
          // Add past event bookings
          past.addAll(
            eventBookings.where((b) =>
              b.eventDate.isBefore(now) || b.status == BookingStatus.completed,
            ),
          );
          
          // Sort by date (most recent first)
          past.sort((a, b) {
            final dateA = a is RestaurantBooking ? a.bookingDate : (a as EventBooking).eventDate;
            final dateB = b is RestaurantBooking ? b.bookingDate : (b as EventBooking).eventDate;
            return dateB.compareTo(dateA);
          });
          
          return AsyncValue.data(past);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Legacy providers for backward compatibility
final userBookingsProvider = Provider<List<RestaurantBooking>>((ref) {
  final bookingsAsync = ref.watch(userRestaurantBookingsProvider);
  return bookingsAsync.when(
    data: (bookings) => bookings,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Helper function for creating restaurant booking (uses service)
Future<RestaurantBooking> createRestaurantBooking({
  required String userId,
  required String restaurantId,
  required String restaurantName,
  required DateTime bookingDate,
  required DateTime bookingTime,
  required int partySize,
  String? specialRequests,
}) async {
  return await BookingService.createRestaurantBooking(
    userId: userId,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    bookingDate: bookingDate,
    bookingTime: bookingTime,
    partySize: partySize,
    specialRequests: specialRequests,
  );
}

// Helper function for creating event booking (uses service)
Future<EventBooking> createEventBooking({
  required String userId,
  required String eventId,
  required String eventTitle,
  required DateTime eventDate,
  required List<EventTicket> tickets,
  required double totalAmount,
}) async {
  return await BookingService.createEventBooking(
    userId: userId,
    eventId: eventId,
    eventTitle: eventTitle,
    eventDate: eventDate,
    tickets: tickets,
    totalAmount: totalAmount,
  );
}
