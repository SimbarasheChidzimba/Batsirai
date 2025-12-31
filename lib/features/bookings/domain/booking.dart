import 'package:equatable/equatable.dart';

enum BookingType {
  restaurant,
  event,
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}

class RestaurantBooking extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final DateTime bookingDate;
  final DateTime bookingTime;
  final int partySize;
  final String? specialRequests;
  final BookingStatus status;
  final DateTime createdAt;
  final String? confirmationCode;

  const RestaurantBooking({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.bookingDate,
    required this.bookingTime,
    required this.partySize,
    this.specialRequests,
    required this.status,
    required this.createdAt,
    this.confirmationCode,
  });

  bool get isPast => bookingDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurantId,
        restaurantName,
        bookingDate,
        bookingTime,
        partySize,
        specialRequests,
        status,
        createdAt,
        confirmationCode,
      ];

  RestaurantBooking copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    DateTime? bookingDate,
    DateTime? bookingTime,
    int? partySize,
    String? specialRequests,
    BookingStatus? status,
    DateTime? createdAt,
    String? confirmationCode,
  }) {
    return RestaurantBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      partySize: partySize ?? this.partySize,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }
}

class EventTicket {
  final String ticketTierId;
  final String tierName;
  final double price;
  final int quantity;

  const EventTicket({
    required this.ticketTierId,
    required this.tierName,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}

class EventBooking extends Equatable {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final List<EventTicket> tickets;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final String? qrCode; // QR code for entry
  final String? confirmationCode;

  const EventBooking({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.tickets,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.qrCode,
    this.confirmationCode,
  });

  int get totalTickets =>
      tickets.fold(0, (sum, ticket) => sum + ticket.quantity);

  bool get isPast => eventDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        eventId,
        eventTitle,
        eventDate,
        tickets,
        totalAmount,
        status,
        createdAt,
        qrCode,
        confirmationCode,
      ];

  EventBooking copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? eventTitle,
    DateTime? eventDate,
    List<EventTicket>? tickets,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    String? qrCode,
    String? confirmationCode,
  }) {
    return EventBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDate: eventDate ?? this.eventDate,
      tickets: tickets ?? this.tickets,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      qrCode: qrCode ?? this.qrCode,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }
}
