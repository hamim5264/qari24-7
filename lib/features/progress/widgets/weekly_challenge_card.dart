import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';

class WeeklyChallengeCard extends StatelessWidget {
  const WeeklyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final completed = controller.challengeCompleted;
      final total = controller.challengeTotal;
      final percent = controller.challengePercent;
      final desc = controller.rxChallengeDesc.value;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'weekly_challenge'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFBF04).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFEFBF04).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFEFBF04),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+100 pts',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEFBF04),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              desc.tr,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              '$completed of $total ${'verses'.tr}',
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
      );
    });
  }
}
