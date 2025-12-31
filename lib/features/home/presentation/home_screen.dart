import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../restaurants/presentation/providers/restaurant_providers.dart';
import '../../events/presentation/providers/event_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/widgets/cards/restaurant_card.dart';
import '../../../core/widgets/cards/event_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumMemberProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppUtils.getGreeting(),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  user?.displayName ?? 'Guest',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            actions: [
              if (!isPremium)
                TextButton.icon(
                  onPressed: () => context.push('/home/membership'),
                  icon: Icon(PhosphorIcons.crown(), size: 18),
                  label: const Text('Upgrade'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                ),
              IconButton(
                icon: Icon(PhosphorIcons.bell()),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SearchBar(
                leading: Icon(PhosphorIcons.magnifyingGlass()),
                hintText: 'Search restaurants, events...',
                onTap: () {
                  // TODO: Navigate to search screen
                },
              ),
            ),
          ),

          // Member Benefits Banner (if not premium)
          if (!isPremium)
            SliverToBoxAdapter(
              child: _MembershipBanner(
                onTap: () => context.push('/home/membership'),
              ),
            ),

          // Featured Events Section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Happening Soon',
              subtitle: 'Don\'t miss these upcoming events',
              onSeeAll: () => context.go('/events'),
            ),
          ),
          
          _FeaturedEventsSection(),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

          // Featured Restaurants Section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Top Rated Restaurants',
              subtitle: 'Exclusive member discounts available',
              onSeeAll: () => context.go('/restaurants'),
            ),
          ),
          
          _FeaturedRestaurantsSection(),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

          // Quick Actions
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Explore by Category',
            ),
          ),
          
          const SliverToBoxAdapter(
            child: _QuickActionsSection(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)),
        ],
      ),
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _MembershipBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.crown(PhosphorIconsStyle.fill),
                  color: AppColors.accent,
                  size: 32,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Premium Benefits',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Get up to 25% off at top venues',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.arrowRight(),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedEventsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(featuredEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.xl),
                child: Text('No featured events at the moment'),
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: events.take(5).length,
              itemBuilder: (context, index) {
                final event = events[index];
                return SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(right: Spacing.md),
                    child: EventCard(
                      event: event,
                      onTap: () => context.push('/events/${event.id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: 3,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.md),
                  child: const EventCardShimmer(),
                ),
              );
            },
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Text('Error loading events: $error'),
          ),
        ),
      ),
    );
  }
}

class _FeaturedRestaurantsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(featuredRestaurantsProvider);

    return restaurantsAsync.when(
      data: (restaurants) {
        if (restaurants.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.xl),
                child: Text('No featured restaurants at the moment'),
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: restaurants.take(5).length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(right: Spacing.md),
                    child: RestaurantCard(
                      restaurant: restaurant,
                      onTap: () => context.push('/restaurants/${restaurant.id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: 3,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.md),
                  child: const RestaurantCardShimmer(),
                ),
              );
            },
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Text('Error loading restaurants: $error'),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem(
        icon: PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
        label: 'Fine Dining',
        color: AppColors.primary,
        onTap: () => context.go('/restaurants'),
      ),
      _CategoryItem(
        icon: PhosphorIcons.musicNotes(PhosphorIconsStyle.fill),
        label: 'Music',
        color: AppColors.accent,
        onTap: () => context.go('/events'),
      ),
      _CategoryItem(
        icon: PhosphorIcons.confetti(PhosphorIconsStyle.fill),
        label: 'Nightlife',
        color: AppColors.secondary,
        onTap: () => context.go('/events'),
      ),
      _CategoryItem(
        icon: PhosphorIcons.cake(PhosphorIconsStyle.fill),
        label: 'Festivals',
        color: AppColors.info,
        onTap: () => context.go('/events'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: categories
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    child: item,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
