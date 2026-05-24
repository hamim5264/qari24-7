import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/weekly_challenge_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressController>();
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
          'leaderboard'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              size: 24,
            ),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() {
        final rankings = controller.otherRankings;
        final achievements = controller.lockedAchievements;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'global',
                      'global'.tr,
                      controller,
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      'community',
                      'community_tab'.tr,
                      controller,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const LeaderboardPodium(),

            const SizedBox(height: 24),

            Text(
              'other_rankings'.tr.toUpperCase(),
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
            const SizedBox(height: 12),

            Column(
              children: rankings
                  .map((row) => _buildRankingRow(row, isDark))
                  .toList(),
            ),

            const SizedBox(height: 24),

            const WeeklyChallengeCard(),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements'.tr.toUpperCase(),
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
                Text(
                  '1/3',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 110,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  return _buildAchievementSlide(achievements[index], isDark);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildTabButton(
    String tabValue,
    String label,
    ProgressController controller,
    bool isDark,
  ) {
    final isSelected = controller.leaderboardTab.value == tabValue;

    return GestureDetector(
      onTap: () => controller.setLeaderboardTab(tabValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingRow(LeaderboardRow row, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: row.isHighlighted
            ? (isDark ? const Color(0xFF0C2C20) : const Color(0xFFE6F0EC))
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: row.isHighlighted
              ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.2))
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          width: row.isHighlighted ? 1.5 : 1,
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
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: row.isHighlighted
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                row.rank.toString(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          CircleAvatar(
            radius: 18,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            backgroundImage: NetworkImage(row.avatarUrl),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.sub,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Points score
          Text(
            row.score.toString(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSlide(LockedAchievement item, bool isDark) {
    Color getBorderColor() {
      if (item.isUnlocked) {
        return const Color(0xFFEFBF04).withValues(alpha: 0.4);
      }
      return isDark ? Colors.grey.shade900 : Colors.grey.shade200;
    }

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getBorderColor(),
          width: item.isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                item.isUnlocked
                    ? Icons.emoji_events_rounded
                    : Icons.lock_outline_rounded,
                color: item.isUnlocked
                    ? const Color(0xFFEFBF04)
                    : AppColors.grey,
                size: 18,
              ),
              if (item.isUnlocked)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            item.desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),

          Text(
            item.progressText,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: item.isUnlocked ? AppColors.success : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
