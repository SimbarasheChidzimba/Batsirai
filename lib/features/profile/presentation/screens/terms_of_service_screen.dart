import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              [
                const Text(
                  'By accessing or using the Batsirai mobile application and services ("Service"), you agree to be bound by these Terms of Service ("Terms"). If you disagree with any part of these terms, you may not access or use our Service.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'We reserve the right to update, change, or replace any part of these Terms at any time. It is your responsibility to check this page periodically for changes. Your continued use of the Service following the posting of any changes constitutes acceptance of those changes.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '2. Description of Service',
              [
                const Text(
                  'Batsirai is a platform that connects users with restaurants, events, and experiences in Zimbabwe. Our Service includes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Restaurant discovery and table booking services'),
                _buildBulletPoint('Event discovery and ticket purchasing'),
                _buildBulletPoint('Membership and subscription management'),
                _buildBulletPoint('Payment processing for bookings and tickets'),
                _buildBulletPoint('User reviews and ratings'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'We act as an intermediary between users and service providers (restaurants, event organizers). We are not responsible for the quality, safety, or delivery of services provided by third parties.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '3. User Accounts',
              [
                _buildSubsection(
                  context,
                  '3.1 Account Creation',
                  [
                    const Text(
                      'To use certain features of our Service, you must create an account. You agree to:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: Spacing.xs),
                    _buildBulletPoint('Provide accurate, current, and complete information'),
                    _buildBulletPoint('Maintain and update your account information'),
                    _buildBulletPoint('Maintain the security of your account credentials'),
                    _buildBulletPoint('Accept responsibility for all activities under your account'),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '3.2 Account Security',
                  [
                    const Text(
                      'You are responsible for maintaining the confidentiality of your account password and for all activities that occur under your account. You must immediately notify us of any unauthorized use of your account.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '3.3 Account Termination',
                  [
                    const Text(
                      'We reserve the right to suspend or terminate your account at any time for violations of these Terms, fraudulent activity, or any other reason we deem necessary to protect our Service and users.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ],
            ),

            _buildSection(
              context,
              '4. Bookings and Reservations',
              [
                const Text(
                  'When you make a booking or reservation through Batsirai:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('You enter into a contract directly with the restaurant or service provider'),
                _buildBulletPoint('We facilitate the booking but are not a party to the transaction'),
                _buildBulletPoint('Cancellation and refund policies are set by the service provider'),
                _buildBulletPoint('You are responsible for honoring your reservation or notifying the provider of cancellations'),
                _buildBulletPoint('No-shows may result in charges as determined by the provider'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'We are not liable for any issues, disputes, or damages arising from your interaction with service providers.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '5. Event Tickets',
              [
                const Text(
                  'When purchasing event tickets through Batsirai:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Tickets are subject to the event organizer\'s terms and conditions'),
                _buildBulletPoint('All sales are final unless otherwise stated by the organizer'),
                _buildBulletPoint('Event dates, times, and details are subject to change by the organizer'),
                _buildBulletPoint('We are not responsible for event cancellations, postponements, or changes'),
                _buildBulletPoint('Refund policies are determined by the event organizer'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'In case of event cancellation, refunds will be processed according to the organizer\'s policy. We will facilitate communication but are not responsible for refund decisions.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '6. Payments',
              [
                const Text(
                  'Payment terms:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('All prices are displayed in the currency specified (USD, ZWL, etc.)'),
                _buildBulletPoint('We use secure third-party payment processors'),
                _buildBulletPoint('You authorize us to charge your payment method for confirmed bookings and purchases'),
                _buildBulletPoint('Service fees may apply and will be disclosed before payment'),
                _buildBulletPoint('Refunds are subject to the cancellation policies of service providers'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'If payment fails, your booking or purchase may be cancelled. We are not responsible for any fees charged by your financial institution.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '7. Membership and Subscriptions',
              [
                const Text(
                  'Batsirai offers membership tiers with various benefits:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Membership subscriptions are billed according to the selected plan'),
                _buildBulletPoint('Subscriptions automatically renew unless cancelled'),
                _buildBulletPoint('You may cancel your subscription at any time through app settings'),
                _buildBulletPoint('Cancellation takes effect at the end of the current billing period'),
                _buildBulletPoint('Refunds for unused subscription periods are not provided'),
                _buildBulletPoint('Membership benefits are subject to change with notice'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'We reserve the right to modify membership benefits, pricing, or terms with reasonable notice to subscribers.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '8. User Conduct',
              [
                const Text(
                  'You agree not to:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Use the Service for any illegal purpose or in violation of any laws'),
                _buildBulletPoint('Impersonate any person or entity or misrepresent your affiliation'),
                _buildBulletPoint('Interfere with or disrupt the Service or servers'),
                _buildBulletPoint('Attempt to gain unauthorized access to any part of the Service'),
                _buildBulletPoint('Use automated systems to access the Service without permission'),
                _buildBulletPoint('Post false, misleading, or defamatory content'),
                _buildBulletPoint('Harass, abuse, or harm other users'),
                _buildBulletPoint('Violate intellectual property rights'),
                _buildBulletPoint('Create multiple accounts to circumvent restrictions or policies'),
              ],
            ),

            _buildSection(
              context,
              '9. Intellectual Property',
              [
                const Text(
                  'The Service and its original content, features, and functionality are owned by Batsirai and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'You may not reproduce, distribute, modify, create derivative works, publicly display, or commercially exploit any content from the Service without our express written permission.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'User-generated content (reviews, photos, etc.) remains your property, but you grant us a license to use, display, and distribute such content in connection with the Service.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '10. Disclaimers and Limitations of Liability',
              [
                _buildSubsection(
                  context,
                  '10.1 Service Availability',
                  [
                    const Text(
                      'We strive to provide reliable service but do not guarantee uninterrupted, secure, or error-free operation. The Service is provided "as is" and "as available" without warranties of any kind.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '10.2 Third-Party Services',
                  [
                    const Text(
                      'We are not responsible for the quality, safety, legality, or delivery of services provided by restaurants, event organizers, or other third parties. We do not endorse or guarantee any third-party services.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _buildSubsection(
                  context,
                  '10.3 Limitation of Liability',
                  [
                    const Text(
                      'To the maximum extent permitted by law, Batsirai shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses resulting from your use of the Service.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ],
            ),

            _buildSection(
              context,
              '11. Indemnification',
              [
                const Text(
                  'You agree to indemnify, defend, and hold harmless Batsirai and its officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses (including legal fees) arising from:',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Your use of the Service'),
                _buildBulletPoint('Your violation of these Terms'),
                _buildBulletPoint('Your violation of any rights of another party'),
                _buildBulletPoint('Your interaction with service providers'),
              ],
            ),

            _buildSection(
              context,
              '12. Dispute Resolution',
              [
                const Text(
                  'Any disputes arising from or relating to these Terms or the Service shall be resolved through:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.xs),
                _buildBulletPoint('Good faith negotiation between the parties'),
                _buildBulletPoint('Mediation if negotiation fails'),
                _buildBulletPoint('Binding arbitration in accordance with Zimbabwean arbitration laws'),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'These Terms are governed by the laws of Zimbabwe. Any legal action must be brought in the courts of Zimbabwe.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '13. Modifications to Service',
              [
                const Text(
                  'We reserve the right to modify, suspend, or discontinue any part of the Service at any time, with or without notice. We are not liable to you or any third party for any modification, suspension, or discontinuation of the Service.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '14. Termination',
              [
                const Text(
                  'We may terminate or suspend your account and access to the Service immediately, without prior notice, for any reason, including breach of these Terms. Upon termination, your right to use the Service will cease immediately.',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'You may terminate your account at any time by contacting us or using the account deletion feature in the app.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),

            _buildSection(
              context,
              '15. Contact Information',
              [
                const Text(
                  'If you have questions about these Terms of Service, please contact us:',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: Spacing.sm),
                const Text(
                  'Email: legal@batsirai.com\nPhone: +263 77 123 4567\nAddress: Harare, Zimbabwe',
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
