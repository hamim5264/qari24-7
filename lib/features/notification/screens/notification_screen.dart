import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'notifications'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final notifications = controller.filteredNotifications;
        final unreadCount = controller.unreadCount;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    label: 'filter_all'.tr,
                    filterValue: 'all',
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    context: context,
                    label: 'filter_unread'.tr,
                    filterValue: 'unread',
                    controller: controller,
                    isDark: isDark,
                    badgeCount: unreadCount,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    context: context,
                    label: 'filter_read'.tr,
                    filterValue: 'read',
                    controller: controller,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildGroupedList(notifications, controller, isDark),
            ),

            if (controller.notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: TextButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'clear_all_notifications'.tr,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'confirm_delete'.tr,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'cancel'.tr,
                              style: const TextStyle(color: AppColors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.clearAll();
                              Get.back();
                            },
                            child: Text(
                              'continue_btn'.tr,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  label: Text(
                    'clear_all_notifications'.tr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String filterValue,
    required NotificationController controller,
    required bool isDark,
    int? badgeCount,
  }) {
    final isSelected = controller.currentFilter.value == filterValue;

    Color getBgColor() {
      if (isSelected) {
        return isDark ? AppColors.primary : AppColors.primary;
      }
      return Colors.transparent;
    }

    Color getBorderColor() {
      if (isSelected) {
        return AppColors.primary;
      }
      return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    }

    Color getTextColor() {
      if (isSelected) {
        return Colors.white;
      }
      return isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
    }

    return GestureDetector(
      onTap: () => controller.changeFilter(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: getBorderColor(), width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: getTextColor(),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(
    List<NotificationModel> notifications,
    NotificationController controller,
    bool isDark,
  ) {
    final todayList = notifications
        .where((n) => n.dayCategory == 'today')
        .toList();
    final yesterdayList = notifications
        .where((n) => n.dayCategory == 'yesterday')
        .toList();
    final olderList = notifications
        .where((n) => n.dayCategory != 'today' && n.dayCategory != 'yesterday')
        .toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      children: [
        if (todayList.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'today'.tr,
            showMarkAll: todayList.any((n) => !n.isRead.value),
            onMarkAllPressed: () => controller.markSectionAsRead('today'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ...todayList.map(
            (n) => _buildNotificationCard(n, controller, isDark),
          ),
          const SizedBox(height: 24),
        ],
        if (yesterdayList.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'yesterday'.tr,
            showMarkAll: yesterdayList.any((n) => !n.isRead.value),
            onMarkAllPressed: () => controller.markSectionAsRead('yesterday'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ...yesterdayList.map(
            (n) => _buildNotificationCard(n, controller, isDark),
          ),
          const SizedBox(height: 24),
        ],
        if (olderList.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'earlier'.tr,
            showMarkAll: olderList.any((n) => !n.isRead.value),
            onMarkAllPressed: () => controller.markSectionAsRead('older'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ...olderList.map(
            (n) => _buildNotificationCard(n, controller, isDark),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool showMarkAll,
    required VoidCallback onMarkAllPressed,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        if (showMarkAll)
          GestureDetector(
            onTap: onMarkAllPressed,
            child: Text(
              'mark_all_as_read'.tr,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    NotificationController controller,
    bool isDark,
  ) {
    IconData iconData;
    Color iconColor;
    Color iconBgColor;

    switch (notification.type) {
      case 'goal':
        iconData = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF34D399);
        iconBgColor = const Color(0xFF34D399).withValues(alpha: 0.1);
        break;
      case 'streak':
        iconData = Icons.local_fire_department_rounded;
        iconColor = const Color(0xFFFB923C);
        iconBgColor = const Color(0xFFFB923C).withValues(alpha: 0.1);
        break;
      case 'challenge':
        iconData = Icons.group_rounded;
        iconColor = const Color(0xFF60A5FA);
        iconBgColor = const Color(0xFF60A5FA).withValues(alpha: 0.1);
        break;
      case 'achievement':
        iconData = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFA78BFA);
        iconBgColor = const Color(0xFFA78BFA).withValues(alpha: 0.1);
        break;
      case 'library':
        iconData = Icons.menu_book_rounded;
        iconColor = const Color(0xFF2DD4BF);
        iconBgColor = const Color(0xFF2DD4BF).withValues(alpha: 0.1);
        break;
      case 'join_request':
        iconData = Icons.person_add_rounded;
        iconColor = const Color(0xFF10B981);
        iconBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        break;
      default:
        iconData = Icons.notifications_none_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Obx(() {
      final isRead = notification.isRead.value;

      return GestureDetector(
        onTap: () => controller.markAsRead(notification.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade900
                  : (isRead
                        ? Colors.grey.shade200
                        : AppColors.primary.withValues(alpha: 0.15)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.titleKey.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification.timestamp,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.descKey.tr,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              if (notification.type == 'join_request') ...[
                                const SizedBox(height: 12),
                                Obx(() {
                                  final action = notification.actionStatus.value;
                                  if (action == 'approved') {
                                    return const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Approved',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (action == 'declined') {
                                    return const Row(
                                      children: [
                                        Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Declined',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (!isRead) {
                                    final joinReqIdVal = notification.extraData?['join_request_id'];
                                    final int? joinRequestId = joinReqIdVal != null
                                        ? int.tryParse(joinReqIdVal.toString())
                                        : null;

                                    if (joinRequestId != null) {
                                      return Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => controller.respondToJoinRequest(
                                              notification.id,
                                              joinRequestId,
                                              'approve',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0D5C3A),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              minimumSize: Size.zero,
                                            ),
                                            child: const Text(
                                              'Approve',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          OutlinedButton(
                                            onPressed: () => controller.respondToJoinRequest(
                                              notification.id,
                                              joinRequestId,
                                              'decline',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              minimumSize: Size.zero,
                                            ),
                                            child: Text(
                                              'Decline',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ],
                          ),
                        ),
                        if (!isRead && notification.type != 'join_request') ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'no_new_notifications'.tr,
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
    );
  }
}
