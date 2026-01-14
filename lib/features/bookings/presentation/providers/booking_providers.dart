import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/booking.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

// Booking state provider
class BookingsNotifier extends StateNotifier<List<RestaurantBooking>> {
  BookingsNotifier() : super([]);

  void addBooking(RestaurantBooking booking) {
    state = [...state, booking];
  }

  void cancelBooking(String bookingId) {
    state = state.map((booking) {
      if (booking.id == bookingId) {
        return booking.copyWith(status: BookingStatus.cancelled);
      }
      return booking;
    }).toList();
  }

  List<RestaurantBooking> getUserBookings(String userId) {
    return state.where((booking) => booking.userId == userId).toList();
  }

  RestaurantBooking? getBookingById(String bookingId) {
    try {
      return state.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<RestaurantBooking>>((ref) {
  return BookingsNotifier();
});

// User's bookings provider
final userBookingsProvider = Provider<List<RestaurantBooking>>((ref) {
  final user = ref.watch(currentUserProvider);
  final bookings = ref.watch(bookingsProvider);
  if (user == null) return [];
  return bookings.where((b) => b.userId == user.id).toList();
});

// Upcoming bookings provider
final upcomingBookingsProvider = Provider<List<RestaurantBooking>>((ref) {
  final bookings = ref.watch(userBookingsProvider);
  final now = DateTime.now();
  return bookings
      .where((b) =>
          b.status == BookingStatus.confirmed &&
          b.bookingDate.isAfter(now))
      .toList()
    ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
});

// Past bookings provider
final pastBookingsProvider = Provider<List<RestaurantBooking>>((ref) {
  final bookings = ref.watch(userBookingsProvider);
  final now = DateTime.now();
  return bookings
      .where((b) => b.bookingDate.isBefore(now) || b.status == BookingStatus.completed)
      .toList()
    ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
});

// Mock function to create booking
Future<RestaurantBooking> createRestaurantBooking({
  required String userId,
  required String restaurantId,
  required String restaurantName,
  required DateTime bookingDate,
  required DateTime bookingTime,
  required int partySize,
  String? specialRequests,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  
  return RestaurantBooking(
    id: uuid.v4(),
    userId: userId,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    bookingDate: bookingDate,
    bookingTime: bookingTime,
    partySize: partySize,
    specialRequests: specialRequests,
    status: BookingStatus.confirmed,
    createdAt: DateTime.now(),
    confirmationCode: _generateConfirmationCode(),
  );
}

String _generateConfirmationCode() {
  final random = DateTime.now().millisecondsSinceEpoch.toString();
  return random.substring(random.length - 6);
}
