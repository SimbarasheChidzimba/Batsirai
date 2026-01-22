import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/membership_providers.dart';
import '../../data/models/membership_tier_model.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(membershipTiersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Membership')),
      body: tiersAsync.when(
        data: (tiers) {
          if (tiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.crownSimple(),
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: Spacing.md),
                  const Text('No membership tiers available'),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Unlock Exclusive Benefits',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Join thousands of members enjoying premium perks across Zimbabwe',
              ),
              const SizedBox(height: 24),
              ...tiers.map((tier) => _buildTierCard(context, tier)),
            ],
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Unlock Exclusive Benefits',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ...List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ShimmerLoading(width: double.infinity, height: 200),
            )),
          ],
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: Spacing.md),
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Text(
                  'Error loading membership tiers: $error',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Spacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(membershipTiersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, MembershipTierModel tier) {
    final currencySymbol = _getCurrencySymbol(tier.currency);
    final priceText = tier.billingPeriod == 'yearly'
        ? '$currencySymbol${tier.price.toStringAsFixed(2)}/year'
        : '$currencySymbol${tier.price.toStringAsFixed(2)}/${tier.billingPeriod}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: tier.isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: tier.isPopular
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tier.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (tier.isPopular) const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (tier.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tier.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  priceText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            if (tier.benefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...tier.benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.check(),
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  )),
            ],
            if (tier.discountPercentage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tier.discountPercentage}% Discount',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Subscribed to ${tier.name}!'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: tier.isPopular
                      ? AppColors.primary
                      : AppColors.primaryContainer,
                  foregroundColor: tier.isPopular
                      ? Colors.white
                      : AppColors.primary,
                ),
                child: const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'ZWL':
      case 'ZWD':
        return 'Z\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '\$';
    }
  }
}
