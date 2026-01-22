import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cards/event_card.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/event_providers.dart';
import '../../domain/event.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Force refresh to show loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(eventsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);
    final availableCategories = ref.watch(availableEventCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          _buildCategoryFilter(availableCategories),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.calendarX(),
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: Spacing.md),
                        const Text('No events found'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: EventCard(
                        event: event,
                        onTap: () => context.push('/events/${event.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: Spacing.md),
                    child: EventCardShimmer(),
                  );
                },
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
                    Text('Error loading events: $error'),
                    const SizedBox(height: Spacing.md),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(eventsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<EventCategory> categories) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" option
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (_) => setState(() {
                _selectedCategory = null;
                ref.read(selectedEventCategoriesProvider.notifier).state = [];
              }),
            ),
          ),
          // Category options from API
          ...categories.map((category) {
            final event = Event(
              id: '',
              title: '',
              description: '',
              images: [],
              category: category,
              status: EventStatus.upcoming,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              venueName: '',
              venueAddress: '',
              latitude: 0,
              longitude: 0,
              ticketTiers: [],
            );
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(event.categoryName),
                selected: _selectedCategory == category,
                onSelected: (_) => setState(() {
                  _selectedCategory = category;
                  ref.read(selectedEventCategoriesProvider.notifier).state = [category];
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
