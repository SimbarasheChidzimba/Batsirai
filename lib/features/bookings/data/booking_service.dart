import '../domain/booking.dart';
import 'package:uuid/uuid.dart';
import 'bookings_repository.dart';

/// Service layer for booking operations
/// Uses BookingsRepository for API calls
class BookingService {
  static const _uuid = Uuid();
  final BookingsRepository? _repository;

  BookingService(this._repository);

  /// Create a restaurant booking
  /// POST /bookings/restaurants
  Future<RestaurantBooking> createRestaurantBooking({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required DateTime bookingDate,
    required DateTime bookingTime,
    required int partySize,
    String? specialRequests,
  }) async {
    final repository = _repository;
    if (repository != null) {
      // Format date as "YYYY-MM-DD"
      final dateStr = '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}';
      // Format time as "HH:MM"
      final timeStr = '${bookingTime.hour.toString().padLeft(2, '0')}:${bookingTime.minute.toString().padLeft(2, '0')}';
      
      return await repository.createRestaurantBooking(
        restaurantId: restaurantId,
        bookingDate: dateStr,
        timeSlot: timeStr,
        partySize: partySize,
        specialRequests: specialRequests,
      );
    }

    // Fallback to mock if repository not available
    await Future.delayed(const Duration(seconds: 1));
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
  /// TODO: Implement event booking API endpoint when available
  Future<EventBooking> createEventBooking({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
    required List<EventTicket> tickets,
    required double totalAmount,
  }) async {
    // TODO: Replace with actual API call when endpoint is available
    // For now, use mock implementation
    await Future.delayed(const Duration(seconds: 1));

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

  /// Get user's restaurant bookings from list bookings API
  Future<List<RestaurantBooking>> getRestaurantBookings(String userId) async {
    final repository = _repository;
    if (repository != null) {
      final all = await repository.listBookings(page: 1, limit: 100);
      return all.whereType<RestaurantBooking>().toList();
    }
    return [];
  }

  /// Get user's event bookings from list bookings API
  Future<List<EventBooking>> getEventBookings(String userId) async {
    final repository = _repository;
    if (repository != null) {
      final all = await repository.listBookings(page: 1, limit: 100);
      return all.whereType<EventBooking>().toList();
    }
    return [];
  }

  /// Get my tickets (event tickets) from GET /tickets/my-tickets
  Future<List<EventBooking>> getMyTickets() async {
    final repository = _repository;
    if (repository != null) {
      return await repository.getMyTickets();
    }
    return [];
  }

  /// Cancel a restaurant booking
  /// PATCH /bookings/{id}/cancel
  Future<void> cancelRestaurantBooking(String bookingId, {String? cancellationReason}) async {
    final repository = _repository;
    if (repository != null) {
      await repository.cancelBooking(
        bookingId: bookingId,
        cancellationReason: cancellationReason,
      );
      return;
    }
    
    // Fallback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Cancel an event booking
  /// PATCH /bookings/{id}/cancel
  Future<void> cancelEventBooking(String bookingId, {String? cancellationReason}) async {
    final repository = _repository;
    if (repository != null) {
      await repository.cancelBooking(
        bookingId: bookingId,
        cancellationReason: cancellationReason,
      );
      return;
    }
    
    // Fallback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Update a booking
  /// PUT /bookings/{id}
  Future<Map<String, dynamic>> updateBooking({
    required String bookingId,
    DateTime? scheduledDate,
    int? attendees,
    Map<String, dynamic>? metadata,
  }) async {
    final repository = _repository;
    if (repository != null) {
      return await repository.updateBooking(
        bookingId: bookingId,
        scheduledDate: scheduledDate?.toIso8601String(),
        attendees: attendees,
        metadata: metadata,
      );
    }
    
    throw Exception('BookingsRepository not available');
  }

  /// Delete a booking
  /// DELETE /bookings/{id}
  Future<void> deleteBooking(String bookingId) async {
    final repository = _repository;
    if (repository != null) {
      await repository.deleteBooking(bookingId);
      return;
    }
    
    throw Exception('BookingsRepository not available');
  }

  /// Get booking details
  /// GET /bookings/{id}
  Future<Map<String, dynamic>> getBookingDetail(String bookingId) async {
    final repository = _repository;
    if (repository != null) {
      return await repository.getBookingDetail(bookingId);
    }
    
    throw Exception('BookingsRepository not available');
  }

  /// Create reservation request (restaurant confirms later; then user pays commitment fee)
  /// POST /bookings/create
  Future<RestaurantBooking> createReservationRequest({
    required String serviceId,
    required DateTime scheduledDate,
    required String timeSlot,
    required int attendees,
    String type = 'RESTAURANT',
  }) async {
    final repository = _repository;
    if (repository != null) {
      final scheduledStr = scheduledDate.toUtc().toIso8601String();
      return await repository.createReservationRequest(
        serviceId: serviceId,
        scheduledDate: scheduledStr,
        timeSlot: timeSlot,
        attendees: attendees,
        type: type,
      );
    }
    throw Exception('BookingsRepository not available');
  }

  /// Pay commitment fee for a booking (returns Stripe checkout URL for in-app WebView)
  /// POST /bookings/{bookingId}/pay
  Future<String> payCommitmentFee(String bookingId, {String paymentMethod = 'STRIPE'}) async {
    final repository = _repository;
    if (repository != null) {
      return await repository.payCommitmentFee(bookingId, paymentMethod: paymentMethod);
    }
    throw Exception('BookingsRepository not available');
  }

  /// Get digital ticket (QR) for a booking
  /// GET /bookings/{bookingId}/ticket
  Future<Map<String, dynamic>> getBookingTicket(String bookingId) async {
    final repository = _repository;
    if (repository != null) {
      return await repository.getBookingTicket(bookingId);
    }
    throw Exception('BookingsRepository not available');
  }

  /// Purchase event ticket (direct payment - Stripe checkout)
  /// POST /tickets/purchase - returns Stripe session URL for in-app WebView
  Future<String> purchaseEventTicket({
    required String serviceId,
    required DateTime scheduledDate,
    required int attendees,
    required String tierId,
    Map<String, dynamic>? metadata,
  }) async {
    final repository = _repository;
    if (repository != null) {
      final scheduledStr = scheduledDate.toUtc().toIso8601String();
      return await repository.purchaseEventTicket(
        serviceId: serviceId,
        scheduledDate: scheduledStr,
        attendees: attendees,
        tierId: tierId,
        metadata: metadata,
      );
    }
    throw Exception('BookingsRepository not available');
  }

  String _generateConfirmationCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 6);
  }

  String _generateQRCodeData(String userId, String eventId) {
    // Generate QR code data for event entry
    return 'EVENT:$eventId:USER:$userId:${DateTime.now().millisecondsSinceEpoch}';
  }
}
