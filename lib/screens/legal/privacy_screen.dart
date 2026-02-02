import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: February 2025',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
            const Gap(24),
            _buildSection(
              '1. Information We Collect',
              'Focus Timer may collect minimal usage data to improve the app experience. This may include app preferences (such as onboarding completion) stored locally on your device. We do not collect personal identification information.',
            ),
            _buildSection(
              '2. Advertisements',
              'The app may display advertisements via Google AdMob. Ad providers may collect anonymous data for ad targeting. Please review Google\'s privacy policy for more information on how they handle data.',
            ),
            _buildSection(
              '3. Local Storage',
              'We store your preferences (e.g., onboarding status, settings) locally on your device. This data stays on your device and is not transmitted to our servers.',
            ),
            _buildSection(
              '4. Data Security',
              'We implement appropriate measures to protect any data stored by the app. However, no method of electronic storage is 100% secure.',
            ),
            _buildSection(
              '5. Children\'s Privacy',
              'Our app is not directed at children under 13. We do not knowingly collect information from children.',
            ),
            _buildSection(
              '6. Contact',
              'If you have questions about this Privacy Policy, please contact us through the app store listing or your preferred support channel.',
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Gap(8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppTheme.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
