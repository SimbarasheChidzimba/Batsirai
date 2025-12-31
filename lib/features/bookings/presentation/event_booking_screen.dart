import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class EventBookingScreen extends StatelessWidget {
  final String eventId;

  const EventBookingScreen({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Tickets')),
      body: const Center(child: Text('Event booking screen')),
    );
  }
}
