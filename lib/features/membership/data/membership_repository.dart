import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/app_config.dart';
import 'models/membership_tier_model.dart';

/// Repository for membership operations
/// All endpoints require authentication token (handled by ApiClient interceptor)
class MembershipRepository {
  final ApiClient _apiClient;

  MembershipRepository(this._apiClient);

  /// Get list of all membership tiers
  /// GET /membership/tiers
  /// Requires: auth_token in Authorization header
  Future<List<MembershipTierModel>> getMembershipTiers() async {
    try {
      print('📡 Fetching membership tiers from API: ${AppConfig.membershipTiers}');
      final response = await _apiClient.dio.get(
        AppConfig.membershipTiers,
      );

      print('✅ Membership Tiers API Response Status: ${response.statusCode}');
      print('📦 Membership Tiers API Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> tiersList;
        if (data is List) {
          // Direct array response
          tiersList = data;
          print('📋 Tiers list (direct): ${tiersList.length} items');
        } else if (data is Map<String, dynamic>) {
          // Check for nested structure: { success: true, data: { tiers: [...] } }
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            final dataObj = data['data'] as Map<String, dynamic>;
            if (dataObj['tiers'] is List) {
              tiersList = dataObj['tiers'] as List;
              print('📋 Tiers list (data.tiers): ${tiersList.length} items');
            } else if (dataObj['data'] is List) {
              tiersList = dataObj['data'] as List;
              print('📋 Tiers list (data.data): ${tiersList.length} items');
            } else {
              print('❌ data object keys: ${dataObj.keys}');
              throw Exception('Unexpected response format in data object: ${dataObj.keys}');
            }
          } else if (data['data'] is List) {
            // { data: [...] }
            tiersList = data['data'] as List;
            print('📋 Tiers list (data key): ${tiersList.length} items');
          } else if (data['tiers'] is List) {
            // { tiers: [...] }
            tiersList = data['tiers'] as List;
            print('📋 Tiers list (tiers key): ${tiersList.length} items');
          } else {
            print('❌ Unexpected response format. Top-level keys: ${data.keys}');
            throw Exception('Unexpected response format: ${data.keys}');
          }
        } else {
          print('❌ Response is not List or Map. Type: ${data.runtimeType}');
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        if (tiersList.isEmpty) {
          print('⚠️  Tiers list is empty');
          return [];
        }

        print('🔄 Parsing ${tiersList.length} membership tiers...');
        final parsedTiers = tiersList
            .map((json) {
              try {
                return MembershipTierModel.fromJson(json as Map<String, dynamic>);
              } catch (e, stack) {
                print('❌ Error parsing tier: $e');
                print('   JSON: $json');
                print('   Stack: $stack');
                rethrow;
              }
            })
            .toList();
        
        print('✅ Successfully parsed ${parsedTiers.length} membership tiers');
        return parsedTiers;
      } else {
        print('❌ Non-200 status code: ${response.statusCode}');
        throw Exception('Failed to fetch membership tiers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException when fetching membership tiers:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching membership tiers: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch membership tiers: ${e.toString()}');
    }
  }

  /// Handle Dio errors and throw user-friendly exceptions
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      String message;
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? 
                  data['error']?.toString() ?? 
                  'Request failed';
      } else if (data is String) {
        message = data;
      } else {
        message = 'Failed to fetch membership tiers (Status: $statusCode)';
      }
      
      return Exception(message);
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network.');
    } else {
      return Exception('An error occurred: ${error.message ?? "Unknown error"}');
    }
  }
}
