import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSection(context, 'Account', [
            _buildListTile(PhosphorIcons.user(), 'Edit Profile', () {}),
            _buildListTile(PhosphorIcons.heart(), 'Favorites', () {}),
            _buildListTile(PhosphorIcons.calendarCheck(), 'My Bookings', () {}),
            _buildListTile(PhosphorIcons.ticket(), 'My Tickets', () {}),
          ]),
          _buildSection(context, 'Settings', [
            _buildListTile(PhosphorIcons.bell(), 'Notifications', () {}),
            _buildListTile(PhosphorIcons.lock(), 'Privacy', () {}),
            _buildListTile(PhosphorIcons.info(), 'About', () {}),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primaryContainer,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: PhosphorIcon(PhosphorIcons.user(), size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('Guest User', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text('guest@batsirai.co.zw'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            child: const Text('Sign In'),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...items,
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: PhosphorIcon(icon),
      title: Text(title),
      trailing: PhosphorIcon(PhosphorIcons.caretRight()),
      onTap: onTap,
    );
  }
}
