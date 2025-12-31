import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/mock_data.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = MockData.restaurants.firstWhere((r) => r.id == restaurantId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(restaurant.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(restaurant.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PhosphorIcon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                      color: AppColors.rating),
                    const SizedBox(width: 4),
                    Text('${restaurant.rating} (${restaurant.reviewCount} reviews)'),
                    const Spacer(),
                    Text(restaurant.priceLevel, style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(restaurant.description),
                const SizedBox(height: 24),
                _buildInfoRow(PhosphorIcons.mapPin(), restaurant.address),
                _buildInfoRow(PhosphorIcons.phone(), restaurant.phone),
                const SizedBox(height: 24),
                const Text('Opening Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ...restaurant.openingHours.entries.map((e) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(e.key), Text(e.value)],
                    ),
                  ),
                ).toList(),
                const SizedBox(height: 24),
                const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: restaurant.amenities.map((a) => 
                    Chip(label: Text(a), backgroundColor: AppColors.primaryContainer),
                  ).toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => context.go('/restaurants/$restaurantId/book'),
            child: const Text('Book a Table'),
          ),
        ),
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
