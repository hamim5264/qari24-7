import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';
import '../widgets/stats_cards_row.dart';
import '../widgets/overall_progress_card.dart';
import '../widgets/activity_chart_card.dart';
import '../widgets/achievements_section.dart';
import '../widgets/monthly_goal_card.dart';
import '../../auth/repositories/auth_repository.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgressController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'progress_title'.tr,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Obx(() {
              final user = Get.find<AuthRepository>().currentUser.value;
              final photoUrl = user?.photo;
              final name = user?.username ?? 'User';
              return CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                backgroundImage: NetworkImage(
                  (photoUrl != null && photoUrl.isNotEmpty)
                      ? photoUrl
                      : 'https://ui-avatars.com/api/?name=$name&background=06402B&color=fff&format=png',
                ),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161616)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFilter.value,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: 18,
                      ),
                      elevation: 16,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      dropdownColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.setFilter(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('filter_daily'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('filter_weekly'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('filter_monthly'.tr),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const StatsCardsRow(),

            const SizedBox(height: 20),

            const OverallProgressCard(),

            const SizedBox(height: 20),

            const ActivityChartCard(),

            const SizedBox(height: 24),

            const AchievementsSection(),

            const SizedBox(height: 24),

            const MonthlyGoalCard(),

            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
