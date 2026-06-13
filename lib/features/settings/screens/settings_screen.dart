import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/setting_group.dart';
import '../widgets/setting_tile.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'theme_screen.dart';
import 'add_feature_screen.dart';

import '../../recitation/controllers/recitation_controller.dart';
import '../../recitation/widgets/mushaf_layout_bottom_sheet.dart';
import '../../recitation/widgets/eye_guideline_sheet.dart';
import '../../recitation/widgets/audio_settings_bottom_sheet.dart';
import '../../recitation/screens/manage_downloads_screen.dart';

import '../../subscription/controllers/subscription_controller.dart';
import '../../subscription/screens/go_premium_screen.dart';
import '../../subscription/screens/manage_subscription_screen.dart';
import '../../subscription/screens/payment_history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'settings_title'.tr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => ProfileHeaderCard(
                name: controller.userName.value,
                email: controller.email.value,
                photoUrl: controller.photoUrl.value,
                isPremium: controller.isPremium.value,
                onManageTap: () => Get.to(() => const ProfileScreen()),
              ),
            ),
            const SizedBox(height: 24),

            SettingGroup(
              title: 'section_display'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.space_dashboard_outlined,
                  title: 'option_layout_options'.tr,
                  onTap: () {
                    if (!Get.isRegistered<RecitationController>()) {
                      Get.put(RecitationController());
                    }
                    Get.bottomSheet(
                      const MushafLayoutBottomSheet(),
                      isScrollControlled: true,
                    );
                  },
                ),
                SettingTile(
                  leadingIcon: Icons.visibility_outlined,
                  title: 'option_show_hide'.tr,
                  onTap: () {
                    if (!Get.isRegistered<RecitationController>()) {
                      Get.put(RecitationController());
                    }
                    Get.bottomSheet(
                      const EyeGuidelineSheet(),
                      isScrollControlled: true,
                    );
                  },
                ),
                SettingTile(
                  leadingIcon: Icons.draw_outlined,
                  title: 'option_highlights'.tr,
                  onTap: () {
                    _showHighlightColorSelector(context, controller);
                  },
                ),
              ],
            ),

            SettingGroup(
              title: 'section_appearance'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.language_outlined,
                  title: 'language_title'.tr,
                  onTap: () => Get.to(() => const LanguageScreen()),
                ),
                SettingTile(
                  leadingIcon: Icons.dark_mode_outlined,
                  title: 'theme_title'.tr,
                  onTap: () => Get.to(() => const ThemeScreen()),
                ),
              ],
            ),

            SettingGroup(
              title: 'section_sound_tactile'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.volume_up_outlined,
                  title: 'option_sound_settings'.tr,
                  onTap: () {
                    if (!Get.isRegistered<RecitationController>()) {
                      Get.put(RecitationController());
                    }
                    Get.bottomSheet(
                      const AudioSettingsBottomSheet(),
                      isScrollControlled: true,
                    );
                  },
                ),
                Obx(
                  () => SettingTile(
                    leadingIcon: Icons.vibration_outlined,
                    title: 'option_tactile_feedback'.tr,
                    trailing: Switch(
                      value: controller.tactileFeedbackEnabled.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        controller.tactileFeedbackEnabled.value = val;
                        Get.snackbar(
                          'Tactile Feedback',
                          val ? 'Vibrations enabled' : 'Vibrations disabled',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SettingGroup(
              title: 'section_downloads'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.download_for_offline_outlined,
                  title: 'manage_downloads'.tr,
                  onTap: () {
                    if (!Get.isRegistered<RecitationController>()) {
                      Get.put(RecitationController());
                    }
                    Get.to(() => const ManageDownloadsScreen());
                  },
                ),
              ],
            ),

            SettingGroup(
              title: 'section_subscription'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.card_membership_outlined,
                  title: 'subscription_status_title'.tr,
                  onTap: () {
                    Get.put(SubscriptionController());
                    Get.to(
                      () => controller.isPremium.value
                          ? const ManageSubscriptionScreen()
                          : const GoPremiumScreen(),
                    );
                  },
                ),
                SettingTile(
                  leadingIcon: Icons.auto_graph_outlined,
                  title: 'option_manage_plan'.tr,
                  onTap: () {
                    Get.put(SubscriptionController());
                    Get.to(
                      () => controller.isPremium.value
                          ? const ManageSubscriptionScreen()
                          : const GoPremiumScreen(),
                    );
                  },
                ),
                SettingTile(
                  leadingIcon: Icons.history_rounded,
                  title: 'Payment History',
                  onTap: () {
                    Get.put(SubscriptionController());
                    Get.to(() => const PaymentHistoryScreen());
                  },
                ),
              ],
            ),

            SettingGroup(
              title: 'section_more'.tr,
              tiles: [
                SettingTile(
                  leadingIcon: Icons.add_circle_outline_rounded,
                  title: 'option_add_feature'.tr,
                  onTap: () => Get.to(() => const AddFeatureScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHighlightColorSelector(BuildContext context, SettingsController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textThemeColor = isDark ? Colors.white : Colors.black87;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;

    final colorsList = [
      {'name': 'Green', 'color': const Color(0xFF16A34A)},
      {'name': 'Blue', 'color': const Color(0xFF2563EB)},
      {'name': 'Orange', 'color': const Color(0xFFD97706)},
      {'name': 'Purple', 'color': const Color(0xFF7C3AED)},
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Highlight Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textThemeColor,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...colorsList.map((item) {
              final name = item['name'] as String;
              final color = item['color'] as Color;
              return Obx(() {
                final isSelected = controller.highlightColorName.value == name;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withValues(alpha: 0.15) 
                        : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: textThemeColor,
                      ),
                    ),
                    trailing: isSelected 
                        ? Icon(Icons.check_circle_rounded, color: color) 
                        : null,
                    onTap: () {
                      controller.setHighlightColor(name);
                      Get.back();
                      Get.snackbar(
                        'Highlight Color',
                        '$name color selected for recitation highlighting.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                      );
                    },
                  ),
                );
              });
            }),
          ],
        ),
      ),
    );
  }
}
