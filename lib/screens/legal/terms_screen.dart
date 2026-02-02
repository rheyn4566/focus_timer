import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              '1. Acceptance of Terms',
              'By downloading, installing, or using the Focus Timer & White Noise app, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
            ),
            _buildSection(
              '2. Use of the App',
              'This app is provided for personal productivity and relaxation. You may use the focus timer and white noise features for non-commercial purposes. You agree not to misuse the app or use it for any unlawful purpose.',
            ),
            _buildSection(
              '3. Intellectual Property',
              'All content, design, and features of the Focus Timer app are owned by the app developers. You may not copy, modify, or distribute any part of the app without prior written permission.',
            ),
            _buildSection(
              '4. Third-Party Services',
              'The app may display advertisements provided by third parties. Your use of the app may be subject to additional terms from these third-party services.',
            ),
            _buildSection(
              '5. Disclaimer',
              'The app is provided "as is" without warranties of any kind. We do not guarantee uninterrupted or error-free operation. Use the app at your own risk.',
            ),
            _buildSection(
              '6. Changes',
              'We may update these Terms from time to time. Continued use of the app after changes constitutes acceptance of the updated Terms.',
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
