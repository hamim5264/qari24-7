import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/recitation_controller.dart';

class MushafLayoutBottomSheet extends StatelessWidget {
  const MushafLayoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecitationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textTitle = isDark ? Colors.white : Colors.black87;

    return Container(
      height: context.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'mushaf_layout'.tr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textTitle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Reading Layout'.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final isSelected = controller.mushafLayout.value == 'book';
                    return _buildLayoutOption(
                      context: context,
                      icon: Icons.menu_book,
                      title: 'book_layout'.tr,
                      subtitle: 'Book (Indopak/Classic Mushaf Page)',
                      isSelected: isSelected,
                      onTap: () => controller.toggleMushafLayout('book'),
                    );
                  }),
                  const SizedBox(height: 10),

                  Obx(() {
                    final isSelected = controller.mushafLayout.value == 'text';
                    return _buildLayoutOption(
                      context: context,
                      icon: Icons.text_fields_rounded,
                      title: 'quran_text_layout'.tr,
                      subtitle: 'Quran Text (Continuous Simple Uthmani Arabic)',
                      isSelected: isSelected,
                      onTap: () => controller.toggleMushafLayout('text'),
                    );
                  }),
                  const SizedBox(height: 10),

                  Obx(() {
                    final isSelected =
                        controller.mushafLayout.value == 'translation';
                    return _buildLayoutOption(
                      context: context,
                      icon: Icons.translate_rounded,
                      title: 'translation_layout'.tr,
                      subtitle: 'Translation (Arabic Verses with Translations)',
                      isSelected: isSelected,
                      onTap: () => controller.toggleMushafLayout('translation'),
                    );
                  }),
                  const SizedBox(height: 24),

                  Text(
                    'font_size_arabic'.tr.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Row(
                      children: [
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: controller.fontSizeArabic.value,
                            min: 18.0,
                            max: 38.0,
                            activeColor: AppColors.primary,
                            inactiveColor: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            onChanged: (val) {
                              controller.fontSizeArabic.value = val;
                            },
                          ),
                        ),
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  Text(
                    'Font Size - Translation'.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Row(
                      children: [
                        const Text('A', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: controller.fontSizeTranslation.value,
                            min: 12.0,
                            max: 24.0,
                            activeColor: AppColors.secondary,
                            inactiveColor: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            onChanged: (val) {
                              controller.fontSizeTranslation.value = val;
                            },
                          ),
                        ),
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildLayoutOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final borderTheme = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderTheme,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
