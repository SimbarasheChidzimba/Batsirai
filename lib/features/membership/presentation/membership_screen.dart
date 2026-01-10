import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Plans')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Text('Choose Your Plan', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: Spacing.lg),
          _PlanCard(
            name: 'Local Basic',
            price: 5.0,
            features: ['Restaurant discounts', 'Event access', '10 saves'],
            color: AppColors.primary,
          ),
          const SizedBox(height: Spacing.md),
          _PlanCard(
            name: 'Local Plus',
            price: 7.0,
            features: ['All Basic features', 'Unlimited saves', 'Priority support'],
            color: AppColors.secondary,
            popular: true,
          ),
          const SizedBox(height: Spacing.md),
          _PlanCard(
            name: 'Local Premium',
            price: 10.0,
            features: ['All Plus features', 'VIP access', 'Free event tickets'],
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final double price;
  final List<String> features;
  final Color color;
  final bool popular;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    required this.color,
    this.popular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (popular) Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: Spacing.sm),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.xs),
            Text('\$${price.toStringAsFixed(0)}/month', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
            const SizedBox(height: Spacing.md),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                children: [
                  Icon(PhosphorIcons.check(), size: 16, color: color),
                  const SizedBox(width: Spacing.sm),
                  Text(f),
                ],
              ),
            )),
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: const Text('Subscribe')),
            ),
          ],
        ),
      ),
    );
  }
}
