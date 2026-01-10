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

class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    required this.restaurantId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantByIdProvider(restaurantId));
    final isPremium = ref.watch(isPremiumMemberProvider);
    final isFavorite = ref.watch(isRestaurantFavoriteProvider(restaurantId));

    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image gallery app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: restaurant.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: restaurant.images[index],
                    fit: BoxFit.cover,
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
                  Text(
                    '${AppUtils.formatList(restaurant.cuisineTypes)} • ${restaurant.priceRange}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),

                  const SizedBox(height: Spacing.md),

                  // Discount badge (if premium)
                  if (restaurant.isPremiumPartner && isPremium)
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

                  // Contact info
                  _InfoCard(
                    icon: PhosphorIcons.phone(),
                    title: 'Phone',
                    subtitle: restaurant.phoneNumber,
                    onTap: () => _makePhoneCall(restaurant.phoneNumber),
                  ),

                  const SizedBox(height: Spacing.md),

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
            onPressed: restaurant.acceptsReservations
                ? () => context.push('/restaurants/$restaurantId/book')
                : null,
            icon: Icon(PhosphorIcons.calendar()),
            label: Text(
              restaurant.acceptsReservations
                  ? 'Make a Reservation'
                  : 'Reservations Not Available',
            ),
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
