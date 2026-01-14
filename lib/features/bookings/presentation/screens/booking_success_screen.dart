import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? bookingData;
  final String? type;
  final double? amount;

  const BookingSuccessScreen({
    super.key,
    this.bookingData,
    this.type,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    // Get data from route extra or use defaults
    final bookingInfo = bookingData ?? {};
    final bookingType = type ?? 'restaurant';
    final bookingAmount = amount ?? 0.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                bookingType == 'restaurant' ? 'Booking Confirmed!' : 'Tickets Purchased!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
              if (bookingType == 'restaurant')
                Text(
                  'Your table reservation has been confirmed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )
              else
                Text(
                  'Your event tickets have been purchased successfully',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              const SizedBox(height: Spacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    children: [
                      if (bookingInfo['confirmationCode'] != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Confirmation Code:'),
                            Text(
                              bookingInfo['confirmationCode'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.md),
                      ],
                      if (bookingType == 'restaurant') ...[
                        _InfoRow('Restaurant', bookingInfo['restaurantName'] ?? 'N/A'),
                        _InfoRow('Date', _formatDate(bookingInfo['bookingDate'])),
                        _InfoRow('Time', _formatTime(bookingInfo['bookingTime'])),
                        _InfoRow('Party Size', '${bookingInfo['partySize'] ?? 0} guests'),
                      ] else ...[
                        _InfoRow('Event', bookingInfo['eventTitle'] ?? 'N/A'),
                        _InfoRow('Date', _formatDate(bookingInfo['eventDate'])),
                        _InfoRow('Tickets', '${bookingInfo['totalTickets'] ?? 0} tickets'),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${bookingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl * 2),
              ElevatedButton(
                onPressed: () => context.go('/bookings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl * 2,
                    vertical: Spacing.md,
                  ),
                ),
                child: const Text('View My Bookings'),
              ),
              const SizedBox(height: Spacing.md),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  String _formatTime(dynamic time) {
    if (time == null) return 'N/A';
    if (time is DateTime) {
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
    return time.toString();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
