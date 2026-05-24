import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/progress_controller.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgressController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final podium = controller.podiumUsers;

      final user1 = podium.firstWhere((u) => u.rank == 1);
      final user2 = podium.firstWhere((u) => u.rank == 2);
      final user3 = podium.firstWhere((u) => u.rank == 3);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C2C20) : const Color(0xFFE6F0EC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildPodiumColumn(
                user: user2,
                ringColor: const Color(0xFFB4B4B4),
                isDark: isDark,
                avatarSize: 52,
                columnHeight: 120,
              ),
            ),

            Expanded(
              child: _buildPodiumColumn(
                user: user1,
                ringColor: const Color(0xFFEFBF04),
                isDark: isDark,
                avatarSize: 68,
                columnHeight: 150,
                hasCrown: true,
              ),
            ),

            Expanded(
              child: _buildPodiumColumn(
                user: user3,
                ringColor: const Color(0xFFCD7F32),
                isDark: isDark,
                avatarSize: 48,
                columnHeight: 110,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPodiumColumn({
    required LeaderboardUser user,
    required Color ringColor,
    required bool isDark,
    required double avatarSize,
    required double columnHeight,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasCrown) ...[
          const Text('👑', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
        ] else ...[
          const SizedBox(height: 32),
        ],

        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize + 8,
              height: avatarSize + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3.5),
              ),
            ),
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ringColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.rank.toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: user.rank == 3 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          user.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          '${user.verses} verses',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
