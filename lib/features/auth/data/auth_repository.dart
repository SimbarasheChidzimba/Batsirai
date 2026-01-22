import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../features/auth/domain/user.dart';
import 'models/auth_models.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  /// Register a new user
  /// Returns the registered user and auth token
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required bool isDiaspora,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'isDiaspora': isDiaspora,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        
        // Extract data object - API returns {success: true, data: {...}, message: "..."}
        final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
        
        // Save token if provided (check both data.token and top-level token)
        final token = data['token']?.toString() ?? responseData['token']?.toString();
        if (token != null) {
          await _secureStorage.saveAuthToken(token);
        }
        if (data['refreshToken'] != null || responseData['refreshToken'] != null) {
          await _secureStorage.saveRefreshToken(
            (data['refreshToken'] ?? responseData['refreshToken']).toString()
          );
        }
        
        // Save user ID (check userId, id, or _id)
        final userId = data['userId']?.toString() ?? 
                       data['id']?.toString() ?? 
                       data['_id']?.toString() ??
                       responseData['userId']?.toString();
        if (userId != null) {
          await _secureStorage.saveUserId(userId);
        }

        // Parse user data from the data object
        final user = _parseUserFromResponse(data);
        
        return AuthResponse.success(
          user: user, 
          token: token,
        );
      } else {
        final data = response.data as Map<String, dynamic>? ?? {};
        return AuthResponse.error(
          message: data['message']?.toString() ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Login user
  /// Returns the user and auth token
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        
        print('🔐 Login Response Data:');
        print('   Full response: $responseData');
        
        // Extract data object - API returns {success: true, data: {...}, message: "..."}
        final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
        print('   Data object: $data');
        
        // Save token if provided (check both data.token and top-level token)
        final token = data['token']?.toString() ?? responseData['token']?.toString();
        if (token != null) {
          await _secureStorage.saveAuthToken(token);
        }
        if (data['refreshToken'] != null || responseData['refreshToken'] != null) {
          await _secureStorage.saveRefreshToken(
            (data['refreshToken'] ?? responseData['refreshToken']).toString()
          );
        }
        
        // Save user ID (check userId, id, or _id)
        final userId = data['userId']?.toString() ?? 
                       data['id']?.toString() ?? 
                       data['_id']?.toString() ??
                       responseData['userId']?.toString();
        if (userId != null) {
          await _secureStorage.saveUserId(userId);
        }

        // Parse user data from the data object
        print('📦 Parsing user from: $data');
        final user = _parseUserFromResponse(data);
        print('✅ Parsed user:');
        print('   ID: ${user.id}');
        print('   Email: ${user.email}');
        print('   DisplayName: ${user.displayName}');
        print('   PhoneNumber: ${user.phoneNumber}');
        
        return AuthResponse.success(
          user: user, 
          token: token,
        );
      } else {
        final data = response.data as Map<String, dynamic>? ?? {};
        return AuthResponse.error(
          message: data['message']?.toString() ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponse.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  /// Get current user from stored token
  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.getUserId();
    if (userId == null) return null;
    
    // TODO: Fetch user details from API if needed
    // For now, return null and let the app fetch on login
    return null;
  }

  /// Parse user from API response
  User _parseUserFromResponse(Map<String, dynamic> data) {
    print('🔍 Parsing user from response:');
    print('   Available keys: ${data.keys.toList()}');
    print('   userId: ${data['userId']}');
    print('   fullName: ${data['fullName']}');
    print('   name: ${data['name']}');
    print('   displayName: ${data['displayName']}');
    print('   email: ${data['email']}');
    print('   phoneNumber: ${data['phoneNumber']}');
    
    // Try multiple field names for user ID
    final userId = data['userId']?.toString() ?? 
                   data['id']?.toString() ?? 
                   data['_id']?.toString() ?? 
                   '';
    
    // Try multiple field names for display name
    final displayName = data['fullName'] ?? 
                        data['name'] ?? 
                        data['displayName'] ?? 
                        data['full_name'] ??
                        '';
    
    // Try multiple field names for email
    final email = data['email']?.toString() ?? '';
    
    // Try multiple field names for phone
    final phoneNumber = data['phoneNumber']?.toString() ?? 
                        data['phone']?.toString() ?? 
                        '';
    
    print('   Final userId: $userId');
    print('   Final displayName: $displayName');
    print('   Final email: $email');
    print('   Final phoneNumber: $phoneNumber');
    
    return User(
      id: userId,
      email: email,
      phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
      displayName: displayName.isNotEmpty ? displayName.toString() : null,
      userType: data['isDiaspora'] == true ? UserType.diaspora : UserType.local,
      membershipTier: _parseMembershipTier(data['membershipTier']),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  MembershipTier _parseMembershipTier(dynamic tier) {
    if (tier == null) return MembershipTier.free;
    final tierString = tier.toString().toLowerCase();
    switch (tierString) {
      case 'localbasic':
      case 'local_basic':
        return MembershipTier.localBasic;
      case 'localplus':
      case 'local_plus':
        return MembershipTier.localPlus;
      case 'localpremium':
      case 'local_premium':
        return MembershipTier.localPremium;
      case 'diasporabasic':
      case 'diaspora_basic':
        return MembershipTier.diasporaBasic;
      case 'diasporaplus':
      case 'diaspora_plus':
        return MembershipTier.diasporaPlus;
      case 'diasporavip':
      case 'diaspora_vip':
        return MembershipTier.diasporaVip;
      default:
        return MembershipTier.free;
    }
  }

  /// Handle Dio errors and return user-friendly messages
  AuthResponse _handleDioError(DioException error) {
    String message;
    int? statusCode;

    // Log the error for debugging
    print('DioError Type: ${error.type}');
    print('DioError Message: ${error.message}');
    print('DioError Response: ${error.response?.data}');
    print('DioError Status Code: ${error.response?.statusCode}');

    if (error.response != null) {
      statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      // Handle different error formats
      if (data is Map<String, dynamic>) {
        // Check for nested error structure (e.g., {error: {message: "..."}})
        if (data['error'] is Map<String, dynamic>) {
          final errorObj = data['error'] as Map<String, dynamic>;
          message = errorObj['message']?.toString() ?? 
                    errorObj['code']?.toString() ??
                    'Request failed';
          
          // Include validation details if present
          if (errorObj['details'] is Map<String, dynamic>) {
            final details = errorObj['details'] as Map<String, dynamic>;
            final detailMessages = details.values.map((v) => v.toString()).join(', ');
            if (detailMessages.isNotEmpty) {
              message = '$message: $detailMessages';
            }
          }
        } else {
          message = data['message']?.toString() ?? 
                    data['error']?.toString() ?? 
                    data['errors']?.toString() ??
                    'Request failed';
        }
      } else if (data is String) {
        // Check if it's HTML (404 page) or actual error message
        if (data.contains('<!DOCTYPE') || data.contains('<html')) {
          message = _getErrorMessageFromStatusCode(statusCode!);
        } else {
          message = data;
        }
      } else {
        message = _getErrorMessageFromStatusCode(statusCode!);
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout ||
               error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection. Please check your network.';
    } else if (error.type == DioExceptionType.unknown) {
      // Handle unknown errors (often SSL, network, or unreachable server)
      final errorMessage = error.message ?? '';
      final errorObj = error.error?.toString() ?? '';
      
      // Check for SSL certificate errors
      if (errorMessage.contains('CERTIFICATE_VERIFY_FAILED') || 
          errorMessage.contains('HandshakeException') ||
          errorObj.contains('CERTIFICATE_VERIFY_FAILED') ||
          errorObj.contains('HandshakeException')) {
        message = 'SSL certificate error. Please contact support if this persists.';
      } else if (errorMessage.isNotEmpty) {
        message = 'Connection error: ${errorMessage.split('\n').first}';
      } else if (errorObj.isNotEmpty) {
        message = 'Connection error: ${errorObj.split('\n').first}';
      } else {
        message = 'Unable to connect to server. Please check your internet connection and try again.';
      }
    } else if (error.type == DioExceptionType.badResponse) {
      message = 'Server returned an invalid response. Please try again.';
    } else if (error.type == DioExceptionType.cancel) {
      message = 'Request was cancelled.';
    } else {
      message = 'An error occurred: ${error.message ?? error.error?.toString() ?? "Unknown error"}. Please try again.';
    }

    return AuthResponse.error(
      message: message,
      statusCode: statusCode,
    );
  }

  String _getErrorMessageFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'API endpoint not found. Please check the server configuration or contact support.';
      case 409:
        return 'User already exists with this email.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
