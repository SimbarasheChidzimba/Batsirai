import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/mock_data.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    var events = MockData.events;
    if (_selectedCategory != 'All') {
      events = events.where((e) => e.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) => _buildEventCard(context, events[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.eventCategories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.eventCategories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: category == _selectedCategory,
              onSelected: (_) => setState(() => _selectedCategory = category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, event) {
    return GestureDetector(
      onTap: () => context.go('/events/${event.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(event.startDate.month.toString(),
                    style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                  Text(event.startDate.day.toString(),
                    style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PhosphorIcon(PhosphorIcons.mapPin(), size: 14),
                        const SizedBox(width: 4),
                        Expanded(child: Text(event.venueName,
                          style: Theme.of(context).textTheme.bodySmall, maxLines: 1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(event.priceRange,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
