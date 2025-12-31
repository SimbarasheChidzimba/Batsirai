import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/mock_data.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = MockData.events.firstWhere((e) => e.id == eventId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(event.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                _buildChip(event.category, AppColors.accent),
                const SizedBox(height: 16),
                _buildInfoRow(PhosphorIcons.calendarBlank(),
                  '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}'),
                _buildInfoRow(PhosphorIcons.clock(), 
                  '${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, '0')}'),
                _buildInfoRow(PhosphorIcons.mapPin(), event.venueAddress),
                const SizedBox(height: 16),
                Text(event.description),
                const SizedBox(height: 24),
                if (event.performers.isNotEmpty) ...[
                  const Text('Performers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ...event.performers.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        PhosphorIcon(PhosphorIcons.microphone(), size: 20),
                        const SizedBox(width: 8),
                        Text(p),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                if (!event.isFree) ...[
                  const Text('Ticket Tiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...event.ticketTiers.map((tier) => Card(
                    child: ListTile(
                      title: Text(tier.name),
                      subtitle: Text(tier.description),
                      trailing: Text('\$${tier.price}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  )),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: event.isFree 
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event RSVP confirmed!')),
                  );
                }
              : () => context.go('/events/$eventId/tickets'),
            child: Text(event.isFree ? 'RSVP (Free)' : 'Get Tickets'),
          ),
        ),
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
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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
