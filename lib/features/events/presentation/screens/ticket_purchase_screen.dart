import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';
import '../../domain/event.dart';
import '../providers/event_providers.dart';

class TicketPurchaseScreen extends ConsumerStatefulWidget {
  final String eventId;
  const TicketPurchaseScreen({super.key, required this.eventId});

  @override
  ConsumerState<TicketPurchaseScreen> createState() =>
      _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends ConsumerState<TicketPurchaseScreen> {
  final Map<String, int> _quantities = {};
  bool _isCreatingSession = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));
    final user = ref.watch(currentUserProvider);

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Get Tickets')),
            body: const Center(
              child: Text('Event not found'),
            ),
          );
        }
        return _buildContent(context, event, user);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Get Tickets')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Get Tickets')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(eventByIdProvider(widget.eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Event event, dynamic user) {
    final total = _calculateTotal(event.ticketTiers);
    final canProceed = total > 0 && user != null && !_isCreatingSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Get Tickets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const Text(
            'Select Tickets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
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
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tier.description,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${tier.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if ((_quantities[tier.id] ?? 0) > 0) {
                                setState(() =>
                                    _quantities[tier.id] = _quantities[tier.id]! - 1);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${_quantities[tier.id] ?? 0}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final currentQty = _quantities[tier.id] ?? 0;
                              if (currentQty < tier.availableQuantity) {
                                setState(() =>
                                    _quantities[tier.id] = currentQty + 1);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Only ${tier.availableQuantity} ${tier.name} tickets available')),
                                );
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          const Spacer(),
                          if ((_quantities[tier.id] ?? 0) > 0)
                            Text(
                              '\$${((_quantities[tier.id] ?? 0) * tier.price).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                      if (tier.availableQuantity < 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Only ${tier.availableQuantity} left!',
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
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canProceed ? () => _proceedToPayment(event, total) : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isCreatingSession
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal(List<TicketTier> tiers) {
    double total = 0;
    for (var tier in tiers) {
      final qty = _quantities[tier.id] ?? 0;
      total += tier.price * qty;
    }
    return total;
  }

  Future<void> _proceedToPayment(Event event, double total) async {
    final user = ref.read(currentUserProvider);

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

    final totalTickets =
        tickets.fold<int>(0, (sum, t) => sum + t['quantity'] as int);

    final bookingData = {
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
    };

    if (user == null) {
      ref.read(pendingBookingDataProvider.notifier).state = bookingData;
      context.push('/login?returnPath=/payment');
      return;
    }

    // Direct payment: POST /tickets/purchase per tier, open Stripe in-app
    setState(() => _isCreatingSession = true);
    try {
      final bookingService = ref.read(bookingServiceProvider);
      final urls = <String>[];

      for (final t in tickets) {
        final tierId = t['tierId'] as String;
        final quantity = t['quantity'] as int;
        final url = await bookingService.purchaseEventTicket(
          serviceId: event.id,
          scheduledDate: event.startDate,
          attendees: quantity,
          tierId: tierId,
          metadata: {'specialRequests': ''},
        );
        urls.add(url);
      }

      if (!mounted) return;
      setState(() => _isCreatingSession = false);

      if (urls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tickets to pay for')),
        );
        return;
      }

      bool allSuccess = true;
      for (final url in urls) {
        final result = await context.push<bool>('/stripe-checkout', extra: url);
        if (result != true) {
          allSuccess = false;
          break;
        }
      }

      if (!mounted) return;
      if (allSuccess) {
        context.pushReplacement(
          '/booking-success',
          extra: {
            'type': 'event',
            'bookingData': {
              ...bookingData['bookingData'] as Map<String, dynamic>,
              'confirmationCode': 'Stripe-${DateTime.now().millisecondsSinceEpoch}',
            },
            'amount': total,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingSession = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
