import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';
import '../screens/leaderboard_screen.dart';

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final heights = controller.activityBarHeights;
      final labels = controller.activityBarLabels;
      final summaryKey = controller.readSummaryKey;
      final labelKey = controller.chartLabelKey;

      String getCalendarText() {
        switch (controller.selectedFilter.value) {
          case 'weekly':
            return 'This Week';
          case 'monthly':
            return 'This Month';
          case 'daily':
          default:
            return 'Today';
        }
      }

      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labelKey.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getCalendarText(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 160,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(heights.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _buildVerticalBar(
                          heightPercent: heights[index],
                          label: labels[index],
                          isDark: isDark,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  summaryKey.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => Get.to(() => const LeaderboardScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'see_leaderboard'.tr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVerticalBar({
    required double heightPercent,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 14,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1C) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: (heightPercent * 120).clamp(0.0, double.infinity),
              width: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0F5A39)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
