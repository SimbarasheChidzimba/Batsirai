import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Last Updated: January 2026',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: Spacing.xl),

            _buildSection(
              context,
              '1. Introduction',
              [
                const Text(
                  'Welcome to Batsirai ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience on our platform. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'By using Batsirai, you agree to the collection and use of information in accordance with this policy. If you do not agree with our policies and practices, please do not use our services.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '2. Information We Collect',
              [
                _buildSubsection(
                  context,
                  '2.1 Personal Information',
                  [
                    const Text(
                      'We collect information that you provide directly to us, including:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: Spacing.xs),
                    _buildBulletPoint('Name, email address, and phone number'),
                    _buildBulletPoint('Profile information and preferences'),
                    _buildBulletPoint('Payment information (processed securely through third-party providers)'),
                    _buildBulletPoint('Membership and subscription details'),
                    _buildBulletPoint('Booking and reservation information'),
                    _buildBulletPoint('Event ticket purchase history'),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '2.2 Automatically Collected Information',
                  [
                    const Text(
                      'When you use our app, we automatically collect:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: Spacing.xs),
                    _buildBulletPoint('Device information (model, operating system, unique identifiers)'),
                    _buildBulletPoint('Location data (with your permission)'),
                    _buildBulletPoint('Usage data (features used, pages visited, time spent)'),
                    _buildBulletPoint('Log information (IP address, access times, error logs)'),
                    _buildBulletPoint('Cookies and similar tracking technologies'),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '2.3 Third-Party Information',
                  [
                    const Text(
                      'We may receive information from third-party services you connect to our app, such as:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: Spacing.xs),
                    _buildBulletPoint('Social media platforms (if you sign in with social accounts)'),
                    _buildBulletPoint('Payment processors'),
                    _buildBulletPoint('Restaurant and event partners'),
                  ],
                ),
              ],
            ),

            _buildSection(
              context,
              '3. How We Use Your Information',
              [
                const Text(
                  'We use the information we collect to:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Provide, maintain, and improve our services'),
                _buildBulletPoint('Process bookings, reservations, and ticket purchases'),
                _buildBulletPoint('Manage your account and membership subscriptions'),
                _buildBulletPoint('Send you booking confirmations, updates, and reminders'),
                _buildBulletPoint('Personalize your experience and show relevant content'),
                _buildBulletPoint('Process payments and prevent fraud'),
                _buildBulletPoint('Communicate with you about our services, promotions, and updates'),
                _buildBulletPoint('Analyze usage patterns to improve our app'),
                _buildBulletPoint('Comply with legal obligations and enforce our terms'),
              ],
            ),

            _buildSection(
              context,
              '4. Information Sharing and Disclosure',
              [
                const Text(
                  'We do not sell your personal information. We may share your information in the following circumstances:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.sm),
                _buildSubsection(
                  context,
                  '4.1 Service Providers',
                  [
                    const Text(
                      'We share information with third-party service providers who perform services on our behalf, such as payment processing, data analytics, and customer support.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                _buildSubsection(
                  context,
                  '4.2 Business Partners',
                  [
                    const Text(
                      'We share booking and reservation information with restaurants and event organizers to fulfill your requests.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                _buildSubsection(
                  context,
                  '4.3 Legal Requirements',
                  [
                    const Text(
                      'We may disclose information if required by law, court order, or government regulation, or to protect our rights, property, or safety.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                _buildSubsection(
                  context,
                  '4.4 Business Transfers',
                  [
                    const Text(
                      'In the event of a merger, acquisition, or sale of assets, your information may be transferred to the acquiring entity.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ],
            ),

            _buildSection(
              context,
              '5. Data Security',
              [
                const Text(
                  'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'We use industry-standard encryption for sensitive data, secure payment processing, and regular security assessments.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '6. Your Rights and Choices',
              [
                const Text(
                  'You have the following rights regarding your personal information:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Access: Request a copy of your personal data'),
                _buildBulletPoint('Correction: Update or correct inaccurate information'),
                _buildBulletPoint('Deletion: Request deletion of your account and data'),
                _buildBulletPoint('Opt-out: Unsubscribe from marketing communications'),
                _buildBulletPoint('Location: Control location data sharing in device settings'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'To exercise these rights, please contact us at privacy@batsirai.com or through the app settings.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '7. Data Retention',
              [
                const Text(
                  'We retain your personal information for as long as necessary to provide our services, comply with legal obligations, resolve disputes, and enforce our agreements. When you delete your account, we will delete or anonymize your personal information, except where we are required to retain it for legal purposes.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '8. Children\'s Privacy',
              [
                const Text(
                  'Batsirai is not intended for users under the age of 18. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '9. International Data Transfers',
              [
                const Text(
                  'Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws. By using our services, you consent to the transfer of your information to these countries.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '10. Changes to This Privacy Policy',
              [
                const Text(
                  'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the "Last Updated" date. Your continued use of our services after such changes constitutes acceptance of the updated policy.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '11. Contact Us',
              [
                const Text(
                  'If you have questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'Email: privacy@batsirai.com\nPhone: +263 77 123 4567\nAddress: Harare, Zimbabwe',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            const SizedBox(height: Spacing.xl),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: Spacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubsection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: Spacing.xs),
        ...children,
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: Spacing.md, top: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
