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
                    if (!Get.isRegistered<RecitationController>()) {
                      Get.put(RecitationController());
                    }
                    Get.bottomSheet(
                      const AudioSettingsBottomSheet(),
                      isScrollControlled: true,
                    );
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
                    Get.snackbar(
                      'Sound Settings',
                      'Adjust audio output levels loaded.',
                      snackPosition: SnackPosition.BOTTOM,
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
}
