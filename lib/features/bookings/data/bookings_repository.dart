import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/booking.dart';

/// Repository for booking operations
/// All endpoints require authentication token (handled by ApiClient interceptor)
class BookingsRepository {
  final ApiClient _apiClient;

  BookingsRepository(this._apiClient);

  /// Create reservation request (pending until restaurant confirms)
  /// POST /bookings/create
  /// Body: serviceId, scheduledDate (ISO), timeSlot, attendees, type: "RESTAURANT"
  Future<RestaurantBooking> createReservationRequest({
    required String serviceId,
    required String scheduledDate,
    required String timeSlot,
    required int attendees,
    String type = 'RESTAURANT',
  }) async {
    try {
      print('📡 Creating reservation request: ${AppConfig.bookingCreate}');
      final response = await _apiClient.dio.post(
        AppConfig.bookingCreate,
        data: {
          'serviceId': serviceId,
          'scheduledDate': scheduledDate,
          'timeSlot': timeSlot,
          'attendees': attendees,
          'type': type,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create reservation: ${response.statusCode}');
      }
      final data = response.data;
      Map<String, dynamic> bookingJson;
      if (data is Map<String, dynamic>) {
        bookingJson = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      } else {
        throw Exception('Unexpected response format');
      }
      return _parseRestaurantBookingFromJson(bookingJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Pay commitment fee (returns Stripe checkout URL for in-app WebView)
  /// PATCH /bookings/{bookingId}/pay body: { paymentMethod: "STRIPE" } (backend may require PATCH; POST returns 405)
  Future<String> payCommitmentFee(String bookingId, {String paymentMethod = 'STRIPE'}) async {
    try {
      final path = AppConfig.bookingPay(bookingId);
      print('📡 Pay commitment fee: $path (PATCH)');
      final response = await _apiClient.dio.patch(
        path,
        data: {'paymentMethod': paymentMethod},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to init payment: ${response.statusCode}');
      }
      final data = response.data;
      Map<String, dynamic>? inner;
      if (data is Map<String, dynamic>) {
        inner = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
      }
      if (inner == null) throw Exception('Unexpected response format');
      final url = inner['url']?.toString() ?? inner['checkoutUrl']?.toString() ?? inner['sessionUrl']?.toString();
      if (url == null || url.isEmpty) throw Exception('No checkout URL in response');
      return url;
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        try {
          final path = AppConfig.bookingPay(bookingId);
          final response = await _apiClient.dio.post(path, data: {'paymentMethod': paymentMethod});
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = response.data;
            Map<String, dynamic>? inner;
            if (data is Map<String, dynamic>) {
              inner = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
            }
            final url = inner?['url']?.toString() ?? inner?['checkoutUrl']?.toString() ?? inner?['sessionUrl']?.toString();
            if (url != null && url.isNotEmpty) return url;
          }
        } catch (_) {}
      }
      throw _handleDioError(e);
    }
  }

  /// Get digital ticket (QR) for booking
  /// GET /bookings/{bookingId}/ticket
  Future<Map<String, dynamic>> getBookingTicket(String bookingId) async {
    try {
      print('📡 Get booking ticket: ${AppConfig.bookingTicket(bookingId)}');
      final response = await _apiClient.dio.get(AppConfig.bookingTicket(bookingId));
      if (response.statusCode != 200) throw Exception('Failed to get ticket: ${response.statusCode}');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is Map<String, dynamic>) return data['data'] as Map<String, dynamic>;
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a restaurant table booking (legacy)
  /// POST /bookings/restaurants
  Future<RestaurantBooking> createRestaurantBooking({
    required String restaurantId,
    required String bookingDate,
    required String timeSlot,
    required int partySize,
    String? specialRequests,
  }) async {
    try {
      print('📡 Creating restaurant booking: ${AppConfig.createRestaurantBooking}');
      final response = await _apiClient.dio.post(
        AppConfig.createRestaurantBooking,
        data: {
          'restaurantId': restaurantId,
          'bookingDate': bookingDate,
          'timeSlot': timeSlot,
          'partySize': partySize,
          if (specialRequests != null && specialRequests.isNotEmpty) 'specialRequests': specialRequests,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
      final data = response.data;
      Map<String, dynamic> bookingJson;
      if (data is Map<String, dynamic>) {
        bookingJson = (data['data'] != null && data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      } else {
        throw Exception('Unexpected response format: ${data.runtimeType}');
      }
      return _parseRestaurantBookingFromJson(bookingJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when creating booking: $e');
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  /// List bookings (paginated)
  /// GET /bookings?page=1&limit=20
  /// Returns mix of RestaurantBooking and EventBooking
  Future<List<dynamic>> listBookings({int page = 1, int limit = 20}) async {
    try {
      print('📡 Listing bookings: ${AppConfig.listBookings(page: page, limit: limit)}');
      final response = await _apiClient.dio.get(
        AppConfig.listBookings(page: page, limit: limit),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to list bookings: ${response.statusCode}');
      }

      final data = response.data;
      List<dynamic> rawList = _extractBookingsList(data);
      print('📋 List bookings: raw list length = ${rawList.length}');
      if (rawList.isNotEmpty && rawList.first is Map) {
        print('📋 First item keys: ${(rawList.first as Map).keys.toList()}');
      }

      final result = <dynamic>[];
      for (final raw in rawList) {
        if (raw is! Map<String, dynamic>) continue;
        // Unwrap if nested, e.g. { booking: { ... } } or { data: { ... } }
        final item = raw['booking'] as Map<String, dynamic>? ?? raw['data'] as Map<String, dynamic>? ?? raw;
        try {
          final type = (item['type'] ?? item['bookingType'] ?? item['serviceType'] ?? raw['type'] ?? '').toString().toLowerCase();
          final isRestaurant = type == 'restaurant' ||
              item['restaurantId'] != null || item['restaurant_id'] != null ||
              item['restaurant'] != null;
          final isEvent = type == 'event' || type == 'ticket' ||
              item['eventId'] != null || item['event_id'] != null ||
              item['event'] != null;

          // Prefer explicit type: RESTAURANT + serviceId is still a restaurant booking (not event)
          if (type == 'restaurant' || (isRestaurant && type != 'event' && type != 'ticket')) {
            result.add(_parseRestaurantBookingFromJson(item));
          } else if (isEvent) {
            result.add(_parseEventBookingFromJson(item));
          }
        } catch (e) {
          print('⚠️ Skip parsing booking item: $e');
        }
      }
      print('📋 List bookings: parsed ${result.length} items');
      return result;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, _) {
      print('❌ Exception when listing bookings: $e');
      throw Exception('Failed to list bookings: ${e.toString()}');
    }
  }

  /// Get booking details by ID
  /// GET /bookings/{id}
  /// Requires: auth_token in Authorization header
  Future<Map<String, dynamic>> getBookingDetail(String bookingId) async {
    try {
      print('📡 Fetching booking detail: ${AppConfig.bookingDetail(bookingId)}');
      final response = await _apiClient.dio.get(
        AppConfig.bookingDetail(bookingId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            return data['data'] as Map<String, dynamic>;
          } else {
            return data;
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching booking detail: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch booking detail: ${e.toString()}');
    }
  }

  /// Update booking
  /// PUT /bookings/{id}
  /// Requires: auth_token in Authorization header
  Future<Map<String, dynamic>> updateBooking({
    required String bookingId,
    String? scheduledDate, // ISO 8601 format: "2026-02-16T19:00:00Z"
    int? attendees,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📡 Updating booking: ${AppConfig.updateBooking(bookingId)}');
      
      final requestData = <String, dynamic>{};
      if (scheduledDate != null) requestData['scheduledDate'] = scheduledDate;
      if (attendees != null) requestData['attendees'] = attendees;
      if (metadata != null) requestData['metadata'] = metadata;
      
      final response = await _apiClient.dio.put(
        AppConfig.updateBooking(bookingId),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            return data['data'] as Map<String, dynamic>;
          } else {
            return data;
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to update booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when updating booking: $e');
      print('   Stack: $stack');
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  /// Cancel booking
  /// PATCH /bookings/{id}/cancel
  /// Requires: auth_token in Authorization header
  Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
    String? cancellationReason,
  }) async {
    try {
      print('📡 Cancelling booking: ${AppConfig.cancelBooking(bookingId)}');
      
      final response = await _apiClient.dio.patch(
        AppConfig.cancelBooking(bookingId),
        data: cancellationReason != null
            ? {'cancellationReason': cancellationReason}
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            return data['data'] as Map<String, dynamic>;
          } else {
            return data;
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when cancelling booking: $e');
      print('   Stack: $stack');
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Purchase event tickets (direct payment - creates Stripe checkout session)
  /// POST /tickets/purchase
  /// Returns the Stripe checkout session URL to open in-app
  Future<String> purchaseEventTicket({
    required String serviceId,
    required String scheduledDate, // ISO 8601 e.g. "2026-06-20T19:00:00Z"
    required int attendees,
    required String tierId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📡 Creating ticket purchase (Stripe): ${AppConfig.ticketsPurchase}');
      final body = <String, dynamic>{
        'serviceId': serviceId,
        'scheduledDate': scheduledDate,
        'attendees': attendees,
        'tierId': tierId,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      };
      final response = await _apiClient.dio.post(
        AppConfig.ticketsPurchase,
        data: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create ticket session: ${response.statusCode}');
      }

      final data = response.data;
      Map<String, dynamic>? inner;
      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          inner = data['data'] as Map<String, dynamic>;
        } else {
          inner = data;
        }
      }
      if (inner == null) throw Exception('Unexpected response format');

      // Stripe session URL - common response keys
      final url = inner['url']?.toString() ??
          inner['checkoutUrl']?.toString() ??
          inner['sessionUrl']?.toString() ??
          inner['stripeUrl']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('No checkout URL in response: ${inner.keys}');
      }
      return url;
    } on DioException catch (e) {
      print('❌ DioException when purchasing ticket: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when purchasing ticket: $e');
      print('   Stack: $stack');
      throw Exception('Failed to create ticket payment: ${e.toString()}');
    }
  }

  /// Get my tickets (event tickets purchased by user)
  /// GET /tickets/my-tickets
  Future<List<EventBooking>> getMyTickets() async {
    try {
      print('📡 Fetching my tickets: ${AppConfig.ticketsMyTickets}');
      final response = await _apiClient.dio.get(AppConfig.ticketsMyTickets);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch my tickets: ${response.statusCode}');
      }

      final data = response.data;
      List<dynamic> rawList;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic> && inner['tickets'] is List) {
          rawList = inner['tickets'] as List;
        } else if (inner is List) {
          rawList = inner;
        } else if (data['tickets'] is List) {
          rawList = data['tickets'] as List;
        } else {
          rawList = [];
        }
      } else if (data is List) {
        rawList = data;
      } else {
        rawList = [];
      }

      final result = <EventBooking>[];
      for (final item in rawList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          result.add(_parseEventBookingFromJson(item));
        } catch (e) {
          print('⚠️ Skip parsing ticket item: $e');
        }
      }
      return result;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, _) {
      print('❌ Exception when fetching my tickets: $e');
      throw Exception('Failed to fetch my tickets: ${e.toString()}');
    }
  }

  /// Delete booking
  /// DELETE /bookings/{id}
  /// Requires: auth_token in Authorization header
  Future<void> deleteBooking(String bookingId) async {
    try {
      print('📡 Deleting booking: ${AppConfig.deleteBooking(bookingId)}');
      final response = await _apiClient.dio.delete(
        AppConfig.deleteBooking(bookingId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when deleting booking: $e');
      print('   Stack: $stack');
      throw Exception('Failed to delete booking: ${e.toString()}');
    }
  }

  /// Extract bookings list from API response (supports multiple shapes)
  List<dynamic> _extractBookingsList(dynamic data) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return [];
    final inner = data['data'];
    if (inner is List) return inner;
    if (inner is Map<String, dynamic>) {
      final list = inner['bookings'] ?? inner['items'] ?? inner['results'] ??
          inner['reservations'] ?? inner['list'] ?? inner['content'] ?? inner['data'];
      if (list is List) return list;
    }
    final topList = data['bookings'] ?? data['items'] ?? data['results'] ??
        data['reservations'] ?? data['list'] ?? data['content'];
    if (topList is List) return topList;
    return [];
  }

  /// Parse event booking from JSON
  EventBooking _parseEventBookingFromJson(Map<String, dynamic> json) {
    final eventDateVal = json['eventDate'] ?? json['event_date'];
    final scheduledVal = json['scheduledDate'] ?? json['scheduled_date'];
    final eventDate = eventDateVal != null
        ? DateTime.parse(eventDateVal.toString())
        : scheduledVal != null
            ? DateTime.parse(scheduledVal.toString())
            : json['event']?['startDate'] != null
                ? DateTime.parse(json['event']['startDate'].toString())
                : DateTime.now();

    List<EventTicket> tickets = [];
    if (json['tickets'] is List) {
      for (final t in json['tickets'] as List) {
        if (t is Map<String, dynamic>) {
          tickets.add(EventTicket(
            ticketTierId: t['ticketTierId']?.toString() ?? t['tierId']?.toString() ?? '',
            tierName: t['tierName']?.toString() ?? t['tierName']?.toString() ?? 'Ticket',
            price: (t['price'] as num?)?.toDouble() ?? 0.0,
            quantity: (t['quantity'] as num?)?.toInt() ?? 1,
          ));
        }
      }
    }
    if (tickets.isEmpty && (json['attendees'] != null || json['quantity'] != null)) {
      final qty = (json['attendees'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 1;
      tickets = [
        EventTicket(
          ticketTierId: json['tierId']?.toString() ?? '',
          tierName: json['tierName']?.toString() ?? 'General',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          quantity: qty,
        ),
      ];
    }

    BookingStatus status = BookingStatus.pending;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed':
      case 'active':
        status = BookingStatus.confirmed;
        break;
      case 'cancelled':
      case 'canceled':
        status = BookingStatus.cancelled;
        break;
      case 'completed':
        status = BookingStatus.completed;
        break;
      case 'no_show':
      case 'noshow':
        status = BookingStatus.noShow;
        break;
      default:
        status = BookingStatus.pending;
    }

    return EventBooking(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? json['user']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? json['event_id']?.toString() ?? json['event']?['id']?.toString() ?? json['serviceId']?.toString() ?? json['service_id']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString() ?? json['event_title']?.toString() ?? json['event']?['title']?.toString() ?? 'Event',
      eventDate: eventDate,
      tickets: tickets,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? (json['totalPrice'] as num?)?.toDouble() ?? (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: status,
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']).toString())
          : DateTime.now(),
      qrCode: json['qrCode']?.toString() ?? json['qr_code']?.toString(),
      confirmationCode: json['confirmationCode']?.toString() ?? json['confirmation_code']?.toString() ?? json['confirmation']?.toString(),
    );
  }

  /// Parse restaurant booking from JSON
  RestaurantBooking _parseRestaurantBookingFromJson(Map<String, dynamic> json) {
    final dateVal = json['bookingDate'] ?? json['booking_date'];
    final timeVal = json['timeSlot'] ?? json['time_slot'];
    // Parse booking date and time
    DateTime bookingDate;
    DateTime bookingTime;

    if (dateVal != null && timeVal != null) {
      // Format: bookingDate = "2026-06-25", timeSlot = "19:30"
      final dateStr = dateVal.toString();
      final timeStr = timeVal.toString();
      bookingDate = DateTime.parse(dateStr);
      final timeParts = timeStr.split(':');
      bookingTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } else if (json['scheduledDate'] != null || json['scheduled_date'] != null) {
      final scheduled = DateTime.parse((json['scheduledDate'] ?? json['scheduled_date']).toString());
      bookingDate = DateTime(scheduled.year, scheduled.month, scheduled.day);
      bookingTime = scheduled;
    } else {
      bookingDate = DateTime.now();
      bookingTime = DateTime.now();
    }

    // Parse status
    BookingStatus status = BookingStatus.pending;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed':
      case 'active':
        status = BookingStatus.confirmed;
        break;
      case 'cancelled':
      case 'canceled':
        status = BookingStatus.cancelled;
        break;
      case 'completed':
      case 'finished':
        status = BookingStatus.completed;
        break;
      case 'no_show':
      case 'noshow':
        status = BookingStatus.noShow;
        break;
      default:
        status = BookingStatus.pending;
    }

    return RestaurantBooking(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? json['user']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? json['restaurant_id']?.toString() ??
          json['serviceId']?.toString() ?? json['service_id']?.toString() ?? json['restaurant']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? json['restaurant_name']?.toString() ??
                      json['restaurant']?['name']?.toString() ?? json['serviceName']?.toString() ?? '',
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      partySize: (json['partySize'] as num?)?.toInt() ?? (json['party_size'] as num?)?.toInt() ??
                 (json['attendees'] as num?)?.toInt() ?? 1,
      specialRequests: json['specialRequests']?.toString() ?? json['special_requests']?.toString() ??
                      json['metadata']?['notes']?.toString(),
      status: status,
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']).toString())
          : DateTime.now(),
      confirmationCode: json['confirmationCode']?.toString() ?? json['confirmation_code']?.toString() ??
                        json['confirmation']?.toString(),
    );
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String message = 'Request failed with status $statusCode';
      
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? 
                  data['error']?.toString() ?? 
                  message;
      }
      
      return Exception(message);
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
