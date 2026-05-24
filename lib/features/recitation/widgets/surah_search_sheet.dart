import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/recitation_controller.dart';

class SurahSearchSheet extends StatelessWidget {
  const SurahSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    final sheetBg = isDark ? const Color(0xFF121212) : Colors.white;
    final cardBgColor = isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textTitle = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade300;

    return Container(
      height: context.height * 0.9,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Search',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textTitle,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1E)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => controller.filterSurahs(val),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'eg. Al-Fatihah, 1:4, pg62,...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.searchQuery.value.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchController.clear();
                                controller.filterSurahs('');
                              },
                            ),
                          Icon(
                            Icons.history,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => GestureDetector(
                  onTap: () => controller.startVoiceSearch(searchController),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: controller.isVoiceSearching.value
                          ? Colors.red.shade800
                          : const Color(0xFF0F3A27),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isVoiceSearching.value
                          ? Icons.stop_rounded
                          : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Recently Read',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textTitle,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 64,
            child: Obx(() {
              if (controller.recentlyReadSurahs.isEmpty) {
                return Center(
                  child: Text(
                    'No recently read surahs.',
                    style: TextStyle(color: textGrey, fontSize: 12),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.recentlyReadSurahs.length,
                itemBuilder: (context, index) {
                  final item = controller.recentlyReadSurahs[index];
                  final surahNum = item['number'] as int;
                  return GestureDetector(
                    onTap: () {
                      controller.loadSurah(surahNum);
                      Get.back();
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$surahNum:1',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['englishName'],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: textTitle,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PG ${item['page']}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 14, color: textGrey),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 24),

          Text(
            'Chapter and Juz Lists',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textTitle,
            ),
          ),
          const SizedBox(height: 12),

          Obx(() {
            final activeTab = controller.selectedSearchTab.value;
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        controller.selectedSearchTab.value = 'Chapters',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: activeTab == 'Chapters'
                            ? (isDark
                                  ? const Color(0xFF1C1C1E)
                                  : AppColors.primary)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: activeTab == 'Chapters'
                              ? (isDark ? textTitle : AppColors.primary)
                              : borderColor,
                          width: activeTab == 'Chapters' ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        'Chapters',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: activeTab == 'Chapters'
                              ? (isDark ? textTitle : Colors.white)
                              : textGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedSearchTab.value = 'Parts',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: activeTab == 'Parts'
                            ? (isDark
                                  ? const Color(0xFF1C1C1E)
                                  : AppColors.primary)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: activeTab == 'Parts'
                              ? (isDark ? textTitle : AppColors.primary)
                              : borderColor,
                          width: activeTab == 'Parts' ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        'Parts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: activeTab == 'Parts'
                              ? (isDark ? textTitle : Colors.white)
                              : textGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Short by ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: textGrey,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Ascending',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textTitle,
                        ),
                      ),
                      Icon(Icons.unfold_more, size: 12, color: textGrey),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Shown Progress ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: textGrey,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Memorization',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textTitle,
                        ),
                      ),
                      Icon(Icons.unfold_more, size: 12, color: textGrey),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              final searchList = controller.filteredSurahsList;

              if (searchList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: textGrey),
                      const SizedBox(height: 12),
                      Text(
                        'No matches found.',
                        style: TextStyle(color: textGrey),
                      ),
                    ],
                  ),
                );
              }

              final Map<int, List<Map<String, dynamic>>> juzGrouped = {};
              for (var s in searchList) {
                final juzNum = s['juz'] as int? ?? 1;
                juzGrouped.putIfAbsent(juzNum, () => []).add(s);
              }

              final sortedJuzs = juzGrouped.keys.toList()..sort();

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: sortedJuzs.length,
                itemBuilder: (context, juzIdx) {
                  final juzNum = sortedJuzs[juzIdx];
                  final list = juzGrouped[juzNum]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Juz $juzNum',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textTitle,
                          ),
                        ),
                      ),

                      Column(
                        children: list.map((surah) {
                          final sNum = surah['number'] as int;
                          final isSelected =
                              controller.currentSurahNumber.value == sNum;

                          return GestureDetector(
                            onTap: () {
                              controller.loadSurah(sNum);
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: borderColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '$sNum',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : textGrey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          surah['englishName'],
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : textTitle,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "${surah['ayahs']} Verses • ${surah['type']}",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11,
                                            color: textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    surah['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
