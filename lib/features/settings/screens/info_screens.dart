import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = isDark ? Colors.white : Colors.black87;
    final subTheme = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'About QARI 24/7',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'QARI 24/7',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              'Your 24/7 AI Quran Companion',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: subTheme,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textTheme,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'QARI 24/7 is designed to make Quran learning, memorization, and correction accessible to everyone around the world, anytime. By combining advanced AI speech recognition technology with interactive features, we help you recite correctly, maintain streaks, and grow closer to the Holy Quran daily.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.6,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Key Features',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textTheme,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureTile(
              icon: Icons.mic_rounded,
              title: 'AI Speech Recognition',
              description: 'Recite verses and receive instant audio evaluations, helping you identify pronunciation and tajweed mistakes.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              icon: Icons.local_fire_department_rounded,
              title: 'Streaks & Learning Habits',
              description: 'Stay motivated with daily reading streaks, reminders, and detailed statistics showing your progress.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              icon: Icons.people_alt_rounded,
              title: 'Interactive Community',
              description: 'Join virtual study circles, share insights, learn with others, and create custom local communities.',
              isDark: isDark,
            ),
            const SizedBox(height: 40),
            Text(
              '© ${DateTime.now().year} Qari 24/7. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: subTheme,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = isDark ? Colors.white : Colors.black87;
    const supportEmail = 'Thehub923community@gmail.com';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF032B1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore common questions or reach out directly to our support team.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textTheme,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQTile(
              question: 'How does the AI recitation correction work?',
              answer: 'QARI 24/7 uses advanced speech analysis models optimized for Quranic Arabic. When you recite, our engine analyzes your voice against correct Tajweed and word patterns, pointing out mistakes or areas for improvement.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFAQTile(
              question: 'My premium status disappeared. How do I restore it?',
              answer: 'Go to your Profile, tap on the "Restore Purchases" button below the subscription status. This will query the App Store or Google Play Store for your active subscriptions and sync them back to your account.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFAQTile(
              question: 'How do I create or join a community group?',
              answer: 'Navigate to the Community tab in the bottom bar, where you can see existing groups or create your own by setting a group name, photo, and rules. You can then invite others to build recitation habits together.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildFAQTile(
              question: 'Can I use QARI 24/7 offline?',
              answer: 'Core recitation tools and text reading can be accessed offline. However, AI voice recognition analysis and community syncing require a stable internet connection.',
              isDark: isDark,
            ),
            const SizedBox(height: 28),
            Text(
              'Still need help?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textTheme,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Support',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textTheme,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              supportEmail,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: supportEmail));
                        Get.snackbar(
                          'Success',
                          'Email copied to clipboard!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Copy Email Address',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        ),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          title: Text(
            question,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated: June 14, 2026',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _buildTermSection(
              title: '1. Acceptance of Terms',
              content: 'By downloading, installing, or using the QARI 24/7 mobile application, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildTermSection(
              title: '2. User Accounts & Registration',
              content: 'To use certain features of the application, including tracking progress and participating in communities, you must register for an account. You agree to provide accurate, current, and complete information and maintain the security of your password and credentials.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildTermSection(
              title: '3. Premium Subscriptions & Purchases',
              content: 'QARI 24/7 offers a Premium subscription plan that grants access to advanced AI evaluation, exclusive stats, and community features. Subscriptions are billed through your App Store or Play Store account. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildTermSection(
              title: '4. Acceptable Conduct',
              content: 'You agree to use QARI 24/7 in a respectful manner. You must not upload harmful, profane, or inappropriate community content, attempt to disrupt the AI engine, copy source code, or violate local or international laws while using our service.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildTermSection(
              title: '5. Limitation of Liability',
              content: 'QARI 24/7 and its affiliates are provided on an "as is" and "as available" basis. We do not guarantee that the application will be uninterrupted, secure, or error-free. We shall not be liable for any indirect, incidental, or consequential damages resulting from your use of the application.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildTermSection(
              title: '6. Contact Us',
              content: 'If you have any questions about these Terms of Service, please contact us at: Thehub923community@gmail.com.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String title,
    required String content,
    required Color bodyColor,
    required Color titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated: June 14, 2026',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _buildPrivacySection(
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us when you create an account, such as your username, email address, profile picture, and support requests. We also process audio recordings of your recitation for the sole purpose of real-time speech-to-text evaluation. Audio recordings are handled dynamically and are not stored permanently on our servers unless specified for learning history.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildPrivacySection(
              title: '2. How We Use Your Information',
              content: 'We use the information we collect to provide, maintain, and improve the QARI 24/7 services. This includes analyzing your recitation to suggest corrections, personalizing your study streak metrics, facilitating community communications, processing subscriptions, and responding to feedback/support emails.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildPrivacySection(
              title: '3. Data Storage & Security',
              content: 'We implement industry-standard security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. We retain your account and learning data for as long as your account is active, or as needed to provide services. You can delete your account and all associated data at any time via the "Delete Account" option in the profile settings.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildPrivacySection(
              title: '4. Third-Party Services',
              content: 'We may use third-party analytics and payment processors (e.g., Stripe, Google Play Services, Apple App Store) to process payments and measure app performance. These services adhere to their own privacy guidelines.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildPrivacySection(
              title: '5. Changes to This Policy',
              content: 'We may update our Privacy Policy from time to time. Any changes will be posted on this screen, with the "Last updated" date revised accordingly. Your continued use of the app after updates indicates acceptance of the changes.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            _buildPrivacySection(
              title: '6. Contact Support',
              content: 'If you have questions or concerns regarding this Privacy Policy or your data, contact us at: Thehub923community@gmail.com.',
              bodyColor: bodyColor,
              titleColor: textTheme,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required String content,
    required Color bodyColor,
    required Color titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
