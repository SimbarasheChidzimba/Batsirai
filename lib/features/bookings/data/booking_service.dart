import '../domain/booking.dart';
import 'package:uuid/uuid.dart';

/// Service layer for booking operations
/// This can be easily replaced with API calls when backend is ready
class BookingService {
  static const _uuid = Uuid();

  /// Create a restaurant booking
  /// TODO: Replace with API call: POST /api/bookings/restaurant
  static Future<RestaurantBooking> createRestaurantBooking({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required DateTime bookingDate,
    required DateTime bookingTime,
    required int partySize,
    String? specialRequests,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with actual API call
    // final response = await dio.post('/api/bookings/restaurant', data: {
    //   'userId': userId,
    //   'restaurantId': restaurantId,
    //   'bookingDate': bookingDate.toIso8601String(),
    //   'bookingTime': bookingTime.toIso8601String(),
    //   'partySize': partySize,
    //   'specialRequests': specialRequests,
    // });
    // return RestaurantBooking.fromJson(response.data);

    return RestaurantBooking(
      id: _uuid.v4(),
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

  /// Create an event booking (ticket purchase)
  /// TODO: Replace with API call: POST /api/bookings/event
  static Future<EventBooking> createEventBooking({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
    required List<EventTicket> tickets,
    required double totalAmount,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with actual API call
    // final response = await dio.post('/api/bookings/event', data: {
    //   'userId': userId,
    //   'eventId': eventId,
    //   'tickets': tickets.map((t) => t.toJson()).toList(),
    //   'totalAmount': totalAmount,
    // });
    // return EventBooking.fromJson(response.data);

    return EventBooking(
      id: _uuid.v4(),
      userId: userId,
      eventId: eventId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      tickets: tickets,
      totalAmount: totalAmount,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      confirmationCode: _generateConfirmationCode(),
      qrCode: _generateQRCodeData(userId, eventId),
    );
  }

  /// Get user's restaurant bookings
  /// TODO: Replace with API call: GET /api/bookings/restaurant?userId={userId}
  static Future<List<RestaurantBooking>> getRestaurantBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with actual API call
    return [];
  }

  /// Get user's event bookings
  /// TODO: Replace with API call: GET /api/bookings/event?userId={userId}
  static Future<List<EventBooking>> getEventBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with actual API call
    return [];
  }

  /// Cancel a restaurant booking
  /// TODO: Replace with API call: PUT /api/bookings/restaurant/{id}/cancel
  static Future<void> cancelRestaurantBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with actual API call
    // await dio.put('/api/bookings/restaurant/$bookingId/cancel');
  }

  /// Cancel an event booking
  /// TODO: Replace with API call: PUT /api/bookings/event/{id}/cancel
  static Future<void> cancelEventBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with actual API call
    // await dio.put('/api/bookings/event/$bookingId/cancel');
  }

  static String _generateConfirmationCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 6);
  }

  static String _generateQRCodeData(String userId, String eventId) {
    // Generate QR code data for event entry
    return 'EVENT:$eventId:USER:$userId:${DateTime.now().millisecondsSinceEpoch}';
  }
}
