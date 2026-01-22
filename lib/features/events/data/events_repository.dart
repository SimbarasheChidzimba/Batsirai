import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/event.dart';

/// Repository for events operations
/// All endpoints require authentication token (handled by ApiClient interceptor)
class EventsRepository {
  final ApiClient _apiClient;

  EventsRepository(this._apiClient);

  /// Get list of all events
  /// GET /events
  /// Requires: auth_token in Authorization header
  Future<List<Event>> listEvents() async {
    try {
      print('📡 Fetching events from API: ${AppConfig.eventsList}');
      // Add minimum delay to show loading state (remove in production if not needed)
      await Future.delayed(const Duration(milliseconds: 500));
      final response = await _apiClient.dio.get(
        AppConfig.eventsList,
      );

      print('✅ Events API Response Status: ${response.statusCode}');
      print('📦 Events API Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> eventsList;
        if (data is List) {
          // Direct array response
          eventsList = data;
          print('📋 Events list (direct): ${eventsList.length} items');
        } else if (data is Map<String, dynamic>) {
          // Check for nested structure: { success: true, data: { events: [...] } }
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            final dataObj = data['data'] as Map<String, dynamic>;
            if (dataObj['events'] is List) {
              eventsList = dataObj['events'] as List;
              print('📋 Events list (data.events): ${eventsList.length} items');
            } else if (dataObj['data'] is List) {
              eventsList = dataObj['data'] as List;
              print('📋 Events list (data.data): ${eventsList.length} items');
            } else {
              print('❌ data object keys: ${dataObj.keys}');
              throw Exception('Unexpected response format in data object: ${dataObj.keys}');
            }
          } else if (data['data'] is List) {
            // { data: [...] }
            eventsList = data['data'] as List;
            print('📋 Events list (data key): ${eventsList.length} items');
          } else if (data['events'] is List) {
            // { events: [...] }
            eventsList = data['events'] as List;
            print('📋 Events list (events key): ${eventsList.length} items');
          } else {
            print('❌ Unexpected response format. Top-level keys: ${data.keys}');
            throw Exception('Unexpected response format: ${data.keys}');
          }
        } else {
          print('❌ Response is not List or Map. Type: ${data.runtimeType}');
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        if (eventsList.isEmpty) {
          print('⚠️  Events list is empty');
          return [];
        }

        print('🔄 Parsing ${eventsList.length} events...');
        final parsedEvents = eventsList
            .map((json) {
              try {
                return _parseEventFromJson(json as Map<String, dynamic>);
              } catch (e, stack) {
                print('❌ Error parsing event: $e');
                print('   JSON: $json');
                print('   Stack: $stack');
                rethrow;
              }
            })
            .toList();
        
        print('✅ Successfully parsed ${parsedEvents.length} events');
        return parsedEvents;
      } else {
        print('❌ Non-200 status code: ${response.statusCode}');
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException when fetching events:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      throw _handleDioError(e);
    } catch (e, stack) {
      print('❌ Exception when fetching events: $e');
      print('   Stack: $stack');
      throw Exception('Failed to fetch events: ${e.toString()}');
    }
  }

  /// Get event details by ID
  /// GET /events/{id}
  /// Requires: auth_token in Authorization header
  Future<Event> getEventDetail(String eventId) async {
    try {
      print('📡 Fetching event detail from API: ${AppConfig.eventDetail(eventId)}');
      // Add minimum delay to show loading state (remove in production if not needed)
      await Future.delayed(const Duration(milliseconds: 500));
      final response = await _apiClient.dio.get(
        AppConfig.eventDetail(eventId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        Map<String, dynamic> eventJson;
        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic>) {
            eventJson = data['data'] as Map<String, dynamic>;
          } else if (data['event'] is Map<String, dynamic>) {
            eventJson = data['event'] as Map<String, dynamic>;
          } else {
            eventJson = data;
          }
        } else {
          throw Exception('Unexpected response format');
        }

        return _parseEventFromJson(eventJson);
      } else {
        throw Exception('Failed to fetch event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch event: ${e.toString()}');
    }
  }

  /// Parse Event from API JSON response
  Event _parseEventFromJson(Map<String, dynamic> json) {
    // Parse category - handle both capitalized and lowercase
    EventCategory category;
    final categoryStr = (json['category'] ?? json['categoryName'] ?? '').toString().toLowerCase();
    switch (categoryStr) {
      case 'music':
      case 'entertainment': // Map Entertainment to Music as fallback
        category = EventCategory.music;
        break;
      case 'sports':
        category = EventCategory.sports;
        break;
      case 'festival':
        category = EventCategory.festival;
        break;
      case 'nightlife':
        category = EventCategory.nightlife;
        break;
      case 'arts':
        category = EventCategory.arts;
        break;
      case 'food':
      case 'food & drink':
      case 'foodanddrink':
        category = EventCategory.food;
        break;
      case 'workshop':
        category = EventCategory.workshop;
        break;
      case 'conference':
        category = EventCategory.conference;
        break;
      case 'theater':
      case 'theatre':
        category = EventCategory.theater;
        break;
      case 'exhibition':
        category = EventCategory.exhibition;
        break;
      case 'comedy':
        category = EventCategory.comedy;
        break;
      case 'family':
        category = EventCategory.family;
        break;
      default:
        print('⚠️  Unknown category: "$categoryStr", defaulting to music');
        category = EventCategory.music; // Default fallback
    }

    // Parse status
    EventStatus status;
    final statusStr = (json['status'] ?? 'upcoming').toString().toLowerCase();
    switch (statusStr) {
      case 'ongoing':
        status = EventStatus.ongoing;
        break;
      case 'soldout':
      case 'sold_out':
        status = EventStatus.soldOut;
        break;
      case 'cancelled':
        status = EventStatus.cancelled;
        break;
      case 'postponed':
        status = EventStatus.postponed;
        break;
      default:
        status = EventStatus.upcoming;
    }

    // Parse ticket tiers
    List<TicketTier> ticketTiers = [];
    if (json['ticketTiers'] != null && json['ticketTiers'] is List) {
      ticketTiers = (json['ticketTiers'] as List)
          .map((tier) => _parseTicketTierFromJson(tier as Map<String, dynamic>))
          .toList();
    } else if (json['tickets'] != null && json['tickets'] is List) {
      ticketTiers = (json['tickets'] as List)
          .map((tier) => _parseTicketTierFromJson(tier as Map<String, dynamic>))
          .toList();
    }

    // Parse images - prioritize gallery, fallback to imageUrl
    List<String> images = [];
    if (json['gallery'] != null && json['gallery'] is List) {
      images = (json['gallery'] as List).map((img) => img.toString()).toList();
    } else if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List).map((img) => img.toString()).toList();
    }
    
