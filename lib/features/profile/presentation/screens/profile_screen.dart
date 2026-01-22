import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildHeader(context, ref, user, isAuthenticated),
          const SizedBox(height: 24),
          if (isAuthenticated) ...[
            _buildSection(context, 'Account', [
              _buildListTile(
                context,
                PhosphorIcons.user(),
                'Edit Profile',
                () => context.push('/profile/edit'),
              ),
              _buildListTile(
                context,
                PhosphorIcons.heart(),
                'Favorites',
                () => context.push('/profile/favorites'),
              ),
              _buildListTile(
                context,
                PhosphorIcons.calendarCheck(),
                'My Bookings & Tickets',
                () => context.push('/bookings'),
              ),
            ]),
          ],
          _buildSection(context, 'Settings', [
            _buildListTile(
              context,
              PhosphorIcons.bell(),
              'Notifications',
              () => context.push('/profile/notifications'),
            ),
            _buildListTile(
              context,
              PhosphorIcons.lock(),
              'Privacy',
              () => context.push('/profile/privacy'),
            ),
            _buildListTile(
              context,
              PhosphorIcons.info(),
              'About Us',
              () => context.push('/profile/about'),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: isAuthenticated
                ? OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(currentUserProvider.notifier).logout();
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
    User? user,
    bool isAuthenticated,
  ) {
    // Get user initials
    String initials = 'GU';
    if (user != null) {
      // Debug: Print user data to see what we're getting
      print('👤 Profile Screen - User data:');
      print('   ID: ${user.id}');
      print('   Email: ${user.email}');
      print('   DisplayName: ${user.displayName}');
      print('   PhoneNumber: ${user.phoneNumber}');
      
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final names = user.displayName!.trim().split(' ');
        if (names.length >= 2) {
          initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
        } else if (names.isNotEmpty && names[0].isNotEmpty) {
          initials = names[0][0].toUpperCase();
        }
      }
      
      // Fallback to email if displayName is empty
      if (initials == 'GU' && user.email.isNotEmpty) {
        initials = user.email[0].toUpperCase();
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            children: [
              // Avatar with initials or placeholder
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                        ? Text(
                            initials,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  // Edit button overlay (for future image upload)
                  if (isAuthenticated)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 16),
                          color: Colors.white,
                          onPressed: () {
                            // TODO: Implement image upload
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image upload coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Text(
                isAuthenticated ? (user?.displayName ?? user?.email ?? 'User') : 'Guest User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                isAuthenticated ? user!.email : 'Sign in to access all features',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              if (isAuthenticated && user != null) ...[
                const SizedBox(height: Spacing.md),
                if (user.membershipTier != MembershipTier.free)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          user.membershipTierName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => context.go('/membership'),
                    icon: PhosphorIcon(
                      PhosphorIcons.crownSimple(),
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      'Upgrade to Premium',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: Spacing.md),
                FilledButton(
                  onPressed: () => context.push('/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Column(
            children: items,
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
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
      trailing: PhosphorIcon(
        PhosphorIcons.caretRight(),
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
