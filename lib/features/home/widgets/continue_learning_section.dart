import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../recitation/screens/recitation_screen.dart';
import '../../recitation/controllers/recitation_controller.dart';
import '../../progress/controllers/progress_controller.dart';

class ContinueLearningSection extends StatelessWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressController = Get.isRegistered<ProgressController>()
        ? Get.find<ProgressController>()
        : Get.put(ProgressController());

    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Obx(() {
        final completedSurahId = progressController.rxCompletedSurahId.value;
        final completedTitle = progressController.rxCompletedSurahTitle.value;
        final completedTotal = progressController.rxCompletedSurahTotalVerses.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'continue_learning'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                 GestureDetector(
                  onTap: () {
                    final recController = Get.put(RecitationController());
                    recController.loadSurah(1); // load Al-Fatihah by default
                    Get.to(() => const RecitationScreen());
                  },
                  child: Text(
                    'view_library'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade400 : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (progressController.rxHasRecentSurah.value && progressController.rxRecentSurahs.isNotEmpty)
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: progressController.rxRecentSurahs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = progressController.rxRecentSurahs[index];
                  final surahId = item['id'] as int? ?? 1;
                  final title = item['title'] as String? ?? '';
                  final englishName = item['english_name'] as String? ?? '';
                  final read = item['verses_read'] as int? ?? 0;
                  final total = item['total_verses'] as int? ?? 1;
                  final percent = total > 0 ? (read / total) : 0.0;

                  return Container(
                    padding: const EdgeInsets.all(16.0),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index == 0 ? 'recent_surah'.tr.toUpperCase() : 'continue_learning'.tr.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title.tr,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              if (englishName.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  englishName,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: textGrey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Verses',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: textGrey,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$read',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '    $total',
                                          style: TextStyle(color: titleColor),
                                        ),
                                      ],
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFF2B2B2B),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFE2B93C),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () {
                                  final recController = Get.put(RecitationController());
                                  recController.loadSurah(surahId);
                                  Get.to(() => const RecitationScreen());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6ECE9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'resume'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F3A27),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.play_arrow,
                                        size: 14,
                                        color: Color(0xFF0F3A27),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 106,
                          height: 106,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(surahId == 67
                                  ? 'assets/images/quran_mulk.png'
                                  : 'assets/images/quran_fatihah.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 42.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [const Color(0xFF141414), const Color(0xFF0C1D13)]
                        : [Colors.white, const Color(0xFFF0FDF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E3526) : const Color(0xFFDCFCE7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withValues(alpha: 0.3) 
                          : Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color(0xFF1B3B2B).withValues(alpha: 0.3)
                            : const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        boxShadow: isDark ? [
                          BoxShadow(
                            color: const Color(0xFF0F4E36).withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: isDark ? const Color(0xFF52B788) : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Start Your Quranic Journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have not recited any surahs yet. Open the library to start reciting with AI correction and track your progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        final recController = Get.put(RecitationController());
                        recController.loadSurah(1); // load Al-Fatihah
                        Get.to(() => const RecitationScreen());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Open Quran Library',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (progressController.rxHasCompletedSurah.value) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'completed_surah'.tr.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            completedTitle.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Verses',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: textGrey,
                                ),
                              ),
                              Text(
                                completedTotal < 10 ? '0$completedTotal' : '$completedTotal',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 1.0,
                              minHeight: 6,
                              backgroundColor: Color(0xFF2B2B2B),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFE2B93C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () {
                              final recController = Get.put(RecitationController());
                              recController.loadSurah(completedSurahId);
                              Get.to(() => const RecitationScreen());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6ECE9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'recite'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F3A27),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.sync,
                                    size: 14,
                                    color: Color(0xFF0F3A27),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Container(
                      width: 106,
                      height: 106,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(completedSurahId == 1
                              ? 'assets/images/quran_fatihah.png'
                              : 'assets/images/quran_mulk.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
