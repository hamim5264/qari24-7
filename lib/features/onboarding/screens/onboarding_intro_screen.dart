import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';
import '../../../core/services/localization_service.dart';

class OnboardingIntroScreen extends GetView<OnboardingController> {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizationService = Get.find<LocalizationService>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFirstScreen(context, isDark, localizationService),
                  _buildSecondScreen(context, isDark, localizationService),
                  _buildThirdScreen(context, isDark, localizationService),
                ],
              ),
            ),
            _buildBottomControls(isDark, localizationService),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstScreen(
    BuildContext context,
    bool isDark,
    LocalizationService localizationService,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'tap_mic_recite'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Obx(() {
                          final isWrong = controller.isRecitationWrong.value;
                          final baseColor = isWrong
                              ? Colors.red
                              : AppColors.primary;

                          return GestureDetector(
                            onTap: controller.startListening,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.isListening.value
                                        ? baseColor.withValues(alpha: 0.18)
                                        : baseColor.withValues(alpha: 0.06),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 95,
                                  width: 95,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.isListening.value
                                        ? baseColor.withValues(alpha: 0.35)
                                        : baseColor.withValues(alpha: 0.12),
                                  ),
                                ),
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    controller.isListening.value
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        Divider(
                          color: isDark ? Colors.grey[850] : Colors.grey[200],
                          height: 1,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[900]!.withValues(alpha: 0.5)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "٤",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Amiri',
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  "وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondScreen(
    BuildContext context,
    bool isDark,
    LocalizationService localizationService,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red[300]!,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "١",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: RichText(
                                textAlign: TextAlign.right,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  children: [
                                    const TextSpan(text: "قُلْ هُوَ اللَّهُ "),
                                    TextSpan(
                                      text: "أَحَدٌ",
                                      style: TextStyle(
                                        color: Colors.red[400],
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.dotted,
                                        decorationColor: Colors.red[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Text(
                            "112:1 Incorrect words",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[850]!
                                  : Colors.grey[100]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.grey[50]!.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            children: [
                              _buildComparisonRow(
                                "Expected",
                                "قُلْ هُوَ اللَّهُ أَحَدٌ",
                                isDark ? Colors.white : Colors.black,
                                isDark,
                                true,
                              ),
                              Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[100],
                              ),
                              _buildComparisonRow(
                                "Recited",
                                "قُلْ هُوَ اللَّهُ الصَّمَدُ",
                                Colors.red[400]!,
                                isDark,
                                false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Demonstration Purpose Only",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[650]
                                  : Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(
    String label,
    String text,
    Color textColor,
    bool isDark,
    bool isExpected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          isExpected
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                )
              : RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
                    children: [
                      const TextSpan(text: "قُلْ هُوَ اللَّهُ "),
                      TextSpan(
                        text: "الصَّمَدُ",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBulletList(bool isDark) {
    String listText = 'onboarding_subtitle_2_list'.tr;
    List<String> items = listText.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        String cleanItem = item.replaceAll('•', '').trim();
        if (cleanItem.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                cleanItem,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThirdScreen(
    BuildContext context,
    bool isDark,
    LocalizationService localizationService,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Weekly Activity",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "This Week",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [45.0, 65.0, 35.0, 55.0, 75.0, 42.0, 30.0]
                              .map(
                                (h) => Container(
                                  width: 18,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ["M", "T", "W", "T", "F", "S", "S"]
                              .map(
                                (d) => Text(
                                  d,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[850]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Text(
                            "You've read 3 hours and 45 minutes this week",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'onboarding_title_3'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSubtitle(
    String titleKey,
    String subtitleKey,
    bool isDark,
    LocalizationService localizationService,
  ) {
    return Column(
      children: [
        Obx(() {
          localizationService.currentLanguage.value;
          return Text(
            titleKey.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          );
        }),
        if (subtitleKey.isNotEmpty) ...[
          const SizedBox(height: 12),
          Obx(() {
            localizationService.currentLanguage.value;
            return Text(
              subtitleKey.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildBottomControls(
    bool isDark,
    LocalizationService localizationService,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Obx(() {
        final pageIndex = controller.currentPage.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              height: 1,
            ),
            const SizedBox(height: 16),

            if (pageIndex == 0) ...[
              _buildTitleSubtitle(
                'onboarding_title_1',
                '',
                isDark,
                localizationService,
              ),
            ] else if (pageIndex == 1) ...[
              _buildTitleSubtitle(
                'onboarding_title_2',
                '',
                isDark,
                localizationService,
              ),
              const SizedBox(height: 12),
              Center(child: IntrinsicWidth(child: _buildBulletList(isDark))),
            ] else if (pageIndex == 2) ...[
              Text(
                'onboarding_title_4'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'onboarding_subtitle_4'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            Builder(
              builder: (context) {
                bool isActive = true;
                if (pageIndex == 0) {
                  isActive = controller.isRecitationPerfect.value;
                }

                return CustomButton(
                  text: 'continue'.tr,
                  backgroundColor: isActive
                      ? AppColors.primary
                      : (isDark ? Colors.grey[900]! : Colors.grey[300]!),
                  textColor: isActive
                      ? Colors.white
                      : (isDark ? Colors.grey[700]! : Colors.grey[500]!),
                  onPressed: isActive ? controller.next : () {},
                );
              },
            ),

            const SizedBox(height: 8),
            if (pageIndex == 0)
              TextButton(
                onPressed: controller.next,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'cant_recite_now'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
