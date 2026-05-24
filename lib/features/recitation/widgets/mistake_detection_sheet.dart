import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/recitation_controller.dart';

class MistakeDetectionSheet extends StatelessWidget {
  const MistakeDetectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textTitle = isDark ? Colors.white : Colors.black87;

    return Container(
      height: context.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'mistake_detection'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textTitle,
                  ),
                  maxLines: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              final surah = controller.currentSurah.value;
              if (surah == null) {
                return Center(
                  child: Text(
                    'no_active_surah'.tr,
                    style: TextStyle(color: textGrey),
                  ),
                );
              }

              final mistakesList = <Map<String, dynamic>>[];
              controller.wordHighlightStatuses.forEach((key, value) {
                if (value == 'minor_mistake' || value == 'major_mistake') {
                  final parts = key.split('_');
                  if (parts.length == 3) {
                    final surahNum = int.tryParse(parts[0]) ?? 0;
                    final ayahNum = int.tryParse(parts[1]) ?? 0;
                    final wordIndex = int.tryParse(parts[2]) ?? 0;

                    if (surahNum == surah.number) {
                      if (ayahNum == 0) {
                        final bismillahWords = [
                          "بِسْمِ",
                          "ٱللَّهِ",
                          "ٱلرَّحْمَٰنِ",
                          "ٱلرَّحِيمِ",
                        ];
                        String wordText = "";
                        if (wordIndex < bismillahWords.length) {
                          wordText = bismillahWords[wordIndex];
                        }
                        mistakesList.add({
                          'ayahNum': 0,
                          'wordIndex': wordIndex,
                          'wordText': wordText,
                          'type': value,
                        });
                      } else {
                        final ayah = surah.ayahs.firstWhereOrNull(
                          (a) => a.numberInSurah == ayahNum,
                        );
                        if (ayah != null) {
                          String wordText = "";
                          if (ayah.tajweedSpans != null &&
                              wordIndex < ayah.tajweedSpans!.length) {
                            wordText = ayah.tajweedSpans![wordIndex].text
                                .trim();
                          } else {
                            final words = ayah.text
                                .split(' ')
                                .where((w) => w.trim().isNotEmpty)
                                .toList();
                            if (wordIndex < words.length) {
                              wordText = words[wordIndex];
                            }
                          }

                          mistakesList.add({
                            'ayahNum': ayahNum,
                            'wordIndex': wordIndex,
                            'wordText': wordText,
                            'type': value,
                          });
                        }
                      }
                    }
                  }
                }
              });

              if (mistakesList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: isDark
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFF2E7D32),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_discrepancies'.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'recite_clearly_desc'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              int totalAssessed = 0;
              final totalMistakes = mistakesList.length;

              controller.wordHighlightStatuses.forEach((key, value) {
                if (key.startsWith("${surah.number}_")) {
                  totalAssessed++;
                }
              });

              double accuracy = 100.0;
              if (totalAssessed > 0) {
                accuracy =
                    ((totalAssessed - totalMistakes) / totalAssessed) * 100;
                if (accuracy < 0) accuracy = 0.0;
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161616)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${accuracy.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accuracy >= 90
                                      ? (isDark
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFF2E7D32))
                                      : (accuracy >= 70
                                            ? Colors.amber
                                            : Colors.redAccent),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'accuracy'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${mistakesList.length}",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'total_mistakes'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${mistakesList.where((m) => m['type'] == 'major_mistake').length}",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'major_mistakes'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${mistakesList.where((m) => m['type'] == 'minor_mistake').length}",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'minor_mistakes'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'discrepancies_list'.tr.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: mistakesList.length,
                      itemBuilder: (context, index) {
                        final item = mistakesList[index];
                        final isMajor = item['type'] == 'major_mistake';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMajor
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : Colors.amber.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isMajor ? Colors.red : Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Ayah ${item['ayahNum']}",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isMajor
                                                ? Colors.red
                                                : Colors.amber.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMajor
                                                ? Colors.red.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.amber.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            isMajor
                                                ? 'major_mistakes'.tr
                                                      .toUpperCase()
                                                : 'minor_mistakes'.tr
                                                      .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: isMajor
                                                  ? Colors.red
                                                  : Colors.amber.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['wordText'],
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textTitle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.volume_up,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  controller.playWordAudio(
                                    controller.currentSurahNumber.value,
                                    item['ayahNum'],
                                    item['wordIndex'],
                                  );
                                },
                                tooltip: 'listen_pronunciation'.tr,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
