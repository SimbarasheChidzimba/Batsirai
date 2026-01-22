import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'providers/event_providers.dart';
import '../../../core/widgets/cards/event_card.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.funnel()),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              ),
              onChanged: (value) {
                ref.read(eventSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Quick date filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              children: [
                _QuickFilterChip(
                  label: 'Today',
                  filter: EventDateFilter.today,
                ),
                _QuickFilterChip(
                  label: 'Tomorrow',
                  filter: EventDateFilter.tomorrow,
                ),
                _QuickFilterChip(
                  label: 'This Weekend',
                  filter: EventDateFilter.thisWeekend,
                ),
                _QuickFilterChip(
                  label: 'This Week',
                  filter: EventDateFilter.thisWeek,
                ),
              ],
            ),
          ),

          // Results
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
                  padding: const EdgeInsets.all(Spacing.md),
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
                padding: const EdgeInsets.all(Spacing.md),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: Spacing.md),
                    child: EventCardShimmer(),
                  );
                },
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    // TODO: Implement filters bottom sheet
  }
}

class _QuickFilterChip extends ConsumerWidget {
  final String label;
  final EventDateFilter filter;

  const _QuickFilterChip({
    required this.label,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedDateFilterProvider);
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedDateFilterProvider.notifier).state =
              selected ? filter : null;
        },
      ),
    );
  }
}
