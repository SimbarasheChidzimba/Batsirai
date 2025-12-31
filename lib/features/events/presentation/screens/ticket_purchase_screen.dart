import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_data.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Get Tickets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const Text('Select Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...event.ticketTiers.map((tier) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tier.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('\$${tier.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tier.description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
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
                      Text('${_quantities[tier.id] ?? 0}', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => setState(() => _quantities[tier.id] = (_quantities[tier.id] ?? 0) + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
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
                  Text('\$$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: total > 0 
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tickets purchased!')),
                      );
                      context.go('/');
                    }
                  : null,
                child: const Text('Purchase Tickets'),
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
}
