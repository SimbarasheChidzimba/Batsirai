import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/booking_providers.dart';
import '../../domain/booking.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String type; // 'restaurant' or 'event'
  final Map<String, dynamic> bookingData;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.type,
    required this.bookingData,
    required this.amount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
  
  // Factory constructor to handle pending booking data
  static Widget fromPendingData(Map<String, dynamic>? pendingData) {
    if (pendingData == null) {
      // Fallback - should not happen, but handle gracefully
      return const PaymentScreen(
        type: 'restaurant',
        bookingData: {},
        amount: 0.0,
      );
    }
    return PaymentScreen(
      type: pendingData['type'] ?? 'restaurant',
      bookingData: pendingData['bookingData'] ?? {},
      amount: (pendingData['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  bool _isProcessing = false;
  Map<String, dynamic>? _actualBookingData;
  String? _actualType;
  double? _actualAmount;

  @override
  void initState() {
    super.initState();
    // Initialize with widget data first
    _actualBookingData = widget.bookingData;
    _actualType = widget.type;
    _actualAmount = widget.amount;
    
    // Check for pending booking data if no valid data was passed via extra
    if (widget.bookingData.isEmpty || widget.amount == 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pendingData = ref.read(pendingBookingDataProvider);
        if (pendingData != null) {
          setState(() {
            _actualBookingData = pendingData['bookingData'] as Map<String, dynamic>? ?? {};
            _actualType = pendingData['type'] as String? ?? 'restaurant';
            _actualAmount = (pendingData['amount'] as num?)?.toDouble() ?? 0.0;
          });
          // Clear pending data after using it
          ref.read(pendingBookingDataProvider.notifier).state = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }
  
  String get _type => _actualType ?? widget.type;
  Map<String, dynamic> get _bookingData => _actualBookingData ?? widget.bookingData;
  double get _amount => _actualAmount ?? widget.amount;

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'card') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty ||
          _cardNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all card details')),
        );
        return;
      }
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      // Store current payment data for resuming after login
      ref.read(pendingBookingDataProvider.notifier).state = {
        'type': widget.type,
        'bookingData': widget.bookingData,
        'amount': widget.amount,
      };
      
      // Redirect to login with return path
      context.push('/login?returnPath=/payment');
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      // Create booking after payment
      if (_type == 'restaurant') {
        // Parse dates if they're strings (from JSON serialization)
        dynamic bookingDateValue = _bookingData['bookingDate'];
        dynamic bookingTimeValue = _bookingData['bookingTime'];
        
        DateTime? bookingDate;
        DateTime? bookingTime;
        
        if (bookingDateValue is String) {
          bookingDate = DateTime.parse(bookingDateValue);
        } else if (bookingDateValue is DateTime) {
          bookingDate = bookingDateValue;
        }
        
        if (bookingTimeValue is String) {
          bookingTime = DateTime.parse(bookingTimeValue);
        } else if (bookingTimeValue is DateTime) {
          bookingTime = bookingTimeValue;
        }
        
        final booking = await bookingService.createRestaurantBooking(
          userId: user.id,
          restaurantId: _bookingData['restaurantId'],
          restaurantName: _bookingData['restaurantName'],
          bookingDate: bookingDate!,
          bookingTime: bookingTime!,
          partySize: _bookingData['partySize'],
          specialRequests: _bookingData['specialRequests'],
        );
        await ref.read(restaurantBookingsProvider.notifier).addBooking(booking);
        
        if (mounted) {
          setState(() => _isProcessing = false);
          context.pushReplacement(
            '/booking-success',
            extra: {
              'type': _type,
              'bookingData': {
                ..._bookingData,
                'confirmationCode': booking.confirmationCode,
              },
              'amount': _amount,
            },
          );
        }
      } else {
        // Event booking - create event booking with tickets
        final tickets = (_bookingData['tickets'] as List<Map<String, dynamic>>)
            .map((ticketData) => EventTicket(
                  ticketTierId: ticketData['tierId'],
                  tierName: ticketData['tierName'],
                  price: ticketData['price'] as double,
                  quantity: ticketData['quantity'] as int,
                ))
            .toList();

        // Parse event date if it's a string
        dynamic eventDateValue = _bookingData['eventDate'];
        DateTime eventDate;
        
        if (eventDateValue is String) {
          eventDate = DateTime.parse(eventDateValue);
        } else if (eventDateValue is DateTime) {
          eventDate = eventDateValue;
        } else {
          throw ArgumentError('Invalid event date format: $eventDateValue');
        }

        final eventBooking = await bookingService.createEventBooking(
          userId: user.id,
          eventId: _bookingData['eventId'],
          eventTitle: _bookingData['eventTitle'],
          eventDate: eventDate,
          tickets: tickets,
          totalAmount: _amount,
        );
        
        await ref.read(eventBookingsProvider.notifier).addBooking(eventBooking);
        
        if (mounted) {
          setState(() => _isProcessing = false);
          context.pushReplacement(
            '/booking-success',
            extra: {
              'type': _type,
              'bookingData': {
                ..._bookingData,
                'confirmationCode': eventBooking.confirmationCode,
                'qrCode': eventBooking.qrCode,
              },
              'amount': _amount,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    if (_type == 'restaurant') ...[
                      _SummaryRow('Restaurant', _bookingData['restaurantName']),
                      _SummaryRow('Date', _formatDate(_parseDate(_bookingData['bookingDate']))),
                      _SummaryRow('Time', _formatTime(_parseDate(_bookingData['bookingTime']))),
                      _SummaryRow('Party Size', '${_bookingData['partySize']} guests'),
                    ] else ...[
                      _SummaryRow('Event', _bookingData['eventTitle']),
                      _SummaryRow('Date', _formatDate(_parseDate(_bookingData['eventDate']))),
                      _SummaryRow('Tickets', '${_bookingData['totalTickets']} tickets'),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '\$${_amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            _PaymentMethodOption(
              icon: PhosphorIcons.creditCard(),
              title: 'Credit/Debit Card',
              value: 'card',
              selected: _selectedPaymentMethod == 'card',
              onTap: () => setState(() => _selectedPaymentMethod = 'card'),
            ),
            const SizedBox(height: Spacing.sm),
            _PaymentMethodOption(
              icon: PhosphorIcons.wallet(),
              title: 'Mobile Money',
              value: 'mobile',
              selected: _selectedPaymentMethod == 'mobile',
              onTap: () => setState(() => _selectedPaymentMethod = 'mobile'),
            ),
            const SizedBox(height: Spacing.sm),
            _PaymentMethodOption(
              icon: PhosphorIcons.bank(),
              title: 'Bank Transfer',
              value: 'bank',
              selected: _selectedPaymentMethod == 'bank',
              onTap: () => setState(() => _selectedPaymentMethod = 'bank'),
            ),
            if (_selectedPaymentMethod == 'card') ...[
              const SizedBox(height: Spacing.xl),
              Text(
                'Card Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Pay \$${_amount.toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }

  DateTime _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.parse(date);
    throw ArgumentError('Invalid date format: $date');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

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

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
            const SizedBox(width: Spacing.md),
            Expanded(child: Text(title)),
            if (selected)
              Icon(
                PhosphorIcons.checkCircle(),
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
