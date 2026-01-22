import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../domain/booking.dart';
import 'providers/booking_providers.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsList(
              bookingsAsync: ref.watch(upcomingBookingsProvider),
              emptyMessage: 'No upcoming bookings',
              isUpcoming: true,
            ),
            _BookingsList(
              bookingsAsync: ref.watch(pastBookingsProvider),
              emptyMessage: 'No past bookings',
              isUpcoming: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final AsyncValue<List<dynamic>> bookingsAsync;
  final String emptyMessage;
  final bool isUpcoming;

  const _BookingsList({
    required this.bookingsAsync,
    required this.emptyMessage,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return bookingsAsync.when(
      data: (bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.calendarBlank(),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(restaurantBookingsProvider.notifier).refresh();
            ref.read(eventBookingsProvider.notifier).refresh();
          },
          child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
              if (booking is RestaurantBooking) {
                return _RestaurantBookingCard(
                  booking: booking,
                  isUpcoming: isUpcoming,
                );
              } else if (booking is EventBooking) {
                return _EventBookingCard(
                  booking: booking,
                  isUpcoming: isUpcoming,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
      loading: () => const _BookingsLoading(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning(),
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bookings',
              style: TextStyle(color: Colors.red[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(restaurantBookingsProvider.notifier).refresh();
                ref.read(eventBookingsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantBookingCard extends ConsumerWidget {
  final RestaurantBooking booking;
  final bool isUpcoming;

  const _RestaurantBookingCard({
    required this.booking,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.forkKnife(),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                        booking.restaurantName,
                        style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(booking.status),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (booking.confirmationCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.confirmationCode!,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            _InfoRow(
              icon: PhosphorIcons.calendar(),
              label: 'Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(booking.bookingDate),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: PhosphorIcons.clock(),
              label: 'Time',
              value: DateFormat('h:mm a').format(booking.bookingTime),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: PhosphorIcons.users(),
              label: 'Party Size',
              value: '${booking.partySize} guests',
            ),
            if (booking.specialRequests != null && booking.specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: PhosphorIcons.note(),
                label: 'Special Requests',
                value: booking.specialRequests!,
              ),
            ],
            if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(restaurantBookingsProvider.notifier).cancelBooking(booking.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _EventBookingCard extends ConsumerWidget {
  final EventBooking booking;
  final bool isUpcoming;

  const _EventBookingCard({
    required this.booking,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.ticket(),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking.eventTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(booking.status),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (booking.confirmationCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.confirmationCode!,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            _InfoRow(
              icon: PhosphorIcons.calendar(),
              label: 'Event Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(booking.eventDate),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: PhosphorIcons.ticket(),
              label: 'Tickets',
              value: '${booking.totalTickets} ticket${booking.totalTickets > 1 ? 's' : ''}',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: PhosphorIcons.currencyDollar(),
              label: 'Total Paid',
              value: '\$${booking.totalAmount.toStringAsFixed(2)}',
            ),
            if (booking.tickets.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Ticket Details:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...booking.tickets.map((ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${ticket.quantity}x ${ticket.tierName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '\$${ticket.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
              const Divider(),
              Row(
                children: [
                  if (booking.qrCode != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQRCode(context, booking.qrCode!),
                        icon: const Icon(Icons.qr_code),
                        label: const Text('View QR Code'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  void _showQRCode(BuildContext context, String qrCodeData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Show this QR code at the event entrance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this event booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(eventBookingsProvider.notifier).cancelBooking(booking.id);
              if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _BookingsLoading extends StatelessWidget {
  const _BookingsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 16,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
              const Spacer(),
              Container(
                width: 150,
                height: 16,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Container(
                width: 120,
                height: 16,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
