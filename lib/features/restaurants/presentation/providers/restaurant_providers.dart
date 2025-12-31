import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/restaurant.dart';
import '../data/mock_restaurant_data.dart';

// Restaurants list provider
final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(milliseconds: 800));
  return MockRestaurantData.restaurants;
});

// Nearby restaurants provider
final nearbyRestaurantsProvider = FutureProvider.family<List<Restaurant>, (double, double)>(
  (ref, location) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockRestaurantData.getNearbyRestaurants(location.$1, location.$2);
  },
);

// Featured restaurants provider
final featuredRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockRestaurantData.getFeaturedRestaurants();
});

// Restaurant by ID provider
final restaurantByIdProvider = Provider.family<Restaurant?, String>((ref, id) {
  final restaurantsAsync = ref.watch(restaurantsProvider);
  return restaurantsAsync.when(
    data: (restaurants) => restaurants.where((r) => r.id == id).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
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
