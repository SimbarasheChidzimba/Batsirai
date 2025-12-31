import 'package:flutter/foundation.dart';

@immutable
class Booking {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final DateTime bookingDate;
  final String timeSlot;
  final int partySize;
  final String status; // 'confirmed', 'pending', 'cancelled', 'completed'
  final String? specialRequests;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.bookingDate,
    required this.timeSlot,
    required this.partySize,
    required this.status,
    this.specialRequests,
    required this.createdAt,
  });

  bool get isUpcoming => bookingDate.isAfter(DateTime.now()) && status == 'confirmed';
  bool get isPast => bookingDate.isBefore(DateTime.now());
  bool get canCancel => isUpcoming && bookingDate.difference(DateTime.now()).inHours > 2;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    userId: json['userId'],
    restaurantId: json['restaurantId'],
    restaurantName: json['restaurantName'],
    bookingDate: DateTime.parse(json['bookingDate']),
    timeSlot: json['timeSlot'],
    partySize: json['partySize'],
    status: json['status'],
    specialRequests: json['specialRequests'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'bookingDate': bookingDate.toIso8601String(),
    'timeSlot': timeSlot,
    'partySize': partySize,
    'status': status,
    'specialRequests': specialRequests,
    'createdAt': createdAt.toIso8601String(),
  };
}
