# Backend Integration Guide

## Overview
The app is now integrated with the Batsirai backend API. Authentication tokens are securely stored using `flutter_secure_storage`.

## Configuration

### Base URL
The base URL is configured in `lib/core/config/app_config.dart` and can be set via:

1. **Dart Define (Recommended for production):**
   ```bash
   flutter run --dart-define=BASE_URL=https://batsirai-stable.vercel.app/api/v1
   ```

2. **Default value:** The app defaults to `https://batsirai-stable.vercel.app/api/v1` if not specified.

### Environment Variables
To use a different base URL, you can:
- Pass it via `--dart-define` when running
- Modify `app_config.dart` for development

## Architecture

### Service Layer
- **`ApiClient`** - Dio-based HTTP client with interceptors
- **`SecureStorageService`** - Secure storage for auth tokens
- **`AuthRepository`** - Authentication operations

### Storage
- Auth tokens are stored using `flutter_secure_storage`
- Tokens are automatically attached to API requests via interceptors
- Tokens are cleared on logout

## Implemented Endpoints

### 1. Register New User
**Endpoint:** `POST /auth/register`

**Request Body:**
```json
{
  "email": "testuser@example.com",
  "password": "Password12$$",
  "fullName": "Test User",
  "phoneNumber": "+263771296986",
  "isDiaspora": false
}
```

**Response Handling:**
- Success: Saves token, sets user state, navigates to success screen
- Error: Shows user-friendly error message

**Error Codes Handled:**
- 400: Invalid request
- 409: User already exists
- 422: Validation error
- 500: Server error

### 2. User Login
**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "email": "testuser@example.com",
  "password": "Password12$$"
}
```

**Response Handling:**
- Success: Saves token, sets user state, navigates to home
- Error: Shows user-friendly error message

**Error Codes Handled:**
- 401: Invalid credentials
- 400: Invalid request
- 500: Server error

## Error Handling

### Network Errors
- Connection timeout
- No internet connection
- Request timeout

### API Errors
- 400: Invalid request
- 401: Unauthorized (invalid credentials)
- 403: Forbidden
- 404: Not found
- 409: Conflict (user exists)
- 422: Validation error
- 500: Server error
- 503: Service unavailable

All errors are caught and displayed with user-friendly messages.

## Security

### Token Storage
- Tokens are stored using `flutter_secure_storage`
- Android: Uses EncryptedSharedPreferences
- iOS: Uses Keychain with first unlock accessibility
- Tokens are automatically cleared on logout

### API Requests
- Auth token is automatically attached to all requests via interceptor
- Token is sent as: `Authorization: Bearer <token>`

## Usage

### Register User
```dart
final authRepository = ref.read(authRepositoryProvider);
final response = await authRepository.register(
  email: 'user@example.com',
  password: 'Password12$$',
  fullName: 'John Doe',
  phoneNumber: '+263771296986',
  isDiaspora: false,
);

if (response.success) {
  // User registered successfully
  authNotifier.setUser(response.user!);
} else {
  // Handle error
  print(response.message);
}
```

### Login User
```dart
final authRepository = ref.read(authRepositoryProvider);
final response = await authRepository.login(
  email: 'user@example.com',
  password: 'Password12$$',
);

if (response.success) {
  // User logged in successfully
  authNotifier.setUser(response.user!);
} else {
  // Handle error
  print(response.message);
}
```

### Logout
```dart
await ref.read(currentUserProvider.notifier).logout();
```

## Running the App

### With Default Base URL
```bash
flutter run -d emulator-5554
```

### With Custom Base URL
```bash
flutter run -d emulator-5554 --dart-define=BASE_URL=https://your-api.com/api/v1
```

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # Base URL configuration
│   └── services/
│       ├── api_client.dart           # Dio HTTP client
│       ├── secure_storage_service.dart  # Token storage
│       └── providers/
│           └── service_providers.dart    # Service providers
└── features/
    └── auth/
        ├── data/
        │   ├── auth_repository.dart      # Auth API calls
        │   ├── models/
        │   │   └── auth_models.dart      # Request/Response models
        │   └── providers/
        │       └── auth_repository_provider.dart
        └── presentation/
            ├── providers/
            │   └── auth_providers.dart   # State management
            ├── login_screen.dart        # Login UI
            └── signup_screen.dart       # Signup UI
```

## Next Steps

To add more API endpoints:
1. Add endpoint to `app_config.dart`
2. Add method to appropriate repository
3. Use the repository in providers/screens
4. Handle errors appropriately

## Testing

Test the integration:
1. Run the app
2. Try registering a new user
3. Try logging in with credentials
4. Check that tokens are stored securely
5. Verify API requests include auth token

## Notes

- All API calls use proper error handling
- Tokens are automatically managed
- User state is synced with secure storage
- Network errors are handled gracefully
- User-friendly error messages are displayed