    // If no gallery/images, use imageUrl
    if (images.isEmpty && json['imageUrl'] != null) {
      images = [json['imageUrl'].toString()];
    } else if (images.isEmpty && json['image'] != null) {
      images = [json['image'].toString()];
    }

    // Parse dates
    DateTime startDate;
    if (json['startDate'] != null) {
      startDate = DateTime.parse(json['startDate'].toString());
    } else if (json['start_date'] != null) {
      startDate = DateTime.parse(json['start_date'].toString());
    } else {
      startDate = DateTime.now();
    }

    DateTime endDate;
    if (json['endDate'] != null) {
      endDate = DateTime.parse(json['endDate'].toString());
    } else if (json['end_date'] != null) {
      endDate = DateTime.parse(json['end_date'].toString());
    } else {
      endDate = startDate.add(const Duration(hours: 2));
    }

    return Event(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: images,
      category: category,
      status: status,
      startDate: startDate,
      endDate: endDate,
      venueName: json['venueName']?.toString() ?? 
                 json['venue_name']?.toString() ?? 
                 json['venue']?.toString() ?? '',
      venueAddress: json['venueAddress']?.toString() ?? 
                    json['venue_address']?.toString() ?? 
                    json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 
                (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 
                 (json['lng'] as num?)?.toDouble() ?? 
                 (json['lon'] as num?)?.toDouble() ?? 0.0,
      ticketTiers: ticketTiers,
      performers: json['performers'] != null && json['performers'] is List
          ? (json['performers'] as List).map((p) => p.toString()).toList()
          : [],
      tags: json['tags'] != null && json['tags'] is List
          ? (json['tags'] as List).map((t) => t.toString()).toList()
          : [],
      dressCode: json['dressCode']?.toString() ?? json['dress_code']?.toString(),
      ageRestriction: json['ageRestriction'] != null
          ? int.tryParse(json['ageRestriction'].toString())
          : json['age_restriction'] != null
              ? int.tryParse(json['age_restriction'].toString())
              : null,
      isFeatured: json['isFeatured'] == true || json['is_featured'] == true,
      isPremiumOnly: json['isPremiumOnly'] == true || json['is_premium_only'] == true,
      organizerName: json['organizerName']?.toString() ?? 
                     json['organizer_name']?.toString() ?? 
                     json['organizer']?.toString() ?? '',
      organizerContact: json['organizerContact']?.toString() ?? 
                        json['organizer_contact']?.toString() ?? 
                        json['contact']?.toString(),
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      attendeeCount: json['attendeeCount'] != null
          ? int.tryParse(json['attendeeCount'].toString())
          : json['attendee_count'] != null
              ? int.tryParse(json['attendee_count'].toString())
              : null,
    );
  }

  /// Parse TicketTier from JSON
  TicketTier _parseTicketTierFromJson(Map<String, dynamic> json) {
    // Handle isAvailable field - if not present, calculate from remaining > 0
    final remaining = json['remaining'] != null
        ? (json['remaining'] as num).toInt()
        : json['availableQuantity'] != null
            ? (json['availableQuantity'] as num).toInt()
            : 0;
    
    final total = json['totalAvailable'] != null
        ? (json['totalAvailable'] as num).toInt()
        : json['totalQuantity'] != null
            ? (json['totalQuantity'] as num).toInt()
            : 0;
    
    return TicketTier(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      availableQuantity: remaining,
      totalQuantity: total,
      benefits: json['benefits'] != null && json['benefits'] is List
          ? (json['benefits'] as List).map((b) => b.toString()).toList()
          : [],
    );
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
        message = 'Failed to fetch events (Status: $statusCode)';
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
