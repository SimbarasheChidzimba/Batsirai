import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/mock_data.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const BookingScreen({super.key, required this.restaurantId});
  
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  int _partySize = 2;
  final _specialRequestsController = TextEditingController();

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = MockData.restaurants.firstWhere((r) => r.id == widget.restaurantId);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Table')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Restaurant Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      restaurant.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.category,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Date Selection
          const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null; // Reset time when date changes
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDate == null 
              ? 'Choose Date' 
              : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)),
          ),
          const SizedBox(height: 24),
          
          // Time Selection
          const Text('Select Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_selectedDate != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.timeSlots.map((timeStr) {
                final timeParts = timeStr.split(':');
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                final time = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  hour,
                  minute,
                );
                final isSelected = _selectedTime != null &&
                    _selectedTime!.hour == hour &&
                    _selectedTime!.minute == minute;
                
                return ChoiceChip(
                  label: Text(timeStr),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTime = time),
                );
              }).toList(),
            )
          else
            const Text('Please select a date first', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          // Party Size
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
                onPressed: _partySize < 20 ? () => setState(() => _partySize++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Special Requests
          TextField(
            controller: _specialRequestsController,
            decoration: const InputDecoration(
              labelText: 'Special Requests (Optional)',
              hintText: 'Dietary restrictions, allergies, etc.',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_selectedDate != null && _selectedTime != null)
              ? () => _proceedToPayment(restaurant)
              : null,
            child: const Text('Continue to Payment'),
          ),
        ),
      ),
    );
  }

  void _proceedToPayment(restaurant) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to make a booking')),
      );
      return;
    }

    // Calculate amount (mock - could be based on party size, restaurant, etc.)
    final amount = _partySize * 5.0; // $5 per person deposit

    context.push(
      '/payment',
      extra: {
        'type': 'restaurant',
        'bookingData': {
          'restaurantId': restaurant.id,
          'restaurantName': restaurant.name,
          'bookingDate': _selectedDate,
          'bookingTime': _selectedTime,
          'partySize': _partySize,
          'specialRequests': _specialRequestsController.text.isEmpty
              ? null
              : _specialRequestsController.text,
        },
        'amount': amount,
      },
    );
  }
}
