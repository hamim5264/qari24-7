import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';

class MonthlyGoalCard extends StatelessWidget {
  const MonthlyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final percent = controller.monthlyGoalPercent;
    final completed = controller.monthlyGoalCompleted;
    final total = controller.monthlyGoalTotal;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C2C20) : const Color(0xFFE6F0EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'monthly_goal'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete 10 Surahs',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$completed / $total ${'Completed'.tr}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.primary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 7,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
