import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          // App Logo/Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Batsirai',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Work & Play, Verified',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // About Section
          _buildSection(
            context,
            'About Batsirai',
            [
              const Text(
                'Batsirai is the ultimate lifestyle and service superapp for Zimbabweans and the diaspora. '
                'We connect you with the best restaurants, events, and experiences across Zimbabwe.',
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: Spacing.md),
              const Text(
                'Our mission is to make it easy for you to discover, book, and enjoy the finest '
                'dining experiences and events while supporting local businesses and communities.',
                style: TextStyle(height: 1.6),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Features Section
          _buildSection(
            context,
            'What We Offer',
            [
              _buildFeatureItem(
                context,
                PhosphorIcons.forkKnife(),
                'Restaurant Discovery',
                'Find and book tables at the best restaurants in Zimbabwe',
              ),
              _buildFeatureItem(
                context,
                PhosphorIcons.ticket(),
                'Event Tickets',
                'Discover and purchase tickets for concerts, festivals, and more',
              ),
              _buildFeatureItem(
                context,
                PhosphorIcons.crownSimple(),
                'Premium Membership',
                'Exclusive discounts and benefits for members',
              ),
              _buildFeatureItem(
                context,
                PhosphorIcons.shieldCheck(),
                'Verified Partners',
                'All our partners are verified and trusted',
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Contact Section
          _buildSection(
            context,
            'Contact Us',
            [
              _buildContactItem(
                context,
                PhosphorIcons.envelope(),
                'Email',
                'support@batsirai.com',
                () => _launchEmail('support@batsirai.com'),
              ),
              _buildContactItem(
                context,
                PhosphorIcons.phone(),
                'Phone',
                '+263 77 123 4567',
                () => _launchPhone('+263771234567'),
              ),
              _buildContactItem(
                context,
                PhosphorIcons.mapPin(),
                'Address',
                'Harare, Zimbabwe',
                null,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Social Media Section
          _buildSection(
            context,
            'Follow Us',
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    context,
                    PhosphorIcons.facebookLogo(),
                    'Facebook',
                    () => _launchUrl('https://facebook.com/batsirai'),
                  ),
                  _buildSocialButton(
                    context,
                    PhosphorIcons.instagramLogo(),
                    'Instagram',
                    () => _launchUrl('https://instagram.com/batsirai'),
                  ),
                  _buildSocialButton(
                    context,
                    PhosphorIcons.twitterLogo(),
                    'Twitter',
                    () => _launchUrl('https://twitter.com/batsirai'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Legal Links
          _buildSection(
            context,
            'Legal',
            [
              _buildListTile(
                context,
                PhosphorIcons.fileText(),
                'Privacy Policy',
                () => context.push('/profile/privacy-policy'),
              ),
              _buildListTile(
                context,
                PhosphorIcons.scroll(),
                'Terms of Service',
                () => context.push('/profile/terms-of-service'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // Copyright
          Center(
            child: Text(
              '© 2026 Batsirai. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: Spacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: PhosphorIcon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            PhosphorIcon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: PhosphorIcon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: PhosphorIcon(
        PhosphorIcons.caretRight(),
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
