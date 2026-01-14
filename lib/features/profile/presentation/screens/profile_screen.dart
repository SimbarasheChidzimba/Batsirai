import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = user != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          _buildHeader(context, ref, user, isAuthenticated),
          const SizedBox(height: 24),
          if (isAuthenticated) ...[
            _buildSection(context, 'Account', [
              _buildListTile(
                PhosphorIcons.user(),
                'Edit Profile',
                () {},
              ),
              _buildListTile(
                PhosphorIcons.heart(),
                'Favorites',
                () {},
              ),
              _buildListTile(
                PhosphorIcons.calendarCheck(),
                'My Bookings',
                () => context.push('/bookings'),
              ),
              _buildListTile(
                PhosphorIcons.ticket(),
                'My Tickets',
                () => context.push('/bookings'),
              ),
            ]),
          ],
          _buildSection(context, 'Settings', [
            _buildListTile(PhosphorIcons.bell(), 'Notifications', () {}),
            _buildListTile(PhosphorIcons.lock(), 'Privacy', () {}),
            _buildListTile(PhosphorIcons.info(), 'About', () {}),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isAuthenticated
                ? OutlinedButton.icon(
                    onPressed: () async {
                      await mockLogout();
                      ref.read(currentUserProvider.notifier).state = null;
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  )
                : FilledButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    user,
    bool isAuthenticated,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primaryContainer,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: PhosphorIcon(
              PhosphorIcons.user(),
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAuthenticated ? (user.displayName ?? user.email) : 'Guest User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            isAuthenticated ? user.email : 'Sign in to access all features',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (isAuthenticated && user.membershipTier != null) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(user.membershipTierName),
              backgroundColor: AppColors.secondaryContainer,
            ),
          ],
          if (!isAuthenticated) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign In'),
            ),
          ],
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
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
