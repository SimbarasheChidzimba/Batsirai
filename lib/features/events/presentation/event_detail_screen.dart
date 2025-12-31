import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'providers/event_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    required this.eventId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventByIdProvider(eventId));
    final isFavorite = ref.watch(isEventFavoriteProvider(eventId));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: event.images.first,
                fit: BoxFit.cover,
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
                      .read(favoriteEventsNotifierProvider.notifier)
                      .toggle(eventId);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: Spacing.md),
                  
                  // Date & Time
                  _InfoRow(
                    icon: PhosphorIcons.calendar(),
                    text: AppUtils.formatDate(event.startDate),
                  ),
                  const SizedBox(height: Spacing.sm),
                  _InfoRow(
                    icon: PhosphorIcons.clock(),
                    text: AppUtils.formatTime(event.startDate),
                  ),
                  const SizedBox(height: Spacing.sm),
                  _InfoRow(
                    icon: PhosphorIcons.mapPin(),
                    text: event.venueName,
                  ),

                  const SizedBox(height: Spacing.lg),

                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(event.description),

                  if (event.performers.isNotEmpty) ...[
                    const SizedBox(height: Spacing.lg),
                    Text(
                      'Performers',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.sm),
                    ...event.performers.map((performer) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Text('• $performer'),
                    )),
                  ],

                  const SizedBox(height: Spacing.lg),

                  Text(
                    'Ticket Options',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  ...event.ticketTiers.map((tier) => Card(
                    child: ListTile(
                      title: Text(tier.name),
                      subtitle: Text(tier.description),
                      trailing: Text(
                        AppUtils.formatCurrency(tier.price),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )),
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
            onPressed: event.hasAvailableTickets
                ? () => context.push('/events/$eventId/book')
                : null,
            icon: Icon(PhosphorIcons.ticket()),
            label: Text(
              event.hasAvailableTickets ? 'Get Tickets' : 'Sold Out',
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(text)),
      ],
    );
  }
}
