import 'dart:math';
import 'package:flutter/foundation.dart';

/// Ticket tier for events
@immutable
class TicketTier {
  final String id;
  final String name;
  final String description;
  final double price;
  final int totalAvailable;
  final int remaining;
  final bool isAvailable;
  final Map<String, dynamic>? benefits; // VIP perks, etc.

  const TicketTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.totalAvailable,
    required this.remaining,
    required this.isAvailable,
    this.benefits,
  });

  bool get isSoldOut => remaining <= 0;
  double get percentageSold => ((totalAvailable - remaining) / totalAvailable) * 100;

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      totalAvailable: json['totalAvailable'] as int,
      remaining: json['remaining'] as int,
      isAvailable: json['isAvailable'] as bool,
      benefits: json['benefits'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'totalAvailable': totalAvailable,
      'remaining': remaining,
      'isAvailable': isAvailable,
      'benefits': benefits,
    };
  }
}

/// Event model representing concerts, shows, festivals, etc.
@immutable
class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final List<String> gallery;
  final String venueName;
  final String venueAddress;
  final double latitude;
  final double longitude;
  final String? organizer;
  final String? organizerContact;
  final List<TicketTier> ticketTiers;
  final bool isFree;
  final bool isFeatured;
  final bool isPremium; // Members-only or premium access
  final String? dressCode;
  final int? ageRestriction;
  final int? capacity;
  final int ticketsSold;
  final List<String> performers; // Artists, speakers, etc.
  final String? websiteUrl;
  final Map<String, String>? socialMedia;
  final List<String> amenities; // Parking, Food, etc.
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.gallery,
    required this.venueName,
    required this.venueAddress,
    required this.latitude,
    required this.longitude,
    this.organizer,
    this.organizerContact,
    required this.ticketTiers,
    required this.isFree,
    this.isFeatured = false,
    this.isPremium = false,
    this.dressCode,
    this.ageRestriction,
    this.capacity,
    required this.ticketsSold,
    required this.performers,
    this.websiteUrl,
    this.socialMedia,
    required this.amenities,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated properties
  bool get isSoldOut => ticketTiers.every((tier) => tier.isSoldOut);
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);
  bool get isOngoing => hasStarted && !hasEnded;
  bool get isUpcoming => !hasStarted;
  
  int get daysUntilEvent {
    if (hasStarted) return 0;
    return startDate.difference(DateTime.now()).inDays;
  }

  String get status {
    if (isSoldOut) return 'Sold Out';
    if (hasEnded) return 'Ended';
    if (isOngoing) return 'Happening Now';
    if (daysUntilEvent == 0) return 'Today';
    if (daysUntilEvent == 1) return 'Tomorrow';
    return 'Upcoming';
  }

  double? get lowestPrice {
    if (isFree) return 0.0;
    final availableTiers = ticketTiers.where((t) => t.isAvailable && !t.isSoldOut);
    if (availableTiers.isEmpty) return null;
    return availableTiers.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  double? get highestPrice {
    if (isFree) return 0.0;
    final availableTiers = ticketTiers.where((t) => t.isAvailable);
    if (availableTiers.isEmpty) return null;
    return availableTiers.map((t) => t.price).reduce((a, b) => a > b ? a : b);
  }

  String get priceRange {
    if (isFree) return 'Free';
    final lowest = lowestPrice;
    final highest = highestPrice;
    if (lowest == null || highest == null) return 'N/A';
    if (lowest == highest) return '\$$lowest';
    return '\$$lowest - \$$highest';
  }

  // Calculate distance from user location
  double distanceFrom(double userLat, double userLng) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadians(latitude - userLat);
    final double dLng = _toRadians(longitude - userLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * 3.14159265359 / 180;
  }

  // Check if event matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery) ||
        tags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
        venueName.toLowerCase().contains(lowerQuery) ||
        performers.any((p) => p.toLowerCase().contains(lowerQuery));
  }

  // Copy with method
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    List<String>? gallery,
    String? venueName,
    String? venueAddress,
    double? latitude,
    double? longitude,
    String? organizer,
    String? organizerContact,
    List<TicketTier>? ticketTiers,
    bool? isFree,
    bool? isFeatured,
    bool? isPremium,
    String? dressCode,
    int? ageRestriction,
    int? capacity,
    int? ticketsSold,
    List<String>? performers,
    String? websiteUrl,
    Map<String, String>? socialMedia,
    List<String>? amenities,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      organizer: organizer ?? this.organizer,
      organizerContact: organizerContact ?? this.organizerContact,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      isFree: isFree ?? this.isFree,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremium: isPremium ?? this.isPremium,
      dressCode: dressCode ?? this.dressCode,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      capacity: capacity ?? this.capacity,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      performers: performers ?? this.performers,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMedia: socialMedia ?? this.socialMedia,
      amenities: amenities ?? this.amenities,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List).cast<String>(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      imageUrl: json['imageUrl'] as String,
      gallery: (json['gallery'] as List).cast<String>(),
      venueName: json['venueName'] as String,
      venueAddress: json['venueAddress'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      organizer: json['organizer'] as String?,
      organizerContact: json['organizerContact'] as String?,
      ticketTiers: (json['ticketTiers'] as List)
          .map((t) => TicketTier.fromJson(t))
          .toList(),
      isFree: json['isFree'] as bool,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      dressCode: json['dressCode'] as String?,
      ageRestriction: json['ageRestriction'] as int?,
      capacity: json['capacity'] as int?,
      ticketsSold: json['ticketsSold'] as int,
      performers: (json['performers'] as List).cast<String>(),
      websiteUrl: json['websiteUrl'] as String?,
      socialMedia: json['socialMedia'] != null
          ? Map<String, String>.from(json['socialMedia'])
          : null,
      amenities: (json['amenities'] as List).cast<String>(),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
      'gallery': gallery,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'latitude': latitude,
      'longitude': longitude,
      'organizer': organizer,
      'organizerContact': organizerContact,
      'ticketTiers': ticketTiers.map((t) => t.toJson()).toList(),
      'isFree': isFree,
      'isFeatured': isFeatured,
      'isPremium': isPremium,
      'dressCode': dressCode,
      'ageRestriction': ageRestriction,
      'capacity': capacity,
      'ticketsSold': ticketsSold,
      'performers': performers,
      'websiteUrl': websiteUrl,
      'socialMedia': socialMedia,
      'amenities': amenities,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, startDate: $startDate)';
  }
}
