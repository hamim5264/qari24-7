import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../widgets/explore_community_card.dart';
import '../screens/your_community_screen.dart';
import '../../../core/constants/app_colors.dart';

class SeeAllCommunitiesScreen extends StatefulWidget {
  final bool isJoinedOnly;
  final CommunityController controller;

  const SeeAllCommunitiesScreen({
    super.key,
    required this.isJoinedOnly,
    required this.controller,
  });

  @override
  State<SeeAllCommunitiesScreen> createState() => _SeeAllCommunitiesScreenState();
}

class _SeeAllCommunitiesScreenState extends State<SeeAllCommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  late final RxBool _showJoined;

  @override
  void initState() {
    super.initState();
    _showJoined = widget.isJoinedOnly.obs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final headerTextColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          _showJoined.value ? 'joined_communities'.tr : 'explore_communities'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: headerTextColor,
          ),
        )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _searchQuery.value = val,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: headerTextColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      size: 20,
                    ),
                    suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Tab Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      label: 'Joined',
                      isSelected: _showJoined.value,
                      onTap: () {
                        _showJoined.value = true;
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterTab(
                      label: 'Explore',
                      isSelected: !_showJoined.value,
                      onTap: () {
                        _showJoined.value = false;
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              )),
            ),

            const SizedBox(height: 8),

            // Communities List
            Expanded(
              child: Obx(() {
                final showJoinedList = _showJoined.value;

                // Get the raw list based on type
                final List<CommunityModel> rawList = showJoinedList
                    ? widget.controller.joinedCommunities
                    : widget.controller.exploreCommunities
                        .where((item) => !widget.controller.joinedCommunities.any((j) => j.id == item.id))
                        .toList();

                // Apply search filter
                final filteredList = rawList.where((c) {
                  final query = _searchQuery.value.toLowerCase();
                  return c.name.value.toLowerCase().contains(query) ||
                      c.description.value.toLowerCase().contains(query);
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 48,
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.value.isNotEmpty
                                ? 'No matching communities found.'
                                : showJoinedList
                                    ? 'You have not joined any communities yet.'
                                    : 'No new communities to explore right now.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: subtitleColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (showJoinedList) {
                  // Display Joined Communities list
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final community = filteredList[index];
                      final isOwner = community.isOwner.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: community.localImage != null
                                  ? Image.file(
                                      community.localImage!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Obx(() => Image.network(
                                      community.photoUrl.value,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 50,
                                        height: 50,
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.group, color: AppColors.primary),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: headerTextColor,
                                    ),
                                  )),
                                  const SizedBox(height: 4),
                                  // Replaced Row with Wrap to prevent horizontal overflow exceptions
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.group,
                                            size: 13,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${community.memberCount.value} members',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            size: 13,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rank ${community.rank}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(() => YourCommunityScreen(
                                  community: community,
                                  controller: widget.controller,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isOwner ? AppColors.secondary : AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isOwner ? 'Owner' : 'View',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // Display Explore Communities list
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final community = filteredList[index];
                      return ExploreCommunityCard(
                        community: community,
                        controller: widget.controller,
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}
