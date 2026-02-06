import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/restaurant_providers.dart';
import '../../../../core/widgets/cards/restaurant_card.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';

class RestaurantsScreen extends ConsumerStatefulWidget {
  const RestaurantsScreen({super.key});
  @override
  ConsumerState<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends ConsumerState<RestaurantsScreen> {
  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(icon: PhosphorIcon(PhosphorIcons.funnelSimple()), onPressed: () {}),
        ],
      ),
      body: restaurantsAsync.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.magnifyingGlass(), size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No restaurants found', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RestaurantCard(
                      restaurant: restaurants[index],
                      onTap: () => context.go('/restaurants/${restaurants[index].id}'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: RestaurantCardShimmer(),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading restaurants', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(restaurantsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final searchQuery = ref.watch(restaurantSearchQueryProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search restaurants...',
          prefixIcon: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: PhosphorIcon(PhosphorIcons.x()),
                  onPressed: () => ref.read(restaurantSearchQueryProvider.notifier).state = '',
                )
              : null,
        ),
        onChanged: (value) => ref.read(restaurantSearchQueryProvider.notifier).state = value,
      ),
    );
  }
}
