import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/restaurant.dart';
import '../../data/mock_restaurant_data.dart';
import '../../data/providers/restaurants_repository_provider.dart';

// Restaurants list provider - uses API
final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantsRepositoryProvider);
  try {
    return await repository.listRestaurants(page: 1, limit: 20);
  } catch (e) {
    print('⚠️  Error fetching restaurants from API, falling back to mock data: $e');
    // Fallback to mock data on error
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRestaurantData.restaurants;
  }
});

// Nearby restaurants provider
final nearbyRestaurantsProvider = FutureProvider.family<List<Restaurant>, (double, double)>(
  (ref, location) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockRestaurantData.getNearbyRestaurants(location.$1, location.$2);
  },
);

// Featured restaurants provider - uses API
final featuredRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.watch(restaurantsRepositoryProvider);
  try {
    final restaurants = await repository.listRestaurants(page: 1, limit: 20);
    // Filter for featured/premium restaurants, or return first 10 if none
    final featured = restaurants.where((r) => r.isPremiumPartner).toList();
    return featured.isNotEmpty ? featured : restaurants.take(10).toList();
  } catch (e) {
    print('⚠️  Error fetching featured restaurants from API, falling back to mock data: $e');
    // Fallback to mock data on error
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRestaurantData.getFeaturedRestaurants();
  }
});

// Restaurant by ID provider - uses API
final restaurantByIdProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final repository = ref.watch(restaurantsRepositoryProvider);
  try {
    print('🔍 RestaurantByIdProvider: Fetching restaurant with ID: $id');
    final restaurant = await repository.getRestaurantDetail(id);
    print('✅ RestaurantByIdProvider: Successfully fetched restaurant: ${restaurant.name}');
    return restaurant;
  } catch (e, stack) {
    print('⚠️  Error fetching restaurant detail from API: $e');
    print('   Stack: $stack');
    
    // If restaurant not found, return null instead of throwing
    // This allows the UI to show "Restaurant not found" message
    if (e.toString().contains('Restaurant not found') || 
        e.toString().contains('404')) {
      print('⚠️  Restaurant not found, returning null');
      return null;
    }
    
    // For other errors, rethrow so UI can show error state
    rethrow;
  }
});

// Restaurants by category provider
final restaurantsByCategoryProvider = Provider.family<List<Restaurant>, RestaurantCategory>(
  (ref, category) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    return restaurantsAsync.when(
      data: (restaurants) => restaurants.where((r) => r.category == category).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Search query provider
final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered restaurants provider (search + filters)
final filteredRestaurantsProvider = Provider<AsyncValue<List<Restaurant>>>((ref) {
  final restaurantsAsync = ref.watch(restaurantsProvider);
  final searchQuery = ref.watch(restaurantSearchQueryProvider);
  final selectedCategories = ref.watch(selectedCategoriesProvider);
  final selectedPriceLevel = ref.watch(selectedPriceLevelProvider);
  final showOpenOnly = ref.watch(showOpenOnlyProvider);

  return restaurantsAsync.when(
    data: (restaurants) {
      var filtered = restaurants;

      // Search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((r) =>
                r.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                r.cuisineTypes.any((c) => c.toLowerCase().contains(searchQuery.toLowerCase())))
            .toList();
      }

      // Category filter
      if (selectedCategories.isNotEmpty) {
        filtered = filtered.where((r) => selectedCategories.contains(r.category)).toList();
      }

      // Price level filter
      if (selectedPriceLevel != null) {
        filtered = filtered.where((r) => r.priceLevel == selectedPriceLevel).toList();
      }

      // Open now filter
      if (showOpenOnly) {
        filtered = filtered.where((r) => r.isOpen).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Filter state providers
final selectedCategoriesProvider = StateProvider<List<RestaurantCategory>>((ref) => []);
final selectedPriceLevelProvider = StateProvider<PriceLevel?>((ref) => null);
final showOpenOnlyProvider = StateProvider<bool>((ref) => false);
