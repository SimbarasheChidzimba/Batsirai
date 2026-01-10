import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../features/restaurants/domain/restaurant.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_utils.dart';

class RestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final double? distance; // in kilometers

  const RestaurantCard({
    required this.restaurant,
    this.onTap,
    this.distance,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isRestaurantFavoriteProvider(restaurant.id));
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: restaurant.images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        PhosphorIcons.image(),
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.imageOverlay,
                    ),
                  ),
                ),
                
                // Distance badge (bottom left)
                if (distance != null)
                  Positioned(
                    bottom: Spacing.sm,
                    left: Spacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.mapPin(),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            AppUtils.formatDistance(distance!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Favorite button (top right)
                Positioned(
                  top: Spacing.sm,
                  right: Spacing.sm,
                  child: IconButton(
                    icon: Icon(
                      isFavorite
                          ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                          : PhosphorIcons.heart(),
                      color: isFavorite ? AppColors.error : Colors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(favoriteRestaurantsNotifierProvider.notifier)
                          .toggle(restaurant.id);
                    },
                  ),
                ),
                
                // Premium badge (top left)
                if (restaurant.isPremiumPartner)
                  Positioned(
                    top: Spacing.sm,
                    left: Spacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            '${restaurant.discount?.toInt()}% OFF',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Icon(
                        PhosphorIcons.star(PhosphorIconsStyle.fill),
                        size: 16,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${restaurant.reviewCount})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: Spacing.xs),
                  
                  // Category and price
                  Row(
                    children: [
                      Text(
                        restaurant.cuisineTypes.take(2).join(' • '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        '• ${restaurant.priceRange}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // Status indicator
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: restaurant.isOpen
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        restaurant.isOpen ? 'Open Now' : 'Closed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: restaurant.isOpen
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // Special offer
                  if (restaurant.specialOffer != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.gift(),
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Flexible(
                            child: Text(
                              restaurant.specialOffer!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
