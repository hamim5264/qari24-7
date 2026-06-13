import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../subscription/screens/go_premium_screen.dart';
import '../controllers/recitation_controller.dart';
import '../models/quran_models.dart';
import '../widgets/surah_search_sheet.dart';
import '../widgets/audio_settings_bottom_sheet.dart';
import '../widgets/mushaf_layout_bottom_sheet.dart';
import '../widgets/mistake_detection_sheet.dart';
import '../widgets/eye_guideline_sheet.dart';
import '../widgets/quran_ayah_number_ornament.dart';

class RecitationScreen extends StatelessWidget {
  const RecitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecitationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: () {
            Get.bottomSheet(const SurahSearchSheet(), isScrollControlled: true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Obx(() {
                    final surahName =
                        controller.currentSurah.value?.englishName ??
                        'Al-Fatihah';
                    final hasAyahs =
                        controller.currentSurah.value?.ayahs.isNotEmpty ??
                        false;
                    final page = hasAyahs
                        ? controller.currentSurah.value!.ayahs.first.page
                        : 1;
                    return Text(
                      '$surahName | PG $page',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.search,
                  size: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() {
            final isSaved = controller.isSurahSaved(
              controller.currentSurahNumber.value,
            );
            return IconButton(
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSaved
                    ? AppColors.primary
                    : (isDark ? Colors.white : Colors.black87),
              ),
              onPressed: () => controller.toggleSaveSurah(
                controller.currentSurahNumber.value,
              ),
            );
          }),

          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                Get.bottomSheet(
                  const AudioSettingsBottomSheet(),
                  isScrollControlled: true,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: GestureDetector(
        onTap: () {
          controller.showMicCapsule.value = false;
          controller.showEyeCapsule.value = false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                try {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final surah = controller.currentSurah.value;
                  if (surah == null) {
                    return Center(
                      child: Text(
                        'Failed to load Surah data.',
                        style: TextStyle(color: textGrey),
                      ),
                    );
                  }

                  final hasAyahs = surah.ayahs.isNotEmpty;
                  final firstPage = hasAyahs ? surah.ayahs.first.page : 1;
                  final firstJuz = hasAyahs ? surah.ayahs.first.juz : 1;

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        color: isDark
                            ? const Color(0xFF101010)
                            : Colors.grey.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Page $firstPage • Juz $firstJuz",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textGrey,
                              ),
                            ),
                            Text(
                              "${surah.numberOfAyahs} Ayahs • ${surah.revelationType}",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(child: _buildVersesContent(context, surah)),

                      const SizedBox(height: 90),
                    ],
                  );
                } catch (e, stack) {
                  debugPrint("CRITICAL ERROR IN MAIN BODY OBX: $e\n$stack");
                  controller.isLoading.value;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            'Main body error: $e\n\n$stack',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),

            Positioned(
              top: 12,
              left: 20,
              right: 20,
              child: Obx(() {
                if (!controller.mistakeDetectionActive.value ||
                    controller.isRecitingMic.value) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: controller.detectedMistakeAyahs.isNotEmpty
                        ? Colors.red.shade900.withValues(alpha: 0.95)
                        : AppColors.primary.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.detectedMistakeAyahs.isNotEmpty
                            ? Icons.error_outline
                            : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.mistakeStatusMessage.value,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (controller.detectedMistakeAyahs.isNotEmpty)
                        TextButton(
                          onPressed: () => controller.stopMistakeDetection(),
                          child: const Text(
                            'RESET',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),

            Positioned(
              bottom: 84,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: Obx(() {
                if (!controller.showMicCapsule.value) {
                  return const SizedBox.shrink();
                }
                return _buildMicCapsule(context, controller);
              }),
            ),

            Positioned(
              bottom: 84,
              right: 24,
              child: Obx(() {
                if (!controller.showEyeCapsule.value) {
                  return const SizedBox.shrink();
                }
                return _buildEyeCapsule(context, controller);
              }),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildBottomDock(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesContent(BuildContext context, Surah surah) {
    final controller = Get.find<RecitationController>();

    return Obx(() {
      try {
        final layout = controller.mushafLayout.value;
        if (layout == 'book') {
          return _buildBookLayout(context, surah);
        } else if (layout == 'text') {
          return _buildTextOnlyLayout(context, surah);
        } else {
          return _buildTranslationLayout(context, surah);
        }
      } catch (e, stack) {
        debugPrint("CRITICAL ERROR IN NESTED VERSES OBX BUILDER: $e\n$stack");
        return _buildErrorWidget("Verses Layout Selection Error", e, stack);
      }
    });
  }

  Widget _buildBookLayout(BuildContext context, Surah surah) {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : const Color(0xFFF9F6ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.grey.shade900 : const Color(0xFFE8DCC4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QuranTextRenderer(surah: surah, layout: 'book'),
        ),
      );
    } catch (e, stack) {
      return _buildErrorWidget("Book Layout Error", e, stack);
    }
  }

  Widget _buildTextOnlyLayout(BuildContext context, Surah surah) {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: QuranTextRenderer(surah: surah, layout: 'text'),
      );
    } catch (e, stack) {
      return _buildErrorWidget("Text Layout Error", e, stack);
    }
  }

  Widget _buildTranslationLayout(BuildContext context, Surah surah) {
    try {
      final controller = Get.find<RecitationController>();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
      final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: surah.ayahs.length,
        itemBuilder: (context, index) {
          try {
            final ayah = surah.ayahs[index];

            return Obx(() {
              try {
                final isHidden = controller.isAyahCurrentlyHidden(
                  ayah.numberInSurah,
                );
                final isMistake = controller.detectedMistakeAyahs.contains(
                  ayah.numberInSurah,
                );
                final isPlaying =
                    controller.currentPlayingAyahIndex.value ==
                    ayah.numberInSurah;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMistake
                          ? Colors.red
                          : (isPlaying
                                ? AppColors.primary
                                : (isDark
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade200)),
                      width: isMistake ? 1.5 : (isPlaying ? 1.5 : 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Ayah ${ayah.numberInSurah}",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (isMistake)
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "MISTAKE DETECTED",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isHidden
                                      ? AppColors.primary
                                      : Colors.grey.shade400,
                                  size: 18,
                                ),
                                onPressed: () {
                                  final settingsController = Get.find<SettingsController>();
                                  if (!settingsController.isPremium.value) {
                                    Get.to(() => const GoPremiumScreen());
                                  } else {
                                    controller.toggleSingleAyahVisibility(
                                      ayah.numberInSurah,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isHidden) ...[
                        GestureDetector(
                          onTap: () {
                            final settingsController = Get.find<SettingsController>();
                            if (!settingsController.isPremium.value) {
                              Get.to(() => const GoPremiumScreen());
                            } else {
                              controller.toggleSingleAyahVisibility(
                                ayah.numberInSurah,
                              );
                            }
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility_off,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.8,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Tap to reveal Arabic text",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Text.rich(
                          TextSpan(
                            children: _getTajweedTextSpans(context, ayah),
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                      const SizedBox(height: 14),

                      Text(
                        ayah.textTranslation,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: controller.fontSizeTranslation.value,
                          color: isMistake ? Colors.red.shade200 : textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("Ayah Render Error: $e"),
                );
              }
            });
          } catch (e) {
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("Ayah Build Error: $e"),
            );
          }
        },
      );
    } catch (e, stack) {
      return _buildErrorWidget("Translation Layout Error", e, stack);
    }
  }

  Widget _buildMicCapsule(
    BuildContext context,
    RecitationController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                controller.showMicCapsule.value = false;
                controller.playAudioForRange();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Listen',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          GestureDetector(
            onTap: () {
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                controller.showMicCapsule.value = false;
                controller.toggleRecitingMic();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Recite',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyeCapsule(
    BuildContext context,
    RecitationController controller,
  ) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final active = !controller.showLinesWithAyahNumber.value;
            return IconButton(
              icon: Icon(
                Icons.keyboard_double_arrow_up,
                color: active ? const Color(0xFFE2B93C) : Colors.white70,
                size: 22,
              ),
              onPressed: () {
                final settingsController = Get.find<SettingsController>();
                if (!settingsController.isPremium.value) {
                  Get.to(() => const GoPremiumScreen());
                } else {
                  controller.showLinesWithAyahNumber.value =
                      !controller.showLinesWithAyahNumber.value;
                }
              },
              tooltip: 'Hide/Show Lines',
            );
          }),
          const SizedBox(height: 8),
          Obx(() {
            final active = controller.showTajweed.value;
            return IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: active ? const Color(0xFFE2B93C) : Colors.white70,
                size: 22,
              ),
              onPressed: () {
                final settingsController = Get.find<SettingsController>();
                if (!settingsController.isPremium.value) {
                  Get.to(() => const GoPremiumScreen());
                } else {
                  controller.toggleTajweed();
                }
              },
              tooltip: 'Toggle Tajwid',
            );
          }),
          const SizedBox(height: 8),
          Obx(() {
            final active = controller.isAyahHiddenMode.value;
            return IconButton(
              icon: Icon(
                Icons.visibility_off,
                color: active ? const Color(0xFFE2B93C) : Colors.white70,
                size: 22,
              ),
              onPressed: () {
                final settingsController = Get.find<SettingsController>();
                if (!settingsController.isPremium.value) {
                  Get.to(() => const GoPremiumScreen());
                } else {
                  controller.toggleAyahHiddenMode();
                }
              },
              tooltip: 'Toggle Hide Mode',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomDock(
    BuildContext context,
    RecitationController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.music_note,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: () {
              controller.showMicCapsule.value = false;
              controller.showEyeCapsule.value = false;
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                Get.bottomSheet(
                  const AudioSettingsBottomSheet(),
                  isScrollControlled: true,
                );
              }
            },
            tooltip: 'Audio Settings',
          ),

          GestureDetector(
            onTap: () {
              controller.showMicCapsule.value = false;
              controller.showEyeCapsule.value = false;
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                Get.bottomSheet(
                  const MistakeDetectionSheet(),
                  isScrollControlled: true,
                );
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.psychology,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  size: 26,
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Obx(() {
                    final mistakes = controller.realTimeMistakeCount.value;
                    if (mistakes == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$mistakes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          Obx(() {
            return PulsingMicButton(
              isListening: controller.isRecitingMic.value,
              isActive: controller.isPlayingAudio.value,
              isDark: isDark,
              onTap: () {
                controller.showEyeCapsule.value = false;
                if (controller.isPlayingAudio.value) {
                  controller.stopAudioPlayback();
                } else if (controller.isRecitingMic.value) {
                  controller.toggleRecitingMic();
                } else {
                  controller.showMicCapsule.value =
                      !controller.showMicCapsule.value;
                }
              },
            );
          }),

          IconButton(
            icon: Icon(
              Icons.menu_book,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: () {
              controller.showMicCapsule.value = false;
              controller.showEyeCapsule.value = false;
              Get.bottomSheet(
                const MushafLayoutBottomSheet(),
                isScrollControlled: true,
              );
            },
            tooltip: 'Mushaf Layout',
          ),

          GestureDetector(
            onTap: () {
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                controller.showMicCapsule.value = false;
                controller.showEyeCapsule.value =
                    !controller.showEyeCapsule.value;
              }
            },
            onLongPress: () {
              final settingsController = Get.find<SettingsController>();
              if (!settingsController.isPremium.value) {
                Get.to(() => const GoPremiumScreen());
              } else {
                controller.showMicCapsule.value = false;
                controller.showEyeCapsule.value = false;
                Get.bottomSheet(
                  const EyeGuidelineSheet(),
                  isScrollControlled: true,
                );
              }
            },
            child: Obx(() {
              final active = controller.isAyahHiddenMode.value;
              return Icon(
                active ? Icons.visibility_off : Icons.visibility,
                color: active
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: 24,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    String contextName,
    dynamic error,
    StackTrace? stack,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contextName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final controller = Get.find<RecitationController>();
                controller.loadSurah(controller.currentSurahNumber.value);
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                "Retry",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuranTextRenderer extends StatefulWidget {
  final Surah surah;
  final String layout;

  const QuranTextRenderer({
    super.key,
    required this.surah,
    required this.layout,
  });

  @override
  State<QuranTextRenderer> createState() => _QuranTextRendererState();
}

class _QuranTextRendererState extends State<QuranTextRenderer> {
  final List<GestureRecognizer> _recognizers = [];

  void _clearRecognizers() {
    _recognizers.clear();
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      try {
        recognizer.dispose();
      } catch (_) {}
    }
    _recognizers.clear();
    super.dispose();
  }

  Widget _buildBismillahHeader(BuildContext context) {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahNum = widget.surah.number;

    if (surahNum == 9) return const SizedBox.shrink();

    final baseStyle = TextStyle(
      fontSize: controller.fontSizeArabic.value + 2,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : AppColors.primary,
    );

    if (!controller.isRecitingMic.value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
          textAlign: TextAlign.center,
          style: baseStyle,
        ),
      );
    }

    final bismillahWords = ["بِسْمِ", "ٱللَّهِ", "ٱلرَّحْمَٰنِ", "ٱلرَّحِيمِ"];

    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    final standardColor = isDark ? Colors.white : Colors.black;
    final activeStyle = baseStyle.copyWith(color: standardColor);

    int activeIndex = -1;
    if (controller.currentRecitingAyahNum.value == 0) {
      for (int i = 0; i < bismillahWords.length; i++) {
        final wordKey = "${surahNum}_0_$i";
        if (!controller.wordHighlightStatuses.containsKey(wordKey)) {
          activeIndex = i;
          break;
        }
      }
    }

    final List<TextSpan> spans = [];

    for (int i = 0; i < bismillahWords.length; i++) {
      final word = bismillahWords[i];
      final isWordActive =
          (controller.currentRecitingAyahNum.value == 0 && i == activeIndex);
      final wordKey = "${surahNum}_0_$i";
      final status = controller.wordHighlightStatuses[wordKey];

      Color color;
      TextDecoration decoration = TextDecoration.none;
      Color? decorationColor;
      double? decorationThickness;

      if (isWordActive) {
        color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF14532D);
      } else if (status != null) {
        if (status == 'correct') {
          color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32);
        } else if (status == 'minor_mistake') {
          color = const Color(0xFFFBC02D);
          decoration = TextDecoration.underline;
          decorationColor = const Color(0xFFFBC02D);
          decorationThickness = 2.0;
        } else if (status == 'major_mistake') {
          color = const Color(0xFFD32F2F);
          decoration = TextDecoration.underline;
          decorationColor = const Color(0xFFD32F2F);
          decorationThickness = 2.5;
        } else {
          color = standardColor;
        }
      } else {
        color = standardColor;
      }

      final bgHighlight = isWordActive
          ? settingsController.getHighlightColor(isDark)
          : (status != null
                ? (status == 'correct'
                      ? const Color(0x114ADE80)
                      : (status == 'minor_mistake'
                            ? const Color(0x22FBC02D)
                            : const Color(0x22D32F2F)))
                : Colors.transparent);

      final wordIndex = i;
      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () {
          debugPrint(
            "[QuranTextRenderer] Tapped Bismillah word index $wordIndex",
          );
          controller.playWordAudio(surahNum, 0, wordIndex);
        };
      _recognizers.add(tapRecognizer);

      spans.add(
        TextSpan(
          text: word + (i < bismillahWords.length - 1 ? " " : ""),
          recognizer: tapRecognizer,
          style: activeStyle.copyWith(
            color: color,
            backgroundColor: bgHighlight,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationThickness: decorationThickness,
            shadows: isWordActive
                ? [
                    Shadow(
                      color: isDark
                          ? const Color(0xAA4ADE80)
                          : const Color(0x3316A34A),
                      blurRadius: 8.0,
                    ),
                  ]
                : null,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecitationController>();

    return Obx(() {
      try {
        _clearRecognizers();

        controller.fontSizeArabic.value;
        controller.showLinesWithAyahNumber.value;
        controller.showTajweed.value;
        controller.isAyahHiddenMode.value;
        controller.currentPlayingAyahIndex.value;
        controller.detectedMistakeAyahs.length;
        controller.hiddenAyahNumbers.length;
        controller.audioPosition.value;
        controller.audioDuration.value;
        controller.isRecitingMic.value;
        controller.currentRecitingAyahNum.value;
        controller.wordHighlightStatuses.length;

        final ayahs = widget.surah.ayahs;
        if (ayahs.isEmpty) return const SizedBox.shrink();

        const blockSize = 15;
        final blockCount = (ayahs.length / blockSize).ceil();

        return ListView.builder(
          shrinkWrap: widget.layout == 'book',
          physics: widget.layout == 'book'
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemCount: blockCount + 1,
          itemBuilder: (context, index) {
            try {
              if (index == 0) {
                return _buildBismillahHeader(context);
              }

              final blockIdx = index - 1;
              final start = blockIdx * blockSize;
              final end = (start + blockSize < ayahs.length)
                  ? start + blockSize
                  : ayahs.length;

              final List<InlineSpan> spans = [];

              for (int i = start; i < end; i++) {
                final ayah = ayahs[i];
                final isHidden = controller.isAyahCurrentlyHidden(
                  ayah.numberInSurah,
                );

                if (isHidden) {
                  final tapRecognizer = TapGestureRecognizer()
                    ..onTap = () => controller.toggleSingleAyahVisibility(
                      ayah.numberInSurah,
                    );
                  _recognizers.add(tapRecognizer);

                  spans.add(
                    TextSpan(
                      text: "  [ 👁️ Verse ${ayah.numberInSurah} ]  ",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: controller.fontSizeArabic.value - 6,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                      recognizer: tapRecognizer,
                    ),
                  );
                  spans.add(const TextSpan(text: " "));
                } else {
                  final tajweedSpans = _getTajweedTextSpans(context, ayah);

                  spans.addAll(tajweedSpans);

                  spans.add(
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => controller.toggleSingleAyahVisibility(
                          ayah.numberInSurah,
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: QuranAyahNumberOrnament(
                            number: ayah.numberInSurah,
                            size: controller.fontSizeArabic.value * 1.1,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }

              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(children: spans),
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.8),
                  ),
                ),
              );
            } catch (e, stack) {
              debugPrint(
                "CRITICAL ERROR IN QuranTextRenderer itemBuilder: $e\n$stack",
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Block $index Render Error: $e",
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ),
              );
            }
          },
        );
      } catch (e, stack) {
        debugPrint("CRITICAL ERROR IN QURAN TEXT RENDERER: $e\n$stack");
        controller.fontSizeArabic.value;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error rendering verses: $e\n\n$stack',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
    });
  }
}

List<TextSpan> _getTajweedTextSpans(BuildContext context, Ayah ayah) {
  try {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    final standardColor = controller.isRecitingMic.value
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white : Colors.black87);
    final arabicStyle = TextStyle(
      fontSize: controller.fontSizeArabic.value,
      fontWeight: FontWeight.w600,
      color: standardColor,
    );

    final wordSpans = ayah.tajweedSpans;
    if (wordSpans == null || wordSpans.isEmpty) {
      return [TextSpan(text: ayah.text, style: arabicStyle)];
    }

    final isPlaying =
        controller.currentPlayingAyahIndex.value == ayah.numberInSurah;
    final isMistake = controller.detectedMistakeAyahs.contains(
      ayah.numberInSurah,
    );

    int activeIndex = -1;
    if (isPlaying &&
        controller.audioDuration.value.inMilliseconds > 0 &&
        controller.audioPosition.value.inMilliseconds > 0) {
      final ratio =
          controller.audioPosition.value.inMilliseconds /
          controller.audioDuration.value.inMilliseconds;
      activeIndex = (ratio * wordSpans.length).floor();
      if (activeIndex >= wordSpans.length) activeIndex = wordSpans.length - 1;
      if (activeIndex < 0) activeIndex = 0;
    } else if (controller.isRecitingMic.value &&
        controller.currentRecitingAyahNum.value == ayah.numberInSurah) {
      for (int i = 0; i < wordSpans.length; i++) {
        final wordKey =
            "${controller.currentSurahNumber.value}_${ayah.numberInSurah}_$i";
        if (!controller.wordHighlightStatuses.containsKey(wordKey)) {
          activeIndex = i;
          break;
        }
      }
    }

    final List<TextSpan> resultSpans = [];

    for (int i = 0; i < wordSpans.length; i++) {
      final span = wordSpans[i];
      final isWordActive = (i == activeIndex);

      final wordKey =
          "${controller.currentSurahNumber.value}_${ayah.numberInSurah}_$i";
      final status = controller.wordHighlightStatuses[wordKey];

      Color color;
      TextDecoration decoration = TextDecoration.none;
      Color? decorationColor;
      double? decorationThickness;

      if (isWordActive) {
        color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF14532D);
      } else if (status != null) {
        if (status == 'correct') {
          color = isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32);
        } else if (status == 'minor_mistake') {
          color = const Color(0xFFFBC02D);
          decoration = TextDecoration.underline;
          decorationColor = const Color(0xFFFBC02D);
          decorationThickness = 2.0;
        } else if (status == 'major_mistake') {
          color = const Color(0xFFD32F2F);
          decoration = TextDecoration.underline;
          decorationColor = const Color(0xFFD32F2F);
          decorationThickness = 2.5;
        } else {
          color = standardColor;
        }
      } else if (!controller.showLinesWithAyahNumber.value) {
        color = Colors.transparent;
        decoration = TextDecoration.underline;
        decorationColor = isMistake
            ? Colors.red
            : (isDark ? Colors.white30 : Colors.black12);
        decorationThickness = 1.5;
      } else if (controller.showTajweed.value &&
          !controller.isRecitingMic.value) {
        switch (span.rule) {
          case TajweedRule.ghunnah:
            color = const Color(0xFF0F3A27);
            if (isDark) color = Colors.green.shade400;
            break;
          case TajweedRule.qalqalah:
            color = Colors.cyan.shade700;
            if (isDark) color = Colors.cyan.shade300;
            break;
          case TajweedRule.madd:
            color = Colors.red.shade700;
            if (isDark) color = Colors.red.shade400;
            break;
          case TajweedRule.idgham:
            color = Colors.orange.shade800;
            if (isDark) color = Colors.orange.shade400;
            break;
          case TajweedRule.ikhfa:
            color = Colors.purple.shade700;
            if (isDark) color = Colors.purple.shade400;
            break;
          case TajweedRule.none:
            color = standardColor;
            break;
        }
      } else {
        color = standardColor;
      }

      final bgHighlight = isWordActive
          ? settingsController.getHighlightColor(isDark)
          : (status != null
                ? (status == 'correct'
                      ? const Color(0x114ADE80)
                      : (status == 'minor_mistake'
                            ? const Color(0x22FBC02D)
                            : const Color(0x22D32F2F)))
                : (!controller.showLinesWithAyahNumber.value
                      ? Colors.transparent
                      : (isMistake
                            ? Colors.red.shade900.withValues(alpha: 0.2)
                            : (isPlaying
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.transparent))));

      final wordIndex = i;
      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () {
          debugPrint(
            "[QuranTextRenderer] Tapped word index $wordIndex of Ayah ${ayah.numberInSurah}",
          );
          controller.playWordAudio(
            controller.currentSurahNumber.value,
            ayah.numberInSurah,
            wordIndex,
          );
        };
      controller.activeTapRecognizers.add(tapRecognizer);

      resultSpans.add(
        TextSpan(
          text: span.text,
          recognizer: tapRecognizer,
          style: arabicStyle.copyWith(
            color: color,
            backgroundColor: bgHighlight,
            fontWeight:
                (isWordActive ||
                    (controller.showTajweed.value &&
                        span.rule != TajweedRule.none))
                ? FontWeight.bold
                : FontWeight.w600,
            decoration: isMistake && status == null
                ? TextDecoration.underline
                : decoration,
            decorationColor: isMistake && status == null
                ? Colors.red
                : decorationColor,
            decorationThickness: decorationThickness,
            shadows: isWordActive
                ? [
                    Shadow(
                      color: isDark
                          ? const Color(0xAA4ADE80)
                          : const Color(0x3316A34A),
                      blurRadius: 8.0,
                    ),
                  ]
                : null,
          ),
        ),
      );
    }

    return resultSpans;
  } catch (e) {
    return [
      TextSpan(
        text: ayah.text,
        style: const TextStyle(color: Colors.red),
      ),
    ];
  }
}

class PulsingMicButton extends StatefulWidget {
  final bool isListening;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const PulsingMicButton({
    super.key,
    required this.isListening,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isListening || widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PulsingMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isListening || widget.isActive) && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isListening &&
        !widget.isActive &&
        _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = widget.isListening
        ? const Color(0xFFC62828)
        : widget.isActive
        ? AppColors.primary
        : const Color(0xFF0F3A27);

    final Color ringColor = widget.isListening
        ? const Color(0xFFC62828)
        : AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (widget.isListening || widget.isActive)
            ...List.generate(3, (index) {
              final double delay = index * 0.4;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double value = (_controller.value - delay) % 1.0;
                  if (value < 0) value += 1.0;
                  final double scale = 1.0 + (value * 1.5);
                  final double opacity = 1.0 - value;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withValues(alpha: opacity * 0.25),
                        border: Border.all(
                          color: ringColor.withValues(alpha: opacity * 0.45),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(
                    alpha: widget.isListening || widget.isActive ? 0.6 : 0.3,
                  ),
                  blurRadius: widget.isListening || widget.isActive ? 14 : 8,
                  spreadRadius: widget.isListening || widget.isActive ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.isListening
                  ? Icons.mic
                  : widget.isActive
                  ? Icons.pause
                  : Icons.mic_none_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
