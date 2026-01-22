import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _profileVisibility = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _dataSharing = false;
  bool _analyticsTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          // Privacy Settings
          _buildSection(
            context,
            'Privacy Settings',
            [
              _buildSwitchTile(
                context,
                PhosphorIcons.user(),
                'Profile Visibility',
                'Allow others to see your profile',
                _profileVisibility,
                (value) => setState(() => _profileVisibility = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.envelope(),
                'Show Email',
                'Display your email on your profile',
                _showEmail,
                (value) => setState(() => _showEmail = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.phone(),
                'Show Phone Number',
                'Display your phone number on your profile',
                _showPhone,
                (value) => setState(() => _showPhone = value),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Data & Analytics
          _buildSection(
            context,
            'Data & Analytics',
            [
              _buildSwitchTile(
                context,
                PhosphorIcons.shareNetwork(),
                'Data Sharing',
                'Share anonymized data to improve our services',
                _dataSharing,
                (value) => setState(() => _dataSharing = value),
              ),
              _buildSwitchTile(
                context,
                PhosphorIcons.chartLine(),
                'Analytics Tracking',
                'Help us improve by sharing usage analytics',
                _analyticsTracking,
                (value) => setState(() => _analyticsTracking = value),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // Security Options
          _buildSection(
            context,
            'Security',
            [
              _buildListTile(
                context,
                PhosphorIcons.lock(),
                'Change Password',
                'Update your account password',
                () {
                  // TODO: Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change password feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                PhosphorIcons.shield(),
                'Two-Factor Authentication',
                'Add an extra layer of security',
                () {
                  // TODO: Navigate to 2FA setup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('2FA feature coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // Privacy Policy & Terms
          _buildSection(
            context,
            'Legal',
            [
              _buildListTile(
                context,
                PhosphorIcons.fileText(),
                'Privacy Policy',
                'Read our privacy policy',
                () => context.push('/profile/privacy-policy'),
              ),
              _buildListTile(
                context,
                PhosphorIcons.scroll(),
                'Terms of Service',
                'Read our terms of service',
                () => context.push('/profile/terms-of-service'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: FilledButton(
              onPressed: () {
                // TODO: Save privacy preferences to API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy preferences saved!'),
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

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
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
      subtitle: Text(subtitle),
      trailing: PhosphorIcon(
        PhosphorIcons.caretRight(),
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
