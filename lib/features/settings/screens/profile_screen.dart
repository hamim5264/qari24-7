import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'add_feature_screen.dart';

import '../../subscription/controllers/subscription_controller.dart';
import '../../subscription/screens/go_premium_screen.dart';
import '../../subscription/screens/manage_subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SettingsController>();

    Widget buildOptionRow({
      required IconData icon,
      required String labelKey,
      required VoidCallback onTap,
      bool isWarning = false,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isWarning
                      ? AppColors.error
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    labelKey.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: isWarning ? FontWeight.bold : FontWeight.w600,
                      color: isWarning
                          ? AppColors.error
                          : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isWarning
                      ? AppColors.error.withValues(alpha: 0.5)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'profile_title'.tr,
          style: const TextStyle(
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                controller.userName.value.isNotEmpty
                    ? controller.userName.value[0]
                    : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.userName.value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.email.value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'joined_date'.tr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          controller.joinedDate.value,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'subscription_label'.tr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            if (controller.isPremium.value)
                              const Text('👑 ', style: TextStyle(fontSize: 12)),
                            Text(
                              controller.isPremium.value
                                  ? controller.subscriptionStatus.value
                                  : 'Free',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: controller.isPremium.value
                                    ? AppColors.secondary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              final isPremium = controller.isPremium.value;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [const Color(0xFFEFBF04), const Color(0xFF0F4E36)]
                          : [const Color(0xFF032B1E), AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.put(SubscriptionController());
                      Get.to(
                        () => isPremium
                            ? const ManageSubscriptionScreen()
                            : const GoPremiumScreen(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isPremium
                          ? 'Manage Premium Subscription'
                          : 'Purchase Qari 24/7 Premium',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Restore',
                  'Purchases restored successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              },
              child: Text(
                'restore_purchases'.tr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text(
                        'Are you sure you want to log out of QARI 24/7?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.snackbar(
                              'Logout',
                              'Logged out successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                            );
                          },
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'logout'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  buildOptionRow(
                    icon: Icons.info_outline_rounded,
                    labelKey: 'about_app',
                    onTap: () {
                      Get.snackbar(
                        'About QARI 24/7',
                        'QARI 24/7 is an AI-powered Quran companion.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.feedback_outlined,
                    labelKey: 'request_feature',
                    onTap: () => Get.to(() => const AddFeatureScreen()),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.help_outline_rounded,
                    labelKey: 'help_center',
                    onTap: () {
                      Get.snackbar(
                        'Help Center',
                        'Help and support guides are coming soon.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.star_outline_rounded,
                    labelKey: 'rate_app',
                    onTap: () {
                      Get.snackbar(
                        'Rate App',
                        'Thank you for your rating request!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.article_outlined,
                    labelKey: 'terms_service',
                    onTap: () {
                      Get.snackbar(
                        'Terms of Service',
                        'Terms of service documents loaded.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.privacy_tip_outlined,
                    labelKey: 'privacy_policy',
                    onTap: () {
                      Get.snackbar(
                        'Privacy Policy',
                        'Privacy policy documents loaded.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.delete_outline_rounded,
                    labelKey: 'delete_account',
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.red),
                          ),
                          content: const Text(
                            'Warning: This action is irreversible. All of your progress and settings will be permanently lost.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                Get.snackbar(
                                  'Account Deleted',
                                  'Your account deletion request has been submitted.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade900,
                                  colorText: Colors.white,
                                );
                              },
                              child: const Text(
                                'Delete Forever',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    isWarning: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
