import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_data.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class TicketPurchaseScreen extends ConsumerStatefulWidget {
  final String eventId;
  const TicketPurchaseScreen({super.key, required this.eventId});
  
  @override
  ConsumerState<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends ConsumerState<TicketPurchaseScreen> {
  final Map<String, int> _quantities = {};

  @override
  Widget build(BuildContext context) {
    final event = MockData.events.firstWhere((e) => e.id == widget.eventId);
    final total = _calculateTotal(event.ticketTiers);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Get Tickets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${event.venueName} • ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Select Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...event.ticketTiers.map((tier) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tier.description,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${tier.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if ((_quantities[tier.id] ?? 0) > 0) {
                            setState(() => _quantities[tier.id] = _quantities[tier.id]! - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${_quantities[tier.id] ?? 0}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final currentQty = _quantities[tier.id] ?? 0;
                          if (currentQty < tier.remaining) {
                            setState(() => _quantities[tier.id] = currentQty + 1);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Only ${tier.remaining} ${tier.name} tickets available')),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      if ((_quantities[tier.id] ?? 0) > 0)
                        Text(
                          '\$${((_quantities[tier.id] ?? 0) * tier.price).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  if (tier.remaining < 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Only ${tier.remaining} left!',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: (total > 0 && user != null)
                  ? () => _proceedToPayment(event, total)
                  : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Continue to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal(List tiers) {
    double total = 0;
    for (var tier in tiers) {
      final qty = _quantities[tier.id] ?? 0;
      total += tier.price * qty;
    }
    return total;
  }

  void _proceedToPayment(event, double total) {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to purchase tickets')),
      );
      return;
    }

    // Prepare ticket data
    final tickets = <Map<String, dynamic>>[];
    _quantities.forEach((tierId, quantity) {
      if (quantity > 0) {
        final tier = event.ticketTiers.firstWhere((t) => t.id == tierId);
        tickets.add({
          'tierId': tierId,
          'tierName': tier.name,
          'price': tier.price,
          'quantity': quantity,
        });
      }
    });

    final totalTickets = tickets.fold<int>(0, (sum, t) => sum + t['quantity'] as int);

    context.push(
      '/payment',
      extra: {
        'type': 'event',
        'bookingData': {
        'eventId': event.id,
        'eventTitle': event.title,
        'eventDate': event.startDate,
        'venue': event.venueName,
          'tickets': tickets,
          'totalTickets': totalTickets,
        },
        'amount': total,
      },
    );
  }
}
