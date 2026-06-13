import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../notification/screens/notification_screen.dart';
import '../../auth/repositories/auth_repository.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationController = Get.put(NotificationController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final authRepo = Get.find<AuthRepository>();
            final user = authRepo.currentUser.value;
            final photoUrl = user?.photo;
            final displayName = user?.username ?? 'user_fullname'.tr;

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'assalamu_alaikum'.tr,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          GestureDetector(
            onTap: () => Get.to(() => const NotificationScreen()),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                final hasUnread = notificationController.unreadCount > 0;

                return Stack(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
