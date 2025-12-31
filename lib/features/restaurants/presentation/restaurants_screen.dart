import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'providers/restaurant_providers.dart';
import '../../restaurants/domain/restaurant.dart';
import '../../../core/widgets/cards/restaurant_card.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../../../core/constants/app_constants.dart';

class RestaurantsScreen extends ConsumerStatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  ConsumerState<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends ConsumerState<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
    final searchQuery = ref.watch(restaurantSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.funnel()),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(PhosphorIcons.x()),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(restaurantSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(restaurantSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Active filters chips
          _ActiveFiltersChips(),

          // Results
          Expanded(
            child: restaurantsAsync.when(
              data: (restaurants) {
                if (restaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.magnifyingGlass(),
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: Spacing.md),
                        Text(
                          'No restaurants found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: Spacing.sm),
                        const Text('Try adjusting your filters'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(Spacing.md),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
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
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: Spacing.md),
                    child: RestaurantCardShimmer(),
                  );
                },
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.warningCircle(),
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: Spacing.md),
                    Text('Error loading restaurants'),
                    const SizedBox(height: Spacing.sm),
                    ElevatedButton(
                      onPressed: () => ref.refresh(restaurantsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FiltersBottomSheet(),
    );
  }
}

class _ActiveFiltersChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final showOpenOnly = ref.watch(showOpenOnlyProvider);
    final selectedPriceLevel = ref.watch(selectedPriceLevelProvider);

    final hasActiveFilters = selectedCategories.isNotEmpty ||
        showOpenOnly ||
        selectedPriceLevel != null;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (showOpenOnly)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: FilterChip(
                label: const Text('Open Now'),
                selected: true,
                onSelected: (_) {
                  ref.read(showOpenOnlyProvider.notifier).state = false;
                },
                deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                onDeleted: () {
                  ref.read(showOpenOnlyProvider.notifier).state = false;
                },
              ),
            ),
          if (selectedPriceLevel != null)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: FilterChip(
                label: Text(_getPriceLevelText(selectedPriceLevel)),
                selected: true,
                onSelected: (_) {
                  ref.read(selectedPriceLevelProvider.notifier).state = null;
                },
                deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                onDeleted: () {
                  ref.read(selectedPriceLevelProvider.notifier).state = null;
                },
              ),
            ),
          ...selectedCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: FilterChip(
                label: Text(_getCategoryText(category)),
                selected: true,
                onSelected: (_) {
                  final current = ref.read(selectedCategoriesProvider);
                  ref.read(selectedCategoriesProvider.notifier).state =
                      current.where((c) => c != category).toList();
                },
                deleteIcon: Icon(PhosphorIcons.x(), size: 16),
                onDeleted: () {
                  final current = ref.read(selectedCategoriesProvider);
                  ref.read(selectedCategoriesProvider.notifier).state =
                      current.where((c) => c != category).toList();
                },
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              ref.read(selectedCategoriesProvider.notifier).state = [];
              ref.read(showOpenOnlyProvider.notifier).state = false;
              ref.read(selectedPriceLevelProvider.notifier).state = null;
            },
            icon: Icon(PhosphorIcons.x(), size: 16),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _getCategoryText(RestaurantCategory category) {
    return category.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  String _getPriceLevelText(PriceLevel level) {
    switch (level) {
      case PriceLevel.budget:
        return '\$';
      case PriceLevel.moderate:
        return '\$\$';
      case PriceLevel.expensive:
        return '\$\$\$';
      case PriceLevel.luxury:
        return '\$\$\$\$';
    }
  }
}

class _FiltersBottomSheet extends ConsumerWidget {
  const _FiltersBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(selectedCategoriesProvider.notifier).state = [];
                      ref.read(showOpenOnlyProvider.notifier).state = false;
                      ref.read(selectedPriceLevelProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filters content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(Spacing.md),
                children: [
                  // Open Now
                  _FilterSection(
                    title: 'Availability',
                    child: _OpenNowFilter(),
                  ),

                  const SizedBox(height: Spacing.lg),

                  // Price Level
                  _FilterSection(
                    title: 'Price Range',
                    child: _PriceLevelFilter(),
                  ),

                  const SizedBox(height: Spacing.lg),

                  // Categories
                  _FilterSection(
                    title: 'Categories',
                    child: _CategoryFilter(),
                  ),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        child,
      ],
    );
  }
}

class _OpenNowFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOpenOnly = ref.watch(showOpenOnlyProvider);

    return SwitchListTile(
      title: const Text('Open Now'),
      subtitle: const Text('Show only restaurants currently open'),
      value: showOpenOnly,
      onChanged: (value) {
        ref.read(showOpenOnlyProvider.notifier).state = value;
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _PriceLevelFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPriceLevel = ref.watch(selectedPriceLevelProvider);

    return Wrap(
      spacing: Spacing.sm,
      children: PriceLevel.values.map((level) {
        final isSelected = selectedPriceLevel == level;
        return ChoiceChip(
          label: Text(_getLevelText(level)),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(selectedPriceLevelProvider.notifier).state =
                selected ? level : null;
          },
        );
      }).toList(),
    );
  }

  String _getLevelText(PriceLevel level) {
    switch (level) {
      case PriceLevel.budget:
        return '\$';
      case PriceLevel.moderate:
        return '\$\$';
      case PriceLevel.expensive:
        return '\$\$\$';
      case PriceLevel.luxury:
        return '\$\$\$\$';
    }
  }
}

class _CategoryFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = ref.watch(selectedCategoriesProvider);

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: RestaurantCategory.values.map((category) {
        final isSelected = selectedCategories.contains(category);
        return FilterChip(
          label: Text(_getCategoryText(category)),
          selected: isSelected,
          onSelected: (selected) {
            final current = ref.read(selectedCategoriesProvider);
            if (selected) {
              ref.read(selectedCategoriesProvider.notifier).state = [
                ...current,
                category
              ];
            } else {
              ref.read(selectedCategoriesProvider.notifier).state =
                  current.where((c) => c != category).toList();
            }
          },
        );
      }).toList(),
    );
  }

  String _getCategoryText(RestaurantCategory category) {
    return category.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }
}
