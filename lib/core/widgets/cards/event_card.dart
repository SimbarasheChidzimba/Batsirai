import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../features/events/domain/event.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_utils.dart';

class EventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    required this.event,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isEventFavoriteProvider(event.id));
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
                    imageUrl: event.images.first,
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
                        PhosphorIcons.ticket(),
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
                
                // Date badge (bottom left)
                Positioned(
                  bottom: Spacing.md,
                  left: Spacing.md,
                  child: _DateBadge(date: event.startDate),
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
                          .read(favoriteEventsNotifierProvider.notifier)
                          .toggle(event.id);
                    },
                  ),
                ),
                
                // Featured badge
                if (event.isFeatured)
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
                      child: Text(
                        'FEATURED',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                
                // Status badge
                if (event.status == EventStatus.soldOut)
                  Positioned(
                    top: Spacing.md + 32,
                    left: Spacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'SOLD OUT',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
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
                  // Title
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: Spacing.sm),
                  
                  // Time and venue
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.clock(),
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        AppUtils.formatTime(event.startDate),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: Spacing.md),
                      Icon(
                        PhosphorIcons.mapPin(),
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          event.venueName,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: Spacing.sm),
                  
                  // Category and price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          event.categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.lowestPrice != null)
                        Text(
                          'From ${AppUtils.formatCurrency(event.lowestPrice!)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      else
                        Text(
                          'Free',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                  
                  // Attendee count or rating
                  if (event.attendeeCount != null || event.rating != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        if (event.rating != null) ...[
                          Icon(
                            PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 14,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            event.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                        ],
                        if (event.attendeeCount != null) ...[
                          Icon(
                            PhosphorIcons.users(),
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            '${event.attendeeCount} attending',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
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

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMM').format(date).toUpperCase();
    final day = DateFormat('dd').format(date);

    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sm),
              ),
            ),
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Text(
              day,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
