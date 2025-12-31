import '../restaurants/domain/restaurant.dart';

class MockRestaurantData {
  static final List<Restaurant> restaurants = [
    // Fine Dining
    Restaurant(
      id: '1',
      name: 'Victoria 22',
      description: 'Elegant fine dining with contemporary cuisine and stunning ambiance. Known for exceptional service and exquisite dishes.',
      images: [
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      category: RestaurantCategory.fineDining,
      priceLevel: PriceLevel.luxury,
      rating: 4.8,
      reviewCount: 342,
      address: 'Sam Nujoma Street, Harare',
      latitude: -17.8252,
      longitude: 31.0335,
      phoneNumber: '+263 242 123456',
      cuisineTypes: ['Contemporary', 'International', 'Fusion'],
      amenities: ['Parking', 'WiFi', 'Bar', 'Private Dining', 'Outdoor Seating'],
      openingHours: {
        'Monday': '11:00 - 23:00',
        'Tuesday': '11:00 - 23:00',
        'Wednesday': '11:00 - 23:00',
        'Thursday': '11:00 - 23:00',
        'Friday': '11:00 - 00:00',
        'Saturday': '11:00 - 00:00',
        'Sunday': '11:00 - 22:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: false,
      isPremiumPartner: true,
      discount: 15.0,
      specialOffer: '2-for-1 on main courses (Mon-Thu)',
    ),
    
    Restaurant(
      id: '2',
      name: 'Amanzi Restaurant',
      description: 'Fusion cuisine with a creative twist. Award-winning chef serving innovative dishes in a sophisticated setting.',
      images: [
        'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
        'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
      ],
      category: RestaurantCategory.fineDining,
      priceLevel: PriceLevel.expensive,
      rating: 4.7,
      reviewCount: 289,
      address: 'Borrowdale Road, Harare',
      latitude: -17.7869,
      longitude: 31.0672,
      phoneNumber: '+263 242 234567',
      cuisineTypes: ['Fusion', 'Modern African', 'International'],
      amenities: ['Parking', 'WiFi', 'Bar', 'Wheelchair Accessible'],
      openingHours: {
        'Monday': 'Closed',
        'Tuesday': '12:00 - 22:30',
        'Wednesday': '12:00 - 22:30',
        'Thursday': '12:00 - 22:30',
        'Friday': '12:00 - 23:00',
        'Saturday': '12:00 - 23:00',
        'Sunday': '12:00 - 21:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      isPremiumPartner: true,
      discount: 20.0,
    ),

    // Asian Cuisine
    Restaurant(
      id: '3',
      name: 'Shangri-La',
      description: 'Authentic Chinese and Thai cuisine in an elegant atmosphere. Family-owned restaurant serving traditional recipes.',
      images: [
        'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      category: RestaurantCategory.asian,
      priceLevel: PriceLevel.moderate,
      rating: 4.5,
      reviewCount: 456,
      address: 'Newlands Shopping Centre, Harare',
      latitude: -17.8041,
      longitude: 31.0479,
      phoneNumber: '+263 242 345678',
      cuisineTypes: ['Chinese', 'Thai', 'Asian Fusion'],
      amenities: ['Parking', 'WiFi', 'Takeaway', 'Family Friendly'],
      openingHours: {
        'Monday': '11:00 - 22:00',
        'Tuesday': '11:00 - 22:00',
        'Wednesday': '11:00 - 22:00',
        'Thursday': '11:00 - 22:00',
        'Friday': '11:00 - 23:00',
        'Saturday': '11:00 - 23:00',
        'Sunday': '11:00 - 21:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      isPremiumPartner: true,
      discount: 10.0,
      specialOffer: 'Free spring rolls with orders over \$25',
    ),

    Restaurant(
      id: '4',
      name: 'Tongfu Chinese Restaurant',
      description: 'Traditional Chinese restaurant offering dim sum, noodles, and authentic Szechuan dishes.',
      images: [
        'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
      ],
      category: RestaurantCategory.asian,
      priceLevel: PriceLevel.moderate,
      rating: 4.3,
      reviewCount: 198,
      address: 'Avondale, Harare',
      latitude: -17.8011,
      longitude: 31.0419,
      phoneNumber: '+263 242 456789',
      cuisineTypes: ['Chinese', 'Dim Sum', 'Szechuan'],
      amenities: ['Parking', 'Takeaway', 'Private Dining'],
      openingHours: {
        'Monday': '10:30 - 22:00',
        'Tuesday': '10:30 - 22:00',
        'Wednesday': '10:30 - 22:00',
        'Thursday': '10:30 - 22:00',
        'Friday': '10:30 - 23:00',
        'Saturday': '10:30 - 23:00',
        'Sunday': '10:30 - 21:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      discount: 15.0,
    ),

    // Seafood
    Restaurant(
      id: '5',
      name: 'The Fishmonger',
      description: 'Fresh seafood daily. Specializing in grilled fish, prawns, and calamari with ocean-inspired ambiance.',
      images: [
        'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800',
        'https://images.unsplash.com/photo-1534604973900-c43ab4c2e0ab?w=800',
      ],
      category: RestaurantCategory.seafood,
      priceLevel: PriceLevel.expensive,
      rating: 4.6,
      reviewCount: 287,
      address: 'Ballantyne Park, Harare',
      latitude: -17.8176,
      longitude: 31.0612,
      phoneNumber: '+263 242 567890',
      cuisineTypes: ['Seafood', 'Mediterranean', 'Grills'],
      amenities: ['Parking', 'Bar', 'Outdoor Seating', 'WiFi'],
      openingHours: {
        'Monday': '11:30 - 22:00',
        'Tuesday': '11:30 - 22:00',
        'Wednesday': '11:30 - 22:00',
        'Thursday': '11:30 - 22:30',
        'Friday': '11:30 - 23:00',
        'Saturday': '11:30 - 23:00',
        'Sunday': '11:30 - 21:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: false,
      isPremiumPartner: true,
      discount: 20.0,
    ),

    // Traditional African
    Restaurant(
      id: '6',
      name: 'Organikks',
      description: 'Organic farm-to-table dining featuring fresh local produce and traditional Zimbabwean dishes with a modern twist.',
      images: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      ],
      category: RestaurantCategory.traditional,
      priceLevel: PriceLevel.moderate,
      rating: 4.4,
      reviewCount: 213,
      address: 'Groombridge, Harare',
      latitude: -17.7958,
      longitude: 31.0598,
      phoneNumber: '+263 242 678901',
      cuisineTypes: ['Traditional', 'African', 'Organic'],
      amenities: ['Parking', 'Garden Seating', 'Family Friendly', 'Vegetarian Options'],
      openingHours: {
        'Monday': '08:00 - 20:00',
        'Tuesday': '08:00 - 20:00',
        'Wednesday': '08:00 - 20:00',
        'Thursday': '08:00 - 20:00',
        'Friday': '08:00 - 21:00',
        'Saturday': '08:00 - 21:00',
        'Sunday': '08:00 - 19:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      discount: 10.0,
      specialOffer: 'Sunday brunch special - \$12',
    ),

    // Casual Dining
    Restaurant(
      id: '7',
      name: "Paula's Place",
      description: 'Cozy casual dining with home-style cooking. Known for hearty breakfasts and comfortable atmosphere.',
      images: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      category: RestaurantCategory.casual,
      priceLevel: PriceLevel.moderate,
      rating: 4.5,
      reviewCount: 567,
      address: 'Mount Pleasant, Harare',
      latitude: -17.7892,
      longitude: 31.0534,
      phoneNumber: '+263 242 789012',
      cuisineTypes: ['Breakfast', 'Brunch', 'Comfort Food'],
      amenities: ['Parking', 'WiFi', 'Outdoor Seating', 'Kid Friendly'],
      openingHours: {
        'Monday': '07:00 - 17:00',
        'Tuesday': '07:00 - 17:00',
        'Wednesday': '07:00 - 17:00',
        'Thursday': '07:00 - 17:00',
        'Friday': '07:00 - 20:00',
        'Saturday': '07:00 - 20:00',
        'Sunday': '07:00 - 17:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      isPremiumPartner: true,
      discount: 15.0,
    ),

    Restaurant(
      id: '8',
      name: 'La Parada',
      description: 'Mediterranean-inspired cuisine with Spanish and Italian influences. Great tapas and wine selection.',
      images: [
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      ],
      category: RestaurantCategory.casual,
      priceLevel: PriceLevel.moderate,
      rating: 4.6,
      reviewCount: 321,
      address: 'Borrowdale, Harare',
      latitude: -17.7823,
      longitude: 31.0689,
      phoneNumber: '+263 242 890123',
      cuisineTypes: ['Mediterranean', 'Spanish', 'Tapas'],
      amenities: ['Parking', 'Bar', 'WiFi', 'Outdoor Seating'],
      openingHours: {
        'Monday': '11:00 - 22:00',
        'Tuesday': '11:00 - 22:00',
        'Wednesday': '11:00 - 22:00',
        'Thursday': '11:00 - 22:30',
        'Friday': '11:00 - 23:30',
        'Saturday': '11:00 - 23:30',
        'Sunday': '11:00 - 21:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      discount: 10.0,
    ),

    // Cafes
    Restaurant(
      id: '9',
      name: 'Cafe Nush',
      description: 'Artisan coffee shop with fresh pastries and light meals. Perfect spot for meetings or relaxation.',
      images: [
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
      ],
      category: RestaurantCategory.cafe,
      priceLevel: PriceLevel.budget,
      rating: 4.7,
      reviewCount: 892,
      address: 'Avondale, Harare',
      latitude: -17.8023,
      longitude: 31.0445,
      phoneNumber: '+263 242 901234',
      cuisineTypes: ['Coffee', 'Pastries', 'Light Meals'],
      amenities: ['WiFi', 'Outdoor Seating', 'Vegan Options', 'Work Friendly'],
      openingHours: {
        'Monday': '07:00 - 18:00',
        'Tuesday': '07:00 - 18:00',
        'Wednesday': '07:00 - 18:00',
        'Thursday': '07:00 - 18:00',
        'Friday': '07:00 - 19:00',
        'Saturday': '07:00 - 19:00',
        'Sunday': '08:00 - 17:00',
      },
      isOpen: true,
      acceptsReservations: false,
      hasDelivery: true,
      isPremiumPartner: true,
      discount: 25.0,
      specialOffer: 'Buy 5 coffees, get 1 free',
    ),

    Restaurant(
      id: '10',
      name: 'The Smokehouse',
      description: 'American-style BBQ and grills. Famous for ribs, burgers, and craft beer selection.',
      images: [
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      ],
      category: RestaurantCategory.casual,
      priceLevel: PriceLevel.moderate,
      rating: 4.5,
      reviewCount: 434,
      address: 'Sam Levy Village, Harare',
      latitude: -17.7845,
      longitude: 31.0712,
      phoneNumber: '+263 242 012345',
      cuisineTypes: ['BBQ', 'American', 'Grills'],
      amenities: ['Parking', 'Bar', 'Sports TV', 'Outdoor Seating'],
      openingHours: {
        'Monday': '11:00 - 22:00',
        'Tuesday': '11:00 - 22:00',
        'Wednesday': '11:00 - 22:00',
        'Thursday': '11:00 - 23:00',
        'Friday': '11:00 - 00:00',
        'Saturday': '11:00 - 00:00',
        'Sunday': '11:00 - 22:00',
      },
      isOpen: true,
      acceptsReservations: true,
      hasDelivery: true,
      discount: 15.0,
      specialOffer: 'Happy Hour: 4-7pm daily',
    ),
  ];

  static List<Restaurant> getNearbyRestaurants(double lat, double lng, {double radiusKm = 10.0}) {
    // In production, this would calculate actual distances
    // For mock data, return all restaurants
    return restaurants;
  }

  static List<Restaurant> getFeaturedRestaurants() {
    return restaurants.where((r) => r.isPremiumPartner).toList();
  }

  static List<Restaurant> getRestaurantsByCategory(RestaurantCategory category) {
    return restaurants.where((r) => r.category == category).toList();
  }

  static Restaurant? getRestaurantById(String id) {
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
