import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/recitation_controller.dart';
import '../screens/manage_downloads_screen.dart';
import '../screens/saved_screen.dart';

class AudioSettingsBottomSheet extends StatelessWidget {
  const AudioSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF121212) : Colors.white;
    final cardBgColor = isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textTitle = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade300;

    return Container(
      height: context.height * 0.88,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C2B1D), Color(0xFF061810)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1E5D3E).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2B93C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unlock Premium Features',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get unlimited access to enhance your Quran reading experience',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'PLAYBACK SETTINGS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Select Range',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Obx(() {
                    final surahName =
                        controller.currentSurah.value?.englishName ??
                        'Al-Fatihah';
                    final surahNum = controller.currentSurahNumber.value;
                    final startVal = controller.startingVerse.value;
                    return _buildSelectRow(
                      context: context,
                      label: 'Starting Verse',
                      value: '$surahName - $surahNum:$startVal',
                      onTap: () =>
                          _showVerseRangePicker(context, true, controller),
                    );
                  }),
                  const SizedBox(height: 12),

                  Obx(() {
                    final surahName =
                        controller.currentSurah.value?.englishName ??
                        'Al-Fatihah';
                    final surahNum = controller.currentSurahNumber.value;
                    final endVal = controller.endingVerse.value;
                    return _buildSelectRow(
                      context: context,
                      label: 'Ending Verse',
                      value: '$surahName - $surahNum:$endVal',
                      onTap: () =>
                          _showVerseRangePicker(context, false, controller),
                    );
                  }),
                  const SizedBox(height: 16),

                  Text(
                    'Reciter',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Obx(() {
                    return _buildSelectRow(
                      context: context,
                      label: 'Reciter',
                      value: controller.selectedReciter.value,
                      onTap: () =>
                          _showReciterSelectionSheet(context, controller),
                    );
                  }),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.to(() => const ManageDownloadsScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'manage_downloads'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textTitle,
                            ),
                          ),
                          const Icon(
                            Icons.download_for_offline_outlined,
                            color: Color(0xFFE2B93C),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.to(() => const SavedScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'saved_sessions'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textTitle,
                            ),
                          ),
                          const Icon(
                            Icons.bookmark_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Play Speed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: speeds.map((speed) {
                        final isSelected =
                            controller.playbackSpeed.value == speed;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.changePlaybackSpeed(speed),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${speed}x',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : textTitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  Text(
                    'Play Each Verse',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final times = [1, 2, 3, 999];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: times.map((t) {
                        final label = t == 999 ? 'Loop' : '$t times';
                        final isSelected =
                            controller.loopEachVerseCount.value == t;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                controller.loopEachVerseCount.value = t,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : textTitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  Text(
                    'Play The Range',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final times = [1, 2, 3, 999];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: times.map((t) {
                        final label = t == 999 ? 'Loop' : '$t times';
                        final isSelected = controller.loopRangeCount.value == t;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.loopRangeCount.value = t,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : textTitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 24),

                  Text(
                    'Quick Select',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.8,
                    children: [
                      _buildQuickSelectButton(
                        'PG. 1',
                        () {
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = 7;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                      _buildQuickSelectButton(
                        'From PG. 1',
                        () {
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = 7;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                      _buildQuickSelectButton(
                        'Al-Fatihah',
                        () {
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = 7;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                      _buildQuickSelectButton(
                        'Juz 1',
                        () {
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = 7;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                      _buildQuickSelectButton(
                        'Hizb 1',
                        () {
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = 7;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                      _buildQuickSelectButton(
                        'All',
                        () {
                          final maxAyahs =
                              controller.currentSurah.value?.numberOfAyahs ?? 7;
                          controller.startingVerse.value = 1;
                          controller.endingVerse.value = maxAyahs;
                        },
                        cardBgColor,
                        textTitle,
                        borderColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Obx(() {
                      final isPlaying = controller.isPlayingAudio.value;
                      return ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.playAudioForRange();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPlaying ? 'Pause Audio' : 'Play Audio',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  Obx(() {
                    final isDownloading = controller.isDownloading.value;
                    final progress = controller.downloadProgress.value;
                    final progressText = controller.downloadProgressText.value;
                    final surah = controller.currentSurah.value;
                    final reciter = controller.selectedReciter.value;
                    final reciterId = controller.getReciterIdentifier(reciter);
                    final isDownloaded =
                        surah != null &&
                        controller.downloadedSurahKeys.contains(
                          '${surah.number}_$reciterId',
                        );

                    if (isDownloading) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    progressText,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textTitle,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                color: AppColors.primary,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: isDownloaded
                            ? null
                            : () => controller.downloadCurrentSurah(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDownloaded
                                ? Colors.grey.shade400
                                : AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDownloaded
                                  ? Icons.download_done
                                  : Icons.download_for_offline,
                              color: isDownloaded
                                  ? Colors.grey
                                  : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDownloaded
                                  ? 'Downloaded Offline'
                                  : 'Download Surah for Offline',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDownloaded
                                    ? Colors.grey
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textTitle = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textTitle,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(
    String label,
    VoidCallback onTap,
    Color bg,
    Color text,
    Color border,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        Get.snackbar(
          'Quick Select',
          'Selected $label successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ),
      ),
    );
  }

  void _showReciterSelectionSheet(
    BuildContext context,
    RecitationController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reciters = [
      'Abdul Rahman',
      'Maher Al-Muaiqly',
      'Mishary Al-Afasy',
      'Abu Bakr Al-Shatri',
      'Mahmoud Husary',
      'Ahmed Ajamy',
      'Female Reciter (Maria Ulfah)',
    ];

    Get.bottomSheet(
      Container(
        height: context.height * 0.72,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Reciter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...reciters.map((r) {
                      final isSelected = controller.selectedReciter.value == r;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          title: Text(
                            r,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? Colors.grey.shade300
                                        : Colors.black87),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            controller.selectedReciter.value = r;
                            Get.back();
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E2620),
                                  const Color(0xFF131A15),
                                ]
                              : [
                                  const Color(0xFFF0FDF4),
                                  const Color(0xFFDCFCE7),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E4033).withValues(alpha: 0.5)
                              : const Color(0xFFBBF7D0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_outlined,
                                color: isDark
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFF16A34A),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Female Reciters (Qari'at)",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF14532D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Public Quran CDNs currently do not host verse-by-verse studio audio for female reciters. To respect our users' requests, we are actively looking to partner with international female Quranic initiatives to host high-quality female recitations in a future release!",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              height: 1.5,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showVerseRangePicker(
    BuildContext context,
    bool isStart,
    RecitationController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxAyahs = controller.currentSurah.value?.numberOfAyahs ?? 7;

    Get.bottomSheet(
      Container(
        height: 320,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart ? 'Select Starting Verse' : 'Select Ending Verse',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: maxAyahs,
                itemBuilder: (context, index) {
                  final verseNum = index + 1;
                  return ListTile(
                    title: Text(
                      "Verse $verseNum",
                      style: const TextStyle(fontFamily: 'Inter'),
                    ),
                    onTap: () {
                      if (isStart) {
                        controller.startingVerse.value = verseNum;
                      } else {
                        controller.endingVerse.value = verseNum;
                      }
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
