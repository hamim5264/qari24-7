import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../progress/controllers/progress_controller.dart';
import '../../progress/screens/leaderboard_screen.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../subscription/screens/select_plan_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/edit_community_bottom_sheet.dart';

class YourCommunityScreen extends StatelessWidget {
  final CommunityModel community;
  final CommunityController controller;

  const YourCommunityScreen({
    super.key,
    required this.community,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = community.isOwner.value;

    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textThemeColor = isDark ? Colors.white : Colors.black87;
    final subtitleThemeColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final listCardBgColor = isDark ? const Color(0xFF161616) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'your_community'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textThemeColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF023F26), Color(0xFF054F30)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF023F26,
                                ).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white38,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Obx(() => community.localImage != null
                                          ? Image.file(
                                              community.localImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              community.photoUrl.value,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Icon(
                                                    Icons.group,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                            )),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: isOwner ? 48.0 : 0.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Obx(() => Text(
                                                  community.name.value,
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFD60A,
                                                  ).withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '# Rank ${community.rank}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFFFD60A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                           Obx(() => Text(
                                             community.description.value,
                                             style: const TextStyle(
                                               fontFamily: 'Inter',
                                               fontSize: 12.5,
                                               color: Colors.white70,
                                               height: 1.4,
                                             ),
                                             maxLines: 2,
                                             overflow: TextOverflow.ellipsis,
                                           )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        final progressController = Get.isRegistered<ProgressController>()
                                            ? Get.find<ProgressController>()
                                            : Get.put(ProgressController());
                                        progressController.setLeaderboardTab('community');
                                        progressController.fetchLeaderboardData();
                                        Get.to(() => const LeaderboardScreen());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD60A),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.bar_chart,
                                              size: 16,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'view_leaderboard'.tr,
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        SharePlus.instance.share(
                                          ShareParams(
                                            text: "Join our Quran community '${community.name.value}' on Qari 24/7!\n\nDownload the app and start learning together: https://qari247.app/invite?community=${community.id}",
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: Colors.white30,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.share_outlined,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'invite'.tr,
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isOwner)
                          Positioned(
                            top: 24,
                            right: 24,
                            child: GestureDetector(
                                onTap: () {
                                  Get.bottomSheet(
                                    EditCommunityBottomSheet(
                                      community: community,
                                      controller: controller,
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'members'.tr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textThemeColor,
                          ),
                        ),
                        Text(
                          '${'available_members'.tr} : ${community.memberCount.value}/50',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subtitleThemeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: community.members.length,
                      itemBuilder: (context, index) {
                        final member = community.members[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: listCardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                backgroundImage: member.avatarUrl.isNotEmpty
                                    ? NetworkImage(member.avatarUrl)
                                    : null,
                                child: member.avatarUrl.isEmpty
                                    ? Text(
                                        member.name.substring(0, 1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textThemeColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      member.role,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: subtitleThemeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: subtitleThemeColor,
                                ),
                                onPressed: () {
                                  Get.snackbar(
                                    member.name,
                                    'Profile and member options coming soon!',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.primary,
                                    colorText: Colors.white,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: isOwner
                  ? _buildActionButton(
                      context: context,
                      label: 'delete_community'.tr,
                      icon: Icons.delete_outline,
                      isDelete: true,
                      onTap: () {
                        final settingsController = Get.find<SettingsController>();
                        if (!settingsController.isPremium.value) {
                          Get.to(() => const SelectPlanScreen());
                          Get.snackbar(
                            'Premium Required',
                            'You must be a premium user to delete a community.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange.shade900,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        _showConfirmationDialog(
                          context: context,
                          title: 'delete_community'.tr,
                          message: 'confirm_delete'.tr,
                          onConfirm: () {
                            controller.deleteCommunity(community);
                            Get.back();
                            Get.back();
                          },
                        );
                      },
                    )
                  : _buildActionButton(
                      context: context,
                      label: 'leave_community'.tr,
                      icon: Icons.exit_to_app,
                      isDelete: false,
                      onTap: () {
                        final settingsController = Get.find<SettingsController>();
                        if (!settingsController.isPremium.value) {
                          Get.to(() => const SelectPlanScreen());
                          Get.snackbar(
                            'Premium Required',
                            'You must be a premium user to leave a community.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange.shade900,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        _showConfirmationDialog(
                          context: context,
                          title: 'leave_community'.tr,
                          message: 'confirm_leave'.tr,
                          onConfirm: () {
                            controller.leaveCommunity(community);
                            Get.back();
                            Get.back();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isDelete,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.error, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.error, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? Colors.red.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.02),
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
