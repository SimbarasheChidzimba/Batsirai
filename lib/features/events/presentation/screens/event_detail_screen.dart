import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../providers/event_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event Not Found')),
              body: const Center(child: Text('Event not found')),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.images.isNotEmpty
                      ? Image.network(
                          event.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryContainer,
                            child: Icon(
                              PhosphorIcons.image(),
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryContainer,
                          child: Icon(
                            PhosphorIcons.image(),
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildChip(event.categoryName, AppColors.accent),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      PhosphorIcons.calendarBlank(),
                      DateFormat('MMM dd, yyyy').format(event.startDate),
                    ),
                    _buildInfoRow(
                      PhosphorIcons.clock(),
                      DateFormat('hh:mm a').format(event.startDate),
                    ),
                    _buildInfoRow(
                      PhosphorIcons.mapPin(),
                      event.venueAddress,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (event.performers.isNotEmpty) ...[
                      Text(
                        'Performers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...event.performers.map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.microphone(),
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(p),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (event.ticketTiers.isNotEmpty) ...[
                      Text(
                        'Ticket Tiers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...event.ticketTiers.map(
                        (tier) => Card(
                          child: ListTile(
                            title: Text(tier.name),
                            subtitle: Text(tier.description),
                            trailing: Text(
                              '\$${tier.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Event Details')),
          body: const Center(child: ShimmerLoading(width: double.infinity, height: 200)),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Event Details')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.warning(), size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading event: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(eventByIdProvider(eventId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: eventAsync.when(
        data: (event) {
          if (event == null) return const SizedBox.shrink();
          final hasFreeTickets = event.ticketTiers.isEmpty ||
              event.ticketTiers.any((t) => t.price == 0);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: hasFreeTickets
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event RSVP confirmed!')),
                        );
                      }
                    : () => context.go('/events/$eventId/tickets'),
                child: Text(hasFreeTickets ? 'RSVP (Free)' : 'Get Tickets'),
              ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          PhosphorIcon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
