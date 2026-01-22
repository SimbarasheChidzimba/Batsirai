import 'package:flutter/material.dart';

/// App color palette following Material Design 3 principles
class AppColors {
  // Primary Colors - Warm Orange (Appetite stimulation)
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryLight = Color(0xFFFF8A50);
  static const Color primaryDark = Color(0xFFD84315);
  static const Color primaryContainer = Color(0xFFFFCCBC);

  // Secondary Colors - Green (Freshness & success)
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF60AD5E);
  static const Color secondaryDark = Color(0xFF005005);
  static const Color secondaryContainer = Color(0xFFC8E6C9);

  // Accent Colors - Amber (Highlights & notifications)
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFFFA000);
  static const Color accentContainer = Color(0xFFFFECB3);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainerLow = Color(0xFFF7F7F7);
  static const Color surfaceContainerHigh = Color(0xFFEEEEEE);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFC8E6C9);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFCDD2);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFE0B2);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoContainer = Color(0xFFBBDEFB);

  // Special Colors
  static const Color rating = Color(0xFFFFC107); // Amber for stars
  static const Color star = Color(0xFFFFC107); // Amber for stars (alias)
  static const Color discount = Color(0xFFE91E63); // Pink for discounts
  static const Color premium = Color(0xFF9C27B0); // Purple for premium features
  static const Color trending = Color(0xFFFF5722); // Orange for trending
  static const Color nearbyDot = Color(0xFF4CAF50); // Green for "near me" indicator
  static const Color imageOverlay = Color(0x80000000); // 50% black overlay for images

  // Price Level Colors
  static const Color priceBudget = Color(0xFF4CAF50);
  static const Color priceModerate = Color(0xFFFFC107);
  static const Color priceExpensive = Color(0xFFFF9800);
  static const Color priceVeryExpensive = Color(0xFFFF5722);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];

  // Event Category Colors
  static const Color eventConcert = Color(0xFFE91E63);
  static const Color eventFestival = Color(0xFFFFC107);
  static const Color eventSports = Color(0xFF4CAF50);
  static const Color eventComedy = Color(0xFFFF9800);
  static const Color eventTheatre = Color(0xFF9C27B0);
  static const Color eventArt = Color(0xFF3F51B5);
  static const Color eventNetworking = Color(0xFF2196F3);
  static const Color eventWorkshop = Color(0xFF009688);
  static const Color eventFamily = Color(0xFFCDDC39);
  static const Color eventNightlife = Color(0xFF673AB7);
  static const Color eventFood = Color(0xFFFF5722);
  static const Color eventWellness = Color(0xFF8BC34A);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xB3000000); // 70% black

  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowMedium = Color(0x33000000); // 20% black
  static const Color shadowDark = Color(0x4D000000); // 30% black

  // Helper Methods
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  static Color getEventCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'concerts':
        return eventConcert;
      case 'festivals':
        return eventFestival;
      case 'sports':
        return eventSports;
      case 'comedy':
        return eventComedy;
      case 'theatre':
        return eventTheatre;
      case 'art & culture':
        return eventArt;
      case 'networking':
        return eventNetworking;
      case 'workshops':
        return eventWorkshop;
      case 'family':
        return eventFamily;
      case 'nightlife':
        return eventNightlife;
      case 'food & drink':
        return eventFood;
      case 'wellness':
        return eventWellness;
      default:
        return primary;
    }
  }

  static Color getPriceLevelColor(String priceLevel) {
    switch (priceLevel) {
      case '\$':
        return priceBudget;
      case '\$\$':
        return priceModerate;
      case '\$\$\$':
        return priceExpensive;
      case '\$\$\$\$':
        return priceVeryExpensive;
      default:
        return priceModerate;
    }
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return success;
    if (rating >= 4.0) return AppColors.rating;
    if (rating >= 3.0) return warning;
    return error;
  }
}
