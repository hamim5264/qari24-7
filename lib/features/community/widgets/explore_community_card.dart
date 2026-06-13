import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../subscription/screens/select_plan_screen.dart';

class ExploreCommunityCard extends StatelessWidget {
  final CommunityModel community;
  final CommunityController controller;

  const ExploreCommunityCard({
    super.key,
    required this.community,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: community.localImage != null
                ? Image.file(
                    community.localImage!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Obx(() => Image.network(
                    community.photoUrl.value,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.group, color: AppColors.primary),
                    ),
                  )),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  community.name.value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                )),
                const SizedBox(height: 4),
                Text(
                  '${_formatMembers(community.memberCount.value)} members',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            final status = community.status.value;

            if (status == 'pending') {
              return _buildPendingButton(context);
            } else if (status == 'joined') {
              return _buildJoinedButton(context);
            } else {
              return _buildJoinButton(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final settingsController = Get.find<SettingsController>();
        if (!settingsController.isPremium.value) {
          Get.to(() => const SelectPlanScreen());
          Get.snackbar(
            'Premium Required',
            'You must be a premium user to join a community.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade900,
            colorText: Colors.white,
          );
          return;
        }
        controller.joinCommunity(community);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF033F26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'join'.tr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
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
              children: [
                Text(
                  'cancel_request'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to cancel your join request to ${community.name.value}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.cancelJoinRequest(community);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'cancel_request'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'pending'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Joined',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _formatMembers(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
