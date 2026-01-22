import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _bookingReminders = true;
  bool _eventUpdates = true;
  bool _promotionalOffers = false;
  bool _membershipUpdates = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          // Notification Preferences
          _buildSection(
            context,
            'Notification Preferences',
            [
              _buildSwitchTile(
                context,
                PhosphorIcons.bell(),
                'Push Notifications',
                'Receive push notifications on your device',
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.envelope(),
                'Email Notifications',
                'Receive notifications via email',
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Notification Types
          _buildSection(
            context,
            'Notification Types',
            [
              _buildSwitchTile(
                context,
                PhosphorIcons.calendarCheck(),
                'Booking Reminders',
                'Get reminded about upcoming bookings',
                _bookingReminders,
                (value) => setState(() => _bookingReminders = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.ticket(),
                'Event Updates',
                'Notifications about events you\'re interested in',
                _eventUpdates,
                (value) => setState(() => _eventUpdates = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.megaphone(),
                'Promotional Offers',
                'Special deals and promotional offers',
                _promotionalOffers,
                (value) => setState(() => _promotionalOffers = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.crownSimple(),
                'Membership Updates',
                'Updates about your membership status',
                _membershipUpdates,
                (value) => setState(() => _membershipUpdates = value),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: FilledButton(
              onPressed: () {
                // TODO: Save notification preferences to API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification preferences saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: PhosphorIcon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
