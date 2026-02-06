import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/booking.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/booking_service.dart';
import '../../data/providers/bookings_repository_provider.dart';

// Booking Service Provider
final bookingServiceProvider = Provider<BookingService>((ref) {
  final repository = ref.watch(bookingsRepositoryProvider);
  return BookingService(repository);
});

// Restaurant Bookings State
class RestaurantBookingsNotifier extends StateNotifier<AsyncValue<List<RestaurantBooking>>> {
  final BookingService _bookingService;
  final Ref _ref;

  RestaurantBookingsNotifier(this._bookingService, this._ref) : super(const AsyncValue.loading()) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final bookings = await _bookingService.getRestaurantBookings(user.id);
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

  Future<void> cancelBooking(String bookingId, {String? cancellationReason}) async {
    try {
      await _bookingService.cancelRestaurantBooking(bookingId, cancellationReason: cancellationReason);
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
  final bookingService = ref.watch(bookingServiceProvider);
  return RestaurantBookingsNotifier(bookingService, ref);
});

// Event Bookings State
class EventBookingsNotifier extends StateNotifier<AsyncValue<List<EventBooking>>> {
  final BookingService _bookingService;
  final Ref _ref;

  EventBookingsNotifier(this._bookingService, this._ref) : super(const AsyncValue.loading()) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final bookings = await _bookingService.getEventBookings(user.id);
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

  Future<void> cancelBooking(String bookingId, {String? cancellationReason}) async {
    try {
      await _bookingService.cancelEventBooking(bookingId, cancellationReason: cancellationReason);
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
  final bookingService = ref.watch(bookingServiceProvider);
  return EventBookingsNotifier(bookingService, ref);
});

// Legacy provider for backward compatibility (restaurant bookings only)
final bookingsProvider =
    StateNotifierProvider<RestaurantBookingsNotifier, AsyncValue<List<RestaurantBooking>>>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return RestaurantBookingsNotifier(bookingService, ref);
});

// My tickets provider - GET /tickets/my-tickets
final myTicketsProvider = FutureProvider<List<EventBooking>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final bookingService = ref.read(bookingServiceProvider);
  return await bookingService.getMyTickets();
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
          final todayStart = DateTime(now.year, now.month, now.day);
          final upcoming = <dynamic>[];
          
          // Add upcoming restaurant bookings: pending (always show) or confirmed/completed with date today or future
          upcoming.addAll(
            restaurantBookings.where((b) {
              if (b.status == BookingStatus.pending) return true;
              if (b.status != BookingStatus.confirmed && b.status != BookingStatus.completed) return false;
              return !b.bookingDate.isBefore(todayStart);
            }),
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
  required BookingService bookingService,
}) async {
  return await bookingService.createRestaurantBooking(
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
  required BookingService bookingService,
}) async {
  return await bookingService.createEventBooking(
    userId: userId,
    eventId: eventId,
    eventTitle: eventTitle,
    eventDate: eventDate,
    tickets: tickets,
    totalAmount: totalAmount,
  );
}

// Pending booking data provider - stores booking data when user needs to login first
final pendingBookingDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
