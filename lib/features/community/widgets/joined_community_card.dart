import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../screens/your_community_screen.dart';
import '../../../core/constants/app_colors.dart';

class JoinedCommunityCard extends StatelessWidget {
  final CommunityModel community;
  final CommunityController controller;

  const JoinedCommunityCard({
    super.key,
    required this.community,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isOwner = community.isOwner.value;

    final boxDecoration = isOwner
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF033F26), Color(0xFF065C38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF033F26).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          );

    final titleColor = isOwner
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isOwner
        ? Colors.white70
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final rankColor = isOwner ? const Color(0xFFFFD60A) : AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => YourCommunityScreen(
              community: community,
              controller: controller,
            ),
          );
        },
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(20),
          decoration: boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: community.localImage != null
                        ? Image.file(
                            community.localImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Obx(() => Image.network(
                            community.photoUrl.value,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 48,
                                  height: 48,
                                  color: isOwner
                                      ? Colors.white24
                                      : AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                  child: Icon(
                                    Icons.group,
                                    color: isOwner
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                          )),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          community.name.value,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 14,
                              color: rankColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '# Rank ${community.rank}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: rankColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Obx(() => Text(
                community.description.value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: subtitleColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 14,
                        color: isOwner ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${community.memberCount.value} Members',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOwner ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOwner
                          ? Colors.white24
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOwner ? 'Owner' : 'Joined',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOwner ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
