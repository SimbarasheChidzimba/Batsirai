import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/restaurant_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';

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
    final restaurantAsync = ref.watch(restaurantByIdProvider(widget.restaurantId));
    
    return restaurantAsync.when(
      data: (restaurant) {
        if (restaurant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book a Table')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Restaurant not found'),
                ],
              ),
            ),
          );
        }
        
        return _buildBookingForm(context, restaurant);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Book a Table')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Book a Table')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading restaurant', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(restaurantByIdProvider(widget.restaurantId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, restaurant) {

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
                    child: restaurant.images.isNotEmpty
                        ? Image.network(
                            restaurant.images[0],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant),
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
                          restaurant.categoryName,
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
          
          // Date Selection (only open days selectable)
          const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _initialSelectableDate(restaurant),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                selectableDayPredicate: (day) => _isRestaurantOpenOnDate(restaurant, day),
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
              ? () => _submitReservationRequest(restaurant)
              : null,
            child: const Text('Submit Reservation Request'),
          ),
        ),
      ),
    );
  }

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  bool _isRestaurantOpenOnDate(dynamic restaurant, DateTime date) {
    final openingHours = restaurant.openingHours as Map<String, String>?;
    if (openingHours == null || openingHours.isEmpty) return true;
    final dayName = _dayNames[date.weekday - 1];
    final hours = openingHours[dayName] ??
        openingHours[dayName.toLowerCase()] ??
        openingHours[dayName.toUpperCase()] ??
        '';
    if (hours.isEmpty) return false;
    if (hours.trim().toLowerCase().contains('closed')) return false;
    return true;
  }

  DateTime _initialSelectableDate(dynamic restaurant) {
    var date = DateTime.now();
    for (var i = 0; i < 8; i++) {
      final d = date.add(Duration(days: i));
      if (_isRestaurantOpenOnDate(restaurant, d)) return d;
    }
    return date;
  }

  Future<void> _submitReservationRequest(restaurant) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ref.read(pendingBookingDataProvider.notifier).state = {
        'type': 'restaurant',
        'restaurantId': restaurant.id,
        'restaurantName': restaurant.name,
        'bookingDate': _selectedDate,
        'bookingTime': _selectedTime,
        'partySize': _partySize,
      };
      context.push('/login?returnPath=/bookings');
      return;
    }

    final date = _selectedDate!;
    final time = _selectedTime!;
    final scheduledDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final timeSlot =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final booking = await bookingService.createReservationRequest(
        serviceId: restaurant.id,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        attendees: _partySize,
        type: 'RESTAURANT',
      );
      ref.read(restaurantBookingsProvider.notifier).addBooking(booking);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reservation request submitted. We\'ll notify you when the restaurant confirms. You can then pay the commitment fee from My Bookings.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    }
  }
}
