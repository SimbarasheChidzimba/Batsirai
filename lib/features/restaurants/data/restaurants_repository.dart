import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/restaurant.dart';

/// Repository for restaurants operations
/// All endpoints require authentication token (handled by ApiClient interceptor)
class RestaurantsRepository {
  final ApiClient _apiClient;

  RestaurantsRepository(this._apiClient);

  /// Get list of restaurants (search & list with optional category, location)
  /// GET /restaurants?category=Fine Dining&location=Harare
  /// Requires: auth_token in Authorization header
  Future<List<Restaurant>> listRestaurants({
    int? page,
    int? limit,
    String? category,
    String? location,
  }) async {
    try {
      final path = AppConfig.restaurantsList(page: page, limit: limit, category: category, location: location);
      print('📡 Fetching restaurants from API: $path');
      await Future.delayed(const Duration(milliseconds: 300));
      final response = await _apiClient.dio.get(path);

      print('✅ Restaurants API Response Status: ${response.statusCode}');
      print('📦 Restaurants API Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> restaurantsList;
        if (data is List) {
          restaurantsList = data;
          print('📋 Restaurants list (direct): ${restaurantsList.length} items');
        } else if (data is Map<String, dynamic>) {
          // Check for nested structure: { success: true, data: { restaurants: [...] } }
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            final dataObj = data['data'] as Map<String, dynamic>;
            if (dataObj['restaurants'] is List) {
              restaurantsList = dataObj['restaurants'] as List;
              print('📋 Restaurants list (data.restaurants): ${restaurantsList.length} items');
            } else if (dataObj['data'] is List) {
              restaurantsList = dataObj['data'] as List;
              print('📋 Restaurants list (data.data): ${restaurantsList.length} items');
            } else {
              print('❌ data object keys: ${dataObj.keys}');
              throw Exception('Unexpected response format in data object: ${dataObj.keys}');
            }
          } else if (data['data'] is List) {
            restaurantsList = data['data'] as List;
            print('📋 Restaurants list (data key): ${restaurantsList.length} items');
          } else if (data['restaurants'] is List) {
            restaurantsList = data['restaurants'] as List;
            print('📋 Restaurants list (restaurants key): ${restaurantsList.length} items');
          } else {
            print('❌ Unexpected response format. Top-level keys: ${data.keys}');
            throw Exception('Unexpected response format: ${data.keys}');
          }
        } else {
          print('❌ Response is not List or Map. Type: ${data.runtimeType}');
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        if (restaurantsList.isEmpty) {
          print('⚠️  Restaurants list is empty');
          return [];
        }

        print('🔄 Parsing ${restaurantsList.length} restaurants...');
        final parsedRestaurants = <Restaurant>[];
        for (var json in restaurantsList) {
          try {
            final restaurant = _parseRestaurantFromJson(json as Map<String, dynamic>);
            parsedRestaurants.add(restaurant);
          } catch (e, stack) {
            print('❌ Error parsing restaurant, skipping: $e');
            print('   JSON: $json');
            print('   Stack: $stack');
            // Continue parsing other restaurants instead of failing completely
          }
        }
        
        print('✅ Successfully parsed ${parsedRestaurants.length} of ${restaurantsList.length} restaurants');
        if (parsedRestaurants.isEmpty && restaurantsList.isNotEmpty) {
          throw Exception('Failed to parse any restaurants from API response');
        }
        return parsedRestaurants;
      } else {
        print('❌ Non-200 status code: ${response.statusCode}');
        throw Exception('Failed to fetch restaurants: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException when fetching restaurants:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching restaurants: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch restaurants: ${e.toString()}');
    }
  }

  /// Get restaurant details by ID
  /// GET /restaurants/{id}
  /// Requires: auth_token in Authorization header
  Future<Restaurant> getRestaurantDetail(String restaurantId) async {
    try {
      print('📡 Fetching restaurant detail from API: ${AppConfig.restaurantDetail(restaurantId)}');
      print('   Restaurant ID: $restaurantId');
      // Add minimum delay to show loading state (remove in production if not needed)
      await Future.delayed(const Duration(milliseconds: 500));
      final response = await _apiClient.dio.get(
        AppConfig.restaurantDetail(restaurantId),
      );

      print('✅ Restaurant Detail API Response Status: ${response.statusCode}');
      print('📦 Restaurant Detail API Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle empty or null response
        if (data == null) {
          print('⚠️  API returned null/empty response');
          throw Exception('Restaurant not found: API returned empty response');
        }
        
        // Handle different response formats
        Map<String, dynamic> restaurantJson;
        if (data is Map<String, dynamic>) {
          print('📋 Response keys: ${data.keys}');
          
          // Check for nested structure: { success: true, data: { restaurant: {...} } }
          if (data['data'] != null) {
            if (data['data'] is Map<String, dynamic>) {
              final dataObj = data['data'] as Map<String, dynamic>;
              print('📋 Data object keys: ${dataObj.keys}');
              
              // Check if data contains a restaurant object
              if (dataObj['restaurant'] != null && dataObj['restaurant'] is Map<String, dynamic>) {
                restaurantJson = dataObj['restaurant'] as Map<String, dynamic>;
                print('✅ Found restaurant in data.restaurant');
              } else {
                // Data object itself is the restaurant
                restaurantJson = dataObj;
                print('✅ Using data object as restaurant');
              }
            } else {
              print('❌ data is not a Map: ${data['data'].runtimeType}');
              throw Exception('Unexpected response format: data is not a Map');
            }
          } else {
            // Top level is the restaurant object
            restaurantJson = data;
            print('✅ Using top-level data as restaurant');
          }
        } else {
          print('❌ Response is not a Map. Type: ${data.runtimeType}');
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        // Validate that we have a restaurant with at least an ID
        if (restaurantJson.isEmpty || (restaurantJson['id'] == null && restaurantJson['_id'] == null)) {
          print('⚠️  Restaurant JSON is empty or missing ID');
          throw Exception('Restaurant not found: Invalid restaurant data');
        }

        print('🔄 Parsing restaurant JSON...');
        print('   Restaurant JSON keys: ${restaurantJson.keys}');
        print('   Restaurant ID in JSON: ${restaurantJson['id'] ?? restaurantJson['_id']}');
        print('   Restaurant Name: ${restaurantJson['name']}');
        
        try {
          final restaurant = _parseRestaurantFromJson(restaurantJson);
          print('✅ Successfully parsed restaurant: ${restaurant.name} (${restaurant.id})');
          return restaurant;
        } catch (parseError, parseStack) {
          print('❌ Error parsing restaurant JSON: $parseError');
          print('   JSON: $restaurantJson');
          print('   Stack: $parseStack');
          rethrow;
        }
      } else if (response.statusCode == 404) {
        print('⚠️  Restaurant not found (404)');
        throw Exception('Restaurant not found');
      } else {
        print('❌ Non-200 status code: ${response.statusCode}');
        print('   Response data: ${response.data}');
        throw Exception('Failed to fetch restaurant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException when fetching restaurant detail:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Request Path: ${e.requestOptions.path}');
      
      // Handle 404 specifically - restaurant not found
      if (e.response?.statusCode == 404) {
        print('⚠️  Restaurant not found (404)');
        throw Exception('Restaurant not found');
      }
      
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching restaurant detail: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch restaurant detail: ${e.toString()}');
    }
  }

  /// Get restaurant menu
  /// GET /restaurants/{id}/menu
  /// Requires: auth_token in Authorization header
  Future<Map<String, dynamic>> getRestaurantMenu(String restaurantId) async {
    try {
      print('📡 Fetching restaurant menu from API: ${AppConfig.restaurantMenu(restaurantId)}');
      final response = await _apiClient.dio.get(
        AppConfig.restaurantMenu(restaurantId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            return data['data'] as Map<String, dynamic>;
          } else {
            return data;
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch restaurant menu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching restaurant menu: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch restaurant menu: ${e.toString()}');
    }
  }

  /// Check slot availability (30-day window)
  /// GET /restaurants/{id}/availability?date=2026-03-01&partySize=4
  Future<Map<String, dynamic>> getRestaurantAvailability(
    String restaurantId, {
    required String date,
    required int partySize,
  }) async {
    try {
      final path = AppConfig.restaurantAvailability(restaurantId, date, partySize);
      print('📡 Fetching availability: $path');
      final response = await _apiClient.dio.get(path);
      if (response.statusCode != 200) throw Exception('Failed to fetch availability: ${response.statusCode}');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is Map<String, dynamic>) return data['data'] as Map<String, dynamic>;
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get social reviews & sentiment for restaurant
  /// GET /reviews/restaurant/{restaurantId}
  Future<List<dynamic>> getRestaurantReviews(String restaurantId) async {
    try {
      final path = AppConfig.restaurantReviews(restaurantId);
      print('📡 Fetching reviews: $path');
      final response = await _apiClient.dio.get(path);
      if (response.statusCode != 200) throw Exception('Failed to fetch reviews: ${response.statusCode}');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['reviews'] ?? data['items'];
        if (list is List) return list;
      } else if (data is List) return data;
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Like a restaurant (add to favorites)
  /// POST /favorites body: { itemType: "RESTAURANT", itemId: "{{restaurantId}}" }
  Future<void> addFavorite({required String itemType, required String itemId}) async {
    try {
      print('📡 Adding favorite: $itemType $itemId');
      await _apiClient.dio.post(AppConfig.favoritesCreate, data: {
        'itemType': itemType,
        'itemId': itemId,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Remove favorite (if API supports DELETE /favorites with body or query)
  Future<void> removeFavorite({required String itemType, required String itemId}) async {
    try {
      await _apiClient.dio.delete(
        '${AppConfig.favoritesCreate}?type=$itemType&itemId=$itemId',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// List my favorites by type
  /// GET /favorites?type=RESTAURANT
  Future<List<dynamic>> listFavorites(String type) async {
    try {
      final path = AppConfig.favoritesList(type);
      print('📡 Listing favorites: $path');
      final response = await _apiClient.dio.get(path);
      if (response.statusCode != 200) throw Exception('Failed to list favorites: ${response.statusCode}');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['favorites'] ?? data['items'];
        if (list is List) return list;
      } else if (data is List) return data;
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Submit verified review
  /// POST /reviews body: { serviceId, rating, comment, images? }
  Future<Map<String, dynamic>> submitReview({
    required String serviceId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      print('📡 Submitting review for $serviceId');
      final body = <String, dynamic>{
        'serviceId': serviceId,
        'rating': rating,
        'comment': comment,
      };
      if (images != null && images.isNotEmpty) body['images'] = images;
      final response = await _apiClient.dio.post(AppConfig.reviewsSubmit, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
      final data = response.data;
      if (data is Map<String, dynamic>) return data['data'] as Map<String, dynamic>? ?? data;
      return {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Parse restaurant from JSON
  Restaurant _parseRestaurantFromJson(Map<String, dynamic> json) {
    // Map category string to enum
    RestaurantCategory category = RestaurantCategory.casual;
    final categoryStr = (json['category'] ?? json['type'] ?? '').toString().toLowerCase();
    switch (categoryStr) {
      case 'fine dining':
      case 'finedining':
        category = RestaurantCategory.fineDining;
        break;
      case 'casual':
      case 'casual dining':
        category = RestaurantCategory.casual;
        break;
      case 'fast food':
      case 'fastfood':
        category = RestaurantCategory.fastFood;
        break;
      case 'traditional':
        category = RestaurantCategory.traditional;
        break;
      case 'asian':
        category = RestaurantCategory.asian;
        break;
      case 'african':
        category = RestaurantCategory.african;
        break;
      case 'italian':
        category = RestaurantCategory.italian;
        break;
      case 'seafood':
        category = RestaurantCategory.seafood;
        break;
      case 'vegetarian':
        category = RestaurantCategory.vegetarian;
        break;
      case 'cafe':
      case 'café':
        category = RestaurantCategory.cafe;
        break;
      case 'bakery':
        category = RestaurantCategory.bakery;
        break;
    }

    // Map price level
    PriceLevel priceLevel = PriceLevel.moderate;
    final priceStr = (json['priceLevel'] ?? json['price'] ?? json['priceRange'] ?? '').toString();
    if (priceStr.contains('\$')) {
      final dollarCount = '\$'.allMatches(priceStr).length;
      switch (dollarCount) {
        case 1:
          priceLevel = PriceLevel.budget;
          break;
        case 2:
          priceLevel = PriceLevel.moderate;
          break;
        case 3:
          priceLevel = PriceLevel.expensive;
          break;
        case 4:
          priceLevel = PriceLevel.luxury;
          break;
      }
    }

    // Parse images
    List<String> images = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = (json['images'] as List).map((e) => e.toString()).toList();
      } else if (json['images'] is String) {
        images = [json['images']];
      }
    } else if (json['imageUrl'] != null) {
      images = [json['imageUrl'].toString()];
    } else if (json['image'] != null) {
      images = [json['image'].toString()];
    }

    // Parse opening hours
    Map<String, String> openingHours = {};
    if (json['openingHours'] != null && json['openingHours'] is Map) {
      openingHours = Map<String, String>.from(
        (json['openingHours'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
      );
    } else if (json['hours'] != null && json['hours'] is Map) {
      openingHours = Map<String, String>.from(
        (json['hours'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
      );
    }

    return Restaurant(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: images,
      category: category,
      priceLevel: priceLevel,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 
                   (json['reviews'] as num?)?.toInt() ?? 0,
      address: json['address']?.toString() ?? 
               json['location']?.toString() ?? 
               json['venueAddress']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 
                (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 
                 (json['lng'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phoneNumber']?.toString() ?? 
                   json['phone']?.toString() ?? '',
      cuisineTypes: (json['cuisineTypes'] as List?)?.map((e) => e.toString()).toList() ?? 
                    (json['cuisines'] as List?)?.map((e) => e.toString()).toList() ?? [],
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      openingHours: openingHours,
      isOpen: json['isOpen'] == true || json['isOpenNow'] == true,
      // Default to true if field is missing (most restaurants accept reservations)
      acceptsReservations: (json['acceptsReservations'] == true) || 
                           (json['acceptsBooking'] == true) ||
                           (json['acceptsReservations'] == null && json['acceptsBooking'] == null),
      hasDelivery: json['hasDelivery'] == true || json['delivery'] == true,
      isPremiumPartner: json['isPremium'] == true || json['isPremiumPartner'] == true,
      discount: (json['discount'] as num?)?.toDouble(),
      specialOffer: json['specialOffer']?.toString(),
    );
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String message = 'Request failed with status $statusCode';
      
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? 
                  data['error']?.toString() ?? 
                  message;
      }
      
      return Exception(message);
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
