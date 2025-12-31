import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Membership')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Unlock Exclusive Benefits', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Join thousands of members enjoying premium perks across Zimbabwe'),
          const SizedBox(height: 24),
          _buildTierCard(context, 'Basic', 5.0, [
            'Access to exclusive deals',
            '10% off at partner restaurants',
            'Priority booking',
          ]),
          _buildTierCard(context, 'Standard', 7.0, [
            'Everything in Basic',
            '15% off at partner restaurants',
            'Early event access',
            'Free delivery on orders',
          ]),
          _buildTierCard(context, 'Premium', 10.0, [
            'Everything in Standard',
            '20% off at all partners',
            'VIP event access',
            'Concierge service',
            'Exclusive member events',
          ]),
        ],
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, String tier, double price, List<String> benefits) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tier, style: Theme.of(context).textTheme.titleLarge),
                Text('\$$price/mo', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  PhosphorIcon(PhosphorIcons.check(), color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(benefit)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subscribed to $tier!')),
                );
              },
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }
}
