import 'package:flutter/material.dart';

/// App-wide constants for Batsirai
class AppConstants {
  // App Info
  static const String appName = 'Batsirai';
  static const String appTagline = 'Discover. Book. Experience.';
  static const String appVersion = '1.0.0';

  // API Configuration (mock for now)
  static const String baseUrl = 'https://api.batsirai.co.zw/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Location Defaults (Harare, Zimbabwe)
  static const double defaultLatitude = -17.8292;
  static const double defaultLongitude = 31.0522;
  static const double searchRadiusKm = 25.0;

  // Pagination
  static const int itemsPerPage = 20;
  static const int initialLoadCount = 10;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 2);
  static const Duration locationCacheDuration = Duration(minutes: 10);

  // Map Configuration
  static const double mapZoomLevel = 14.0;
  static const double mapMaxZoom = 18.0;
  static const double mapMinZoom = 10.0;

  // Booking
  static const int maxPartySize = 20;
  static const int minPartySize = 1;
  static const int bookingAdvanceDays = 60;
  static const List<int> partySizeOptions = [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 20];

  // Time Slots
  static const List<String> timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00', '22:30', '23:00'
  ];

  // Membership Tiers
  static const Map<String, double> localMembershipPrices = {
    'basic': 5.00,
    'standard': 7.00,
    'premium': 10.00,
  };

  static const Map<String, double> diasporaMembershipPrices = {
    'basic': 4.99,
    'standard': 9.99,
    'premium': 17.99,
  };

  // Restaurant Categories
  static const List<String> restaurantCategories = [
    'All',
    'Fine Dining',
    'Casual Dining',
    'Fast Food',
    'African Cuisine',
    'Asian Cuisine',
    'Italian',
    'Chinese',
    'Thai',
    'Indian',
    'BBQ & Grill',
    'Seafood',
    'Vegetarian',
    'Cafe',
    'Bakery',
    'Traditional',
  ];

  // Event Categories
  static const List<String> eventCategories = [
    'All',
    'Concerts',
    'Festivals',
    'Sports',
    'Comedy',
    'Theatre',
    'Art & Culture',
    'Networking',
    'Workshops',
    'Family',
    'Nightlife',
    'Food & Drink',
    'Wellness',
    'Corporate',
  ];

  // Price Levels
  static const List<String> priceLevels = [
    '\$',      // Budget
    '\$\$',    // Moderate
    '\$\$\$',  // Expensive
    '\$\$\$\$', // Very Expensive
  ];

  // Distance Units
  static const String distanceUnit = 'km';
  static const double kmToMiles = 0.621371;

  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const double ratingStep = 0.5;

  // Images
  static const String placeholderImage = 'https://via.placeholder.com/400x300.png?text=Batsirai';
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration locationDebounce = Duration(seconds: 2);

  // Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyMembershipTier = 'membership_tier';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyFavoriteRestaurants = 'favorite_restaurants';
  static const String keyFavoriteEvents = 'favorite_events';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyLastLocation = 'last_location';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/batsirai';
  static const String instagramUrl = 'https://instagram.com/batsirai';
  static const String twitterUrl = 'https://twitter.com/batsirai';
  static const String whatsappNumber = '+263771234567';

  // Support
  static const String supportEmail = 'support@batsirai.co.zw';
  static const String supportPhone = '+263771234567';

  // Payment
  static const String paynowMerchantId = 'your_merchant_id';
  static const List<String> supportedCurrencies = ['USD', 'GBP', 'EUR'];
  static const String defaultCurrency = 'USD';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxReviewLength = 500;
  static const int minReviewLength = 10;

  // Limits
  static const int maxFavorites = 100;
  static const int maxRecentSearches = 10;
  static const int maxPhotosPerReview = 5;

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String locationError = 'Unable to get your location. Please enable location services.';
  static const String permissionError = 'Permission denied. Please grant the required permissions.';
}

// Spacing constants
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border radius constants
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  // Success Messages
  static const String bookingSuccess = 'Booking confirmed! Check your email for details.';
  static const String reviewSuccess = 'Thank you for your review!';
  static const String membershipSuccess = 'Welcome to Batsirai Premium!';

  // Zimbabwean Cities
  static const List<Map<String, dynamic>> cities = [
    {'name': 'Harare', 'lat': -17.8292, 'lng': 31.0522},
    {'name': 'Bulawayo', 'lat': -20.1672, 'lng': 28.5831},
    {'name': 'Mutare', 'lat': -18.9707, 'lng': 32.6710},
    {'name': 'Gweru', 'lat': -19.4500, 'lng': 29.8167},
    {'name': 'Victoria Falls', 'lat': -17.9243, 'lng': 25.8567},
  ];

  // Venues (Popular in Zimbabwe)
  static const List<String> popularVenues = [
    'Harare International Conference Centre',
    'Harare Gardens',
    'Harare Hippodrome',
    'Rainbow Towers',
    'Borrowdale Race Course',
    'Belgravia Sports Club',
    'Celebration Centre',
    'The Venue Avondale',
  ];
}
