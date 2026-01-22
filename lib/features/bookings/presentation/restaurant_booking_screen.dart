import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';

class RestaurantBookingScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantBookingScreen({required this.restaurantId, super.key});

  @override
  State<RestaurantBookingScreen> createState() => _RestaurantBookingScreenState();
}

class _RestaurantBookingScreenState extends State<RestaurantBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  int _partySize = 2;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Reservation')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              _DateChip(label: 'Today', date: DateTime.now(), selected: _isSameDay(_selectedDate, DateTime.now()), onTap: () => setState(() => _selectedDate = DateTime.now())),
              const SizedBox(width: Spacing.sm),
              _DateChip(label: 'Tomorrow', date: DateTime.now().add(const Duration(days: 1)), selected: _isSameDay(_selectedDate, DateTime.now().add(const Duration(days: 1))), onTap: () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1)))),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Text('Select Time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (context, index) {
                final time = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 11 + index ~/ 2, index.isOdd ? 30 : 0);
                return Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: ChoiceChip(
                    label: Text(DateFormat('h:mm a').format(time)),
                    selected: _selectedTime == time,
                    onSelected: (selected) => setState(() => _selectedTime = time),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text('Party Size', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              IconButton(icon: Icon(PhosphorIcons.minus()), onPressed: () => setState(() => _partySize = (_partySize - 1).clamp(1, 20))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('$_partySize', style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(icon: Icon(PhosphorIcons.plus()), onPressed: () => setState(() => _partySize = (_partySize + 1).clamp(1, 20))),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Special Requests (Optional)'), maxLines: 3),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: ElevatedButton(
            onPressed: _selectedTime != null ? _confirmBooking : null,
            child: const Text('Confirm Reservation'),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _confirmBooking() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
    Navigator.pop(context);
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.date, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? AppColors.primary : null,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
    );
  }
}
