import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.user(), size: 80, color: AppColors.textSecondary),
                const SizedBox(height: Spacing.lg),
                Text('Welcome to Batsirai', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: Spacing.sm),
                const Text('Sign in to access exclusive deals', textAlign: TextAlign.center),
                const SizedBox(height: Spacing.xl),
                ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Sign In')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 40, child: Text(user!.displayName?[0] ?? 'U', style: const TextStyle(fontSize: 32))),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? 'User', style: Theme.of(context).textTheme.titleLarge),
                    Text(user.email),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          ListTile(leading: Icon(PhosphorIcons.ticket()), title: const Text('My Bookings'), onTap: () => context.push('/profile/bookings')),
          ListTile(leading: Icon(PhosphorIcons.heart()), title: const Text('Favorites'), onTap: () {}),
          ListTile(leading: Icon(PhosphorIcons.gear()), title: const Text('Settings'), onTap: () {}),
          const SizedBox(height: Spacing.lg),
          OutlinedButton.icon(onPressed: () async { await mockLogout(); ref.read(currentUserProvider.notifier).state = null; }, icon: Icon(PhosphorIcons.signOut()), label: const Text('Sign Out')),
        ],
      ),
    );
  }
}
