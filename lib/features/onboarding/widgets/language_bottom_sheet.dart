import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/localization_service.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static const Map<String, String> nativeLanguageNames = {
    'English': 'English',
    'Arabic': 'العربية',
    'French': 'Français',
    'Spanish': 'Español',
    'Urdu': 'Urdu',
    'Mandarin': 'Mandarin',
    'Turkish': 'Türkçe',
    'Russian': 'Русский',
    'Italian': 'Italiano',
    'Portuguese': 'Português',
    'German': 'Deutsch',
  };

  @override
  Widget build(BuildContext context) {
    final localizationService = Get.find<LocalizationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            localizationService.currentLanguage.value;
            return Text(
              'select_language'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          }),
          const SizedBox(height: 10),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocalizationService.langs.length,
              itemBuilder: (context, index) {
                final lang = LocalizationService.langs[index];
                return Obx(() {
                  final isSelected =
                      localizationService.currentLanguage.value == lang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          localizationService.changeLocale(lang);
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.primary
                                      : Colors.grey.withValues(alpha: 0.15))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              nativeLanguageNames[lang] ?? lang,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                          ? Colors.white
                                          : AppColors.textPrimaryLight)
                                    : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
