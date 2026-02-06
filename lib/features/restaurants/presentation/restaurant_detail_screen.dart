import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'providers/restaurant_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../domain/restaurant.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    required this.restaurantId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));
    final isPremium = ref.watch(isPremiumMemberProvider);
    
    return restaurantAsync.when(
      data: (restaurant) {
        if (restaurant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Restaurant not found'),
                ],
              ),
            ),
          );
        }
        
        final isFavorite = ref.watch(isRestaurantFavoriteProvider(restaurantId));
        return _buildRestaurantDetail(context, restaurant, isPremium, isFavorite, ref);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading restaurant', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(restaurantByIdProvider(restaurantId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantDetail(
    BuildContext context,
    Restaurant restaurant,
    bool isPremium,
    bool isFavorite,
    WidgetRef ref,
  ) {

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image gallery app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: restaurant.images.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: Icon(PhosphorIcons.image(), size: 64, color: Colors.grey[600]),
                    )
                  : PageView.builder(
                      itemCount: restaurant.images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: restaurant.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(PhosphorIcons.image(), size: 64, color: Colors.grey[600]),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite
                      ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                      : PhosphorIcons.heart(),
                  color: isFavorite ? AppColors.error : Colors.white,
                ),
                onPressed: () {
                  ref
                      .read(favoriteRestaurantsNotifierProvider.notifier)
                      .toggle(restaurantId);
                },
              ),
              IconButton(
                icon: Icon(PhosphorIcons.shareNetwork()),
                onPressed: () {
                  // TODO: Share
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.star(PhosphorIconsStyle.fill),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Spacing.sm),

                  // Cuisine and price
                  if (restaurant.cuisineTypes.isNotEmpty || restaurant.priceRange.isNotEmpty)
                    Text(
                      [
                        if (restaurant.cuisineTypes.isNotEmpty) AppUtils.formatList(restaurant.cuisineTypes),
                        if (restaurant.priceRange.isNotEmpty) restaurant.priceRange,
                      ].where((s) => s.isNotEmpty).join(' • '),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                  const SizedBox(height: Spacing.md),

                  // Discount badge (if premium)
                  if (restaurant.isPremiumPartner && isPremium && restaurant.discount != null)
                    Container(
                      padding: const EdgeInsets.all(Spacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.star(PhosphorIconsStyle.fill),
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              'You save ${restaurant.discount}% as a premium member!',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: Spacing.lg),

                  // Opening hours
                  if (restaurant.openingHours.isNotEmpty) ...[
                    Text(
                      'Opening times',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.sm),
                        child: Column(
                          children: _openingHoursEntries(restaurant.openingHours),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                  ],

                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    restaurant.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: Spacing.lg),

                  // Amenities
                  if (restaurant.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.sm,
                      children: restaurant.amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          avatar: Icon(PhosphorIcons.check(), size: 16),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: Spacing.lg),
                  ],

                  // Contact info
                  if (restaurant.phoneNumber.isNotEmpty)
                    _InfoCard(
                      icon: PhosphorIcons.phone(),
                      title: 'Phone',
                      subtitle: restaurant.phoneNumber,
                      onTap: () => _makePhoneCall(restaurant.phoneNumber),
                    ),

                  if (restaurant.phoneNumber.isNotEmpty) const SizedBox(height: Spacing.md),

                  if (restaurant.address.isNotEmpty)
                    _InfoCard(
                      icon: PhosphorIcons.mapPin(),
                      title: 'Address',
                      subtitle: restaurant.address,
                      onTap: () {
                        // TODO: Open in maps
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/restaurants/$restaurantId/book'),
            icon: Icon(PhosphorIcons.calendar()),
            label: const Text('Make a Reservation'),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

List<Widget> _openingHoursEntries(Map<String, String> openingHours) {
  const dayOrder = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final entries = <Widget>[];
  for (final day in dayOrder) {
    final hours = openingHours[day] ??
        openingHours[day.toLowerCase()] ??
        openingHours[day.toUpperCase()] ??
        '—';
    entries.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                color: hours.toLowerCase().contains('closed')
                    ? AppColors.textSecondary
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  return entries;
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap != null ? Icon(PhosphorIcons.caretRight()) : null,
        onTap: onTap,
      ),
    );
  }
}
