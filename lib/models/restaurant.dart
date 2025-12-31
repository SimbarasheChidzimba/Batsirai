import 'dart:math';
import 'package:flutter/foundation.dart';

/// Restaurant model representing a dining establishment
@immutable
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> cuisineTypes;
  final String priceLevel; // $, $$, $$$, $$$$
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> gallery;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String website;
  final Map<String, String> openingHours; // Day -> Hours
  final List<String> amenities; // WiFi, Parking, etc.
  final bool isOpenNow;
  final bool acceptsReservations;
  final bool isPremium; // Premium partner
  final bool isFeatured;
  final double? discount; // Percentage discount for members
  final String? specialOffer;
  final int? capacity;
  final int? averageWaitTime; // in minutes
  final String? menuUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.cuisineTypes,
    required this.priceLevel,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.gallery,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.email = '',
    this.website = '',
    required this.openingHours,
    required this.amenities,
    required this.isOpenNow,
    required this.acceptsReservations,
    this.isPremium = false,
    this.isFeatured = false,
    this.discount,
    this.specialOffer,
    this.capacity,
    this.averageWaitTime,
    this.menuUrl,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate distance from user location
  double distanceFrom(double userLat, double userLng) {
    // Haversine formula for distance calculation
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

  // Check if restaurant matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery) ||
        cuisineTypes.any((c) => c.toLowerCase().contains(lowerQuery)) ||
        address.toLowerCase().contains(lowerQuery);
  }

  // Copy with method
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    List<String>? cuisineTypes,
    String? priceLevel,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? gallery,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? openingHours,
    List<String>? amenities,
    bool? isOpenNow,
    bool? acceptsReservations,
    bool? isPremium,
    bool? isFeatured,
    double? discount,
    String? specialOffer,
    int? capacity,
    int? averageWaitTime,
    String? menuUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      priceLevel: priceLevel ?? this.priceLevel,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      amenities: amenities ?? this.amenities,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      acceptsReservations: acceptsReservations ?? this.acceptsReservations,
      isPremium: isPremium ?? this.isPremium,
      isFeatured: isFeatured ?? this.isFeatured,
      discount: discount ?? this.discount,
      specialOffer: specialOffer ?? this.specialOffer,
      capacity: capacity ?? this.capacity,
      averageWaitTime: averageWaitTime ?? this.averageWaitTime,
      menuUrl: menuUrl ?? this.menuUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      cuisineTypes: (json['cuisineTypes'] as List).cast<String>(),
      priceLevel: json['priceLevel'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String,
      gallery: (json['gallery'] as List).cast<String>(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      openingHours: Map<String, String>.from(json['openingHours']),
      amenities: (json['amenities'] as List).cast<String>(),
      isOpenNow: json['isOpenNow'] as bool,
      acceptsReservations: json['acceptsReservations'] as bool,
      isPremium: json['isPremium'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      discount: json['discount'] as double?,
      specialOffer: json['specialOffer'] as String?,
      capacity: json['capacity'] as int?,
      averageWaitTime: json['averageWaitTime'] as int?,
      menuUrl: json['menuUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'cuisineTypes': cuisineTypes,
      'priceLevel': priceLevel,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'gallery': gallery,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'openingHours': openingHours,
      'amenities': amenities,
      'isOpenNow': isOpenNow,
      'acceptsReservations': acceptsReservations,
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'discount': discount,
      'specialOffer': specialOffer,
      'capacity': capacity,
      'averageWaitTime': averageWaitTime,
      'menuUrl': menuUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, rating: $rating)';
  }
}
