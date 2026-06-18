import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'add_feature_screen.dart';
import 'info_screens.dart';

import '../../subscription/controllers/subscription_controller.dart';
import '../../subscription/screens/go_premium_screen.dart';
import '../../subscription/screens/manage_subscription_screen.dart';
import '../../auth/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Eagerly refresh subscription details in the background when entering ProfileScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<SubscriptionController>()) {
        Get.find<SubscriptionController>().fetchSubscriptionDetails();
      }
    });

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileSheet(context, controller, isDark),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Obx(() {
              final authRepo = Get.find<AuthRepository>();
              final user = authRepo.currentUser.value;
              final photoUrl = user?.photo;
              return CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImageProvider(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 16),
            Obx(
              () => Text(
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
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                controller.email.value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
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
              onTap: () async {
                Get.dialog(
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  barrierDismissible: false,
                );
                final subController = Get.isRegistered<SubscriptionController>()
                    ? Get.find<SubscriptionController>()
                    : Get.put(SubscriptionController());
                final success = await subController.restoreSubscription();
                Get.back(); // Dismiss loading
                if (success) {
                  Get.snackbar(
                    'Restore',
                    'Purchases restored successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Restore Failed',
                    'No active subscriptions found to restore.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade900,
                    colorText: Colors.white,
                  );
                }
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
                      title: Text('logout_dialog_title'.tr),
                      content: Text('logout_dialog_desc'.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text('cancel'.tr),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.logout();
                          },
                          child: Text(
                            'logout_dialog_btn'.tr,
                            style: const TextStyle(color: Colors.red),
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
                    onTap: () => Get.to(() => const AboutAppScreen()),
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
                    onTap: () => Get.to(() => const HelpCenterScreen()),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.star_outline_rounded,
                    labelKey: 'rate_app',
                    onTap: () {
                      int selectedStars = 5;
                      final reviewController = TextEditingController();
                      Get.dialog(
                        StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text('rate_dialog_title'.tr),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      final starNum = index + 1;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedStars = starNum;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                          child: Icon(
                                            starNum <= selectedStars
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: const Color(0xFFEFBF04),
                                            size: 36,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: reviewController,
                                    decoration: InputDecoration(
                                      labelText: 'rate_dialog_review_label'.tr,
                                      hintText: 'rate_dialog_review_hint'.tr,
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: Text('cancel'.tr),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back();
                                    await controller.submitAppRating(
                                      rating: selectedStars,
                                      review: reviewController.text.trim(),
                                    );
                                  },
                                  child: Text(
                                    'rate_dialog_submit'.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.article_outlined,
                    labelKey: 'terms_service',
                    onTap: () => Get.to(() => const TermsOfServiceScreen()),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.privacy_tip_outlined,
                    labelKey: 'privacy_policy',
                    onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  buildOptionRow(
                    icon: Icons.delete_outline_rounded,
                    labelKey: 'delete_account',
                    onTap: () {
                      final passwordController = TextEditingController();
                      Get.dialog(
                        AlertDialog(
                          title: Text(
                            'delete_dialog_title'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'delete_dialog_warning'.tr,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'delete_dialog_confirm_password'.tr,
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: Text('cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () async {
                                final pw = passwordController.text.trim();
                                if (pw.isEmpty) {
                                  Get.snackbar(
                                    'delete_dialog_validation'.tr,
                                    'delete_dialog_pw_required'.tr,
                                  );
                                  return;
                                }
                                Get.back();
                                await controller.deleteUserAccount(
                                  password: pw,
                                );
                              },
                              child: Text(
                                'delete_dialog_delete_forever'.tr,
                                style: const TextStyle(color: Colors.red),
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

  void _showEditProfileSheet(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    final usernameController = TextEditingController(
      text: controller.userName.value,
    );
    controller.newProfileImage.value = null;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        final authRepo = Get.find<AuthRepository>();
                        final user = authRepo.currentUser.value;
                        final photoUrl = user?.photo;
                        final localImage = controller.newProfileImage.value;

                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: localImage != null
                                ? Image.file(localImage, fit: BoxFit.cover)
                                : (photoUrl != null && photoUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: photoUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.person,
                                                size: 50,
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                          ),
                                        )),
                          ),
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showPhotoSourceSheet(
                            context,
                            controller,
                            isDark,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade700,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final isUpdating = controller.isUpdatingProfile.value;
                  return isUpdating
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final name = usernameController.text.trim();
                            if (name.isEmpty) {
                              Get.snackbar(
                                'Validation',
                                'Username cannot be empty',
                              );
                              return;
                            }
                            final success = await controller.updateProfile(
                              username: name,
                              photo: controller.newProfileImage.value,
                            );
                            if (success) {
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Profile updated successfully!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF06402B),
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: const Text('Save Changes'),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showPhotoSourceSheet(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: AppColors.primary,
                ),
                title: const Text('Take Photo'),
                onTap: () => controller.pickNewProfileImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () =>
                    controller.pickNewProfileImage(ImageSource.gallery),
              ),
              Obx(() {
                if (controller.newProfileImage.value != null) {
                  return ListTile(
                    leading: const Icon(Icons.delete, color: AppColors.error),
                    title: const Text('Remove Selected Photo'),
                    onTap: () {
                      controller.removeNewProfileImage();
                      Get.back();
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
