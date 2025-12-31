import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/mock_data.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const BookingScreen({super.key, required this.restaurantId});
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 2;

  @override
  Widget build(BuildContext context) {
    final restaurant = MockData.restaurants.firstWhere((r) => r.id == widget.restaurantId);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Table')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(restaurant.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Text(_selectedDate == null 
              ? 'Choose Date' 
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
          ),
          const SizedBox(height: 24),
          const Text('Select Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.timeSlots.map((time) => 
              ChoiceChip(
                label: Text(time),
                selected: _selectedTime == time,
                onSelected: (_) => setState(() => _selectedTime = time),
              ),
            ).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Party Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_partySize guests', style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: () => setState(() => _partySize++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selectedDate != null && _selectedTime != null
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking confirmed!')),
                  );
                  context.go('/');
                }
              : null,
            child: const Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }
}
