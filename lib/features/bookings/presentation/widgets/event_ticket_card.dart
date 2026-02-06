import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/booking.dart';
import '../providers/booking_providers.dart';

/// Event ticket styled like a physical admission ticket:
/// stub edge, perforation line, event details, confirmation code, QR.
class EventTicketCard extends ConsumerWidget {
  final EventBooking booking;
  final bool isUpcoming;

  const EventTicketCard({
    super.key,
    required this.booking,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? Colors.grey[900]! : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ticket body with stub and perforation
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Perforation strip (dashed line effect)
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomPaint(
                      painter: _DashedLinePainter(color: borderColor),
                    ),
                  ),
                  // "ADMIT ONE" strip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                    ),
                    child: Text(
                      'ADMIT ONE',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: event details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status chip
                              _StatusChip(status: booking.status),
                              const SizedBox(height: 12),
                              // Event title
                              Text(
                                booking.eventTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              _TicketInfoRow(
                                icon: PhosphorIcons.calendarBlank(),
                                text: DateFormat('EEEE, MMM d').format(booking.eventDate),
                              ),
                              const SizedBox(height: 6),
                              _TicketInfoRow(
                                icon: PhosphorIcons.clock(),
                                text: DateFormat('h:mm a').format(booking.eventDate),
                              ),
                              const SizedBox(height: 12),
                              // Tier / section
                              if (booking.tickets.isNotEmpty) ...[
                                ...booking.tickets.map(
                                  (t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${t.quantity}x ${t.tierName}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Total paid
                              Text(
                                'Total paid \$${booking.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Confirmation code (barcode-style)
                              if (booking.confirmationCode != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Confirmation',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        booking.confirmationCode!,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontFamily: 'monospace',
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Right: QR code (if available)
                        if (booking.qrCode != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: QrImageView(
                              data: booking.qrCode!,
                              version: QrVersions.auto,
                              size: 88,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bottom perforation
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomPaint(
                      painter: _DashedLinePainter(color: borderColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Actions (View QR, Cancel) for upcoming confirmed
          if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking.qrCode != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showQRCode(context, booking.qrCode!),
                      icon: const Icon(Icons.qr_code_2, size: 20),
                      label: const Text('Show at entrance'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context, ref, booking),
                    icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context, String qrCodeData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: qrCodeData,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Show this QR code at the event entrance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
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

  void _showCancelDialog(BuildContext context, WidgetRef ref, EventBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking'),
        content: const Text(
          'Are you sure you want to cancel this event booking?',
        ),
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
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.confirmed => ('Confirmed', Colors.green.shade700),
      BookingStatus.pending => ('Pending', Colors.orange.shade700),
      BookingStatus.cancelled => ('Cancelled', Colors.red.shade700),
      BookingStatus.completed => ('Completed', Colors.blue.shade700),
      BookingStatus.noShow => ('No show', Colors.grey.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TicketInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 6;
    const gap = 4;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + dashWidth, size.height / 2), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
