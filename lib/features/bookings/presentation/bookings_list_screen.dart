import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../domain/booking.dart';
import 'providers/booking_providers.dart';
import 'widgets/event_ticket_card.dart';

/// Polling interval for booking status (e.g. pending → confirmed so "Pay commitment fee" appears)
const _bookingStatusPollInterval = Duration(seconds: 30);

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen> {
  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    _statusPollTimer = Timer.periodic(_bookingStatusPollInterval, (_) {
      if (!mounted) return;
      ref.read(restaurantBookingsProvider.notifier).refresh();
      ref.read(eventBookingsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'My Tickets'),
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
            const _MyTicketsList(),
          ],
        ),
      ),
    );
  }
}

class _MyTicketsList extends ConsumerWidget {
  const _MyTicketsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.ticket(),
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tickets yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myTicketsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final booking = tickets[index];
              return EventTicketCard(
                booking: booking,
                isUpcoming: booking.eventDate.isAfter(DateTime.now()),
              );
            },
          ),
        );
      },
      loading: () => const _BookingsLoading(),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.warning(), size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading tickets',
              style: TextStyle(color: Colors.red[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(myTicketsProvider),
              child: const Text('Retry'),
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
                return EventTicketCard(
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
            if (isUpcoming && booking.status == BookingStatus.pending) ...[
              const Divider(),
              Text(
                'Waiting for the restaurant to confirm. You\'ll be able to pay the commitment fee here once confirmed.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _payCommitmentFee(context, ref),
                      icon: const Icon(Icons.payment, size: 20),
                      label: const Text('Pay Commitment Fee'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context, ref),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            if (booking.status == BookingStatus.completed) ...[
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showTicket(context, ref),
                  icon: const Icon(Icons.qr_code_2, size: 20),
                  label: const Text('View Ticket'),
                ),
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

  Future<void> _payCommitmentFee(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref.read(bookingServiceProvider).payCommitmentFee(booking.id);
      if (!context.mounted) return;
      final success = await context.push<bool>('/stripe-checkout', extra: url);
      if (context.mounted && success == true) {
        ref.read(restaurantBookingsProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful. Your booking is confirmed.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start payment: $e')),
      );
    }
  }

  Future<void> _showTicket(BuildContext context, WidgetRef ref) async {
    try {
      final ticket =
          await ref.read(bookingServiceProvider).getBookingTicket(booking.id);
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _TicketSheet(
          booking: booking,
          ticketData: ticket,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load ticket: $e')),
      );
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

class _TicketSheet extends StatelessWidget {
  final RestaurantBooking booking;
  final Map<String, dynamic> ticketData;

  const _TicketSheet({
    required this.booking,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    final qrCode = ticketData['qrCode']?.toString() ??
        ticketData['qr_code']?.toString() ??
        ticketData['code']?.toString() ??
        booking.confirmationCode;
    final imageUrl = ticketData['imageUrl']?.toString() ??
        ticketData['image_url']?.toString() ??
        ticketData['qrImageUrl']?.toString();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your table reservation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              booking.restaurantName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('EEEE, MMM d').format(booking.bookingDate)} at ${DateFormat('jm').format(booking.bookingTime)} · ${booking.partySize} guests',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (booking.confirmationCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Code: ${booking.confirmationCode}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildQrPlaceholder(context, qrCode),
                ),
              )
            else if (qrCode != null && qrCode.isNotEmpty)
              _buildQrPlaceholder(context, qrCode)
            else
              Icon(Icons.confirmation_number, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPlaceholder(BuildContext context, String? data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: QrImageView(
        data: data ?? booking.id,
        version: QrVersions.auto,
        size: 200,
        backgroundColor: Colors.white,
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
