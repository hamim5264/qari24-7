import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../community/screens/community_screen.dart';
import '../../community/controllers/community_controller.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final communityController = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());

    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 20, color: Color(0xFFFFD60A)),
                const SizedBox(width: 8),
                Text(
                  'community'.tr.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: labelColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'share_progress_community'.tr.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                color: titleColor,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => const CommunityScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF033F26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'explore_community'.tr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Obx(() {
                  final List<String> memberPhotos = [];
                  final seenUsernames = <String>{};

                  for (var c in communityController.joinedCommunities) {
                    for (var m in c.members) {
                      final name = m.name.replaceAll(' (You)', '');
                      if (!seenUsernames.contains(name) && m.avatarUrl.isNotEmpty) {
                        seenUsernames.add(name);
                        memberPhotos.add(m.avatarUrl);
                      }
                    }
                  }
                  for (var c in communityController.exploreCommunities) {
                    for (var m in c.members) {
                      final name = m.name.replaceAll(' (You)', '');
                      if (!seenUsernames.contains(name) && m.avatarUrl.isNotEmpty) {
                        seenUsernames.add(name);
                        memberPhotos.add(m.avatarUrl);
                      }
                    }
                  }

                  // Fallbacks
                  final fallbackNames = ['Hamim Leon', 'Qari Premium', 'Rafa'];
                  while (memberPhotos.length < 3) {
                    final name = fallbackNames[memberPhotos.length % fallbackNames.length];
                    memberPhotos.add('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&format=png');
                  }

                  return SizedBox(
                    width: 72,
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 11,
                              backgroundImage: NetworkImage(memberPhotos[0]),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 11,
                              backgroundImage: NetworkImage(memberPhotos[1]),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 30,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 11,
                              backgroundImage: NetworkImage(memberPhotos[2]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
