import 'package:equatable/equatable.dart';

enum RestaurantCategory {
  fineDining,
  casual,
  fastFood,
  traditional,
  asian,
  african,
  italian,
  seafood,
  vegetarian,
  cafe,
  bakery,
}

enum PriceLevel {
  budget, // $
  moderate, // $$
  expensive, // $$$
  luxury, // $$$$
}

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final RestaurantCategory category;
  final PriceLevel priceLevel;
  final double rating;
  final int reviewCount;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final List<String> cuisineTypes;
  final List<String> amenities;
  final Map<String, String> openingHours;
  final bool isOpen;
  final bool acceptsReservations;
  final bool hasDelivery;
  final bool isPremiumPartner;
  final double? discount; // Percentage discount for members
  final String? specialOffer;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.priceLevel,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.cuisineTypes,
    required this.amenities,
    required this.openingHours,
    required this.isOpen,
    required this.acceptsReservations,
    required this.hasDelivery,
    this.isPremiumPartner = false,
    this.discount,
    this.specialOffer,
  });

  String get priceRange {
    switch (priceLevel) {
      case PriceLevel.budget:
        return '\$';
      case PriceLevel.moderate:
        return '\$\$';
      case PriceLevel.expensive:
        return '\$\$\$';
      case PriceLevel.luxury:
        return '\$\$\$\$';
    }
  }

  String get categoryName {
    switch (category) {
      case RestaurantCategory.fineDining:
        return 'Fine Dining';
      case RestaurantCategory.casual:
        return 'Casual Dining';
      case RestaurantCategory.fastFood:
        return 'Fast Food';
      case RestaurantCategory.traditional:
        return 'Traditional';
      case RestaurantCategory.asian:
        return 'Asian';
      case RestaurantCategory.african:
        return 'African';
      case RestaurantCategory.italian:
        return 'Italian';
      case RestaurantCategory.seafood:
        return 'Seafood';
      case RestaurantCategory.vegetarian:
        return 'Vegetarian';
      case RestaurantCategory.cafe:
        return 'Cafe';
      case RestaurantCategory.bakery:
        return 'Bakery';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        images,
        category,
        priceLevel,
        rating,
        reviewCount,
        address,
        latitude,
        longitude,
        phoneNumber,
        cuisineTypes,
        amenities,
        openingHours,
        isOpen,
        acceptsReservations,
        hasDelivery,
        isPremiumPartner,
        discount,
        specialOffer,
      ];

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    RestaurantCategory? category,
    PriceLevel? priceLevel,
    double? rating,
    int? reviewCount,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    List<String>? cuisineTypes,
    List<String>? amenities,
    Map<String, String>? openingHours,
    bool? isOpen,
    bool? acceptsReservations,
    bool? hasDelivery,
    bool? isPremiumPartner,
    double? discount,
    String? specialOffer,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      priceLevel: priceLevel ?? this.priceLevel,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      amenities: amenities ?? this.amenities,
      openingHours: openingHours ?? this.openingHours,
      isOpen: isOpen ?? this.isOpen,
      acceptsReservations: acceptsReservations ?? this.acceptsReservations,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      isPremiumPartner: isPremiumPartner ?? this.isPremiumPartner,
      discount: discount ?? this.discount,
      specialOffer: specialOffer ?? this.specialOffer,
    );
  }
}
