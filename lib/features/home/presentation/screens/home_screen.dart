import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/mock_data.dart';
import '../../../../models/restaurant.dart';
import '../../../../models/event.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = MockData.restaurants.take(10).toList();
    final events = MockData.events.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batsirai', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text('Discover. Book. Experience.',
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Trending Restaurants', restaurants, true),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Upcoming Events', events, false),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickAction(context, 'Restaurants', PhosphorIcons.forkKnife(), 
          AppColors.primary, () => context.go('/restaurants')),
        _quickAction(context, 'Events', PhosphorIcons.ticket(),
          AppColors.accent, () => context.go('/events')),
        _quickAction(context, 'Premium', PhosphorIcons.crownSimple(),
          AppColors.premium, () => context.go('/membership')),
      ],
    );
  }

  Widget _quickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: PhosphorIcon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List items, bool isRestaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => context.go(isRestaurant 
                  ? '/restaurants/${item.id}' 
                  : '/events/${item.id}'),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRestaurant ? item.name : item.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isRestaurant) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              PhosphorIcon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                                color: AppColors.rating, size: 14),
                              const SizedBox(width: 4),
                              Text(item.rating.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
