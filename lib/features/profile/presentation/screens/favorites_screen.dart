import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/restaurant_card.dart';
import '../../../../core/widgets/cards/event_card.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../events/presentation/providers/event_providers.dart';
import '../../../restaurants/presentation/providers/restaurant_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.heart(),
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: Spacing.md),
              const Text('Please sign in to view your favorites'),
              const SizedBox(height: Spacing.md),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Restaurants'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRestaurantsTab(),
          _buildEventsTab(),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    final favoriteIds = ref.watch(favoriteRestaurantIdsProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return restaurantsAsync.when(
      data: (allRestaurants) {
        final favorites = allRestaurants
            .where((r) => favoriteIds.contains(r.id))
            .toList();

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.heart(),
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: Spacing.md),
                const Text('No favorite restaurants yet'),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Tap the heart icon on restaurants to add them to favorites',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(Spacing.md),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final restaurant = favorites[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: RestaurantCard(
                restaurant: restaurant,
                onTap: () => context.push('/restaurants/${restaurant.id}'),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(Spacing.md),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Spacing.md),
            child: ShimmerLoading(width: double.infinity, height: 200),
          );
        },
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.warning(), size: 64, color: Colors.red),
            const SizedBox(height: Spacing.md),
            Text('Error loading restaurants: $error'),
            const SizedBox(height: Spacing.md),
            ElevatedButton(
              onPressed: () => ref.invalidate(restaurantsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    final favoriteIds = ref.watch(favoriteEventIdsProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (allEvents) {
        final favorites = allEvents
            .where((e) => favoriteIds.contains(e.id))
            .toList();

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.heart(),
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: Spacing.md),
                const Text('No favorite events yet'),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Tap the heart icon on events to add them to favorites',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(Spacing.md),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final event = favorites[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: EventCard(
                event: event,
                onTap: () => context.push('/events/${event.id}'),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(Spacing.md),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Spacing.md),
            child: ShimmerLoading(width: double.infinity, height: 200),
          );
        },
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.warning(), size: 64, color: Colors.red),
            const SizedBox(height: Spacing.md),
            Text('Error loading events: $error'),
            const SizedBox(height: Spacing.md),
            ElevatedButton(
              onPressed: () => ref.invalidate(eventsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
