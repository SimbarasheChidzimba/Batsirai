/// App configuration for environment variables
/// Base URL can be set via --dart-define or defaults to production
class AppConfig {
  // Base URL from dart-define or default
  // Note: If BASE_URL is not set, use the production API URL
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://batsirai-stable.vercel.app/api/v1',
  );
  
  // Ensure we never use placeholder URLs
  static String get safeBaseUrl {
    final url = baseUrl;
    if (url.contains('your-api.com') || url.contains('example.com')) {
      print('⚠️  WARNING: Placeholder URL detected, using production URL');
      return 'https://batsirai-stable.vercel.app/api/v1';
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
  
  // API endpoints - Membership
  static const String membershipTiers = '/membership/tiers';
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
}
