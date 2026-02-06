/// App configuration for environment variables
/// Base URL can be set via --dart-define or defaults to production
class AppConfig {
  // Base URL from dart-define or default
  // Note: If BASE_URL is not set, use the production API URL
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://batsirai-stable-git-transition-delvins-projects-3ac4b61e.vercel.app/api/v1',
  );
  
  // Ensure we never use placeholder URLs
  static String get safeBaseUrl {
    final url = baseUrl;
    if (url.contains('your-api.com') || url.contains('example.com')) {
      print('⚠️  WARNING: Placeholder URL detected, using production URL');
    //  return 'https://batsirai-stable.vercel.app/api/v1';
      return 'https://batsirai-stable-git-transition-delvins-projects-3ac4b61e.vercel.app/api/v1';
    }
    return url;
  }
  
  // Debug: Print base URL on first access
  static String get baseUrlWithLog {
    print('📌 AppConfig.baseUrl = $baseUrl');
    return baseUrl;
  }

  // API endpoints - Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  
  // API endpoints - Events
  static const String eventsList = '/events';
  static String eventDetail(String id) => '/events/$id';
  
  // API endpoints - Restaurants
  static String restaurantsList({
    int? page,
    int? limit,
    String? category,
    String? location,
  }) {
    final q = <String>[];
    if (page != null) q.add('page=$page');
    if (limit != null) q.add('limit=$limit');
    if (category != null && category.isNotEmpty) q.add('category=${Uri.encodeComponent(category)}');
    if (location != null && location.isNotEmpty) q.add('location=${Uri.encodeComponent(location)}');
    return q.isEmpty ? '/restaurants' : '/restaurants?${q.join('&')}';
  }

  static String restaurantDetail(String id) => '/restaurants/$id';
  static String restaurantMenu(String id) => '/restaurants/$id/menu';
  static String restaurantAvailability(String id, String date, int partySize) =>
      '/restaurants/$id/availability?date=$date&partySize=$partySize';

  // API endpoints - Reviews
  static String restaurantReviews(String restaurantId) =>
      '/reviews/restaurant/$restaurantId';
  static const String reviewsSubmit = '/reviews';

  // API endpoints - Favorites
  static const String favoritesCreate = '/favorites';
  static String favoritesList(String type) => '/favorites?type=$type';

  // API endpoints - Bookings (new lifecycle: create request → pay commitment → ticket)
  static const String bookingCreate = '/bookings/create';
  static String bookingPay(String id) => '/bookings/$id/pay';
  static String bookingTicket(String id) => '/bookings/$id/ticket';
  static const String createRestaurantBooking = '/bookings/restaurants'; // legacy
  static String listBookings({int page = 1, int limit = 20}) =>
      '/bookings?page=$page&limit=$limit';
  static String bookingDetail(String id) => '/bookings/$id';
  static String updateBooking(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String deleteBooking(String id) => '/bookings/$id';
  
  // API endpoints - Membership
  static const String membershipTiers = '/membership/tiers';

  // API endpoints - Tickets
  static const String ticketsPurchase = '/tickets/purchase';
  static const String ticketsMyTickets = '/tickets/my-tickets';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
}
