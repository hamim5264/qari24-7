import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../widgets/category_select_card.dart';

class AddFeatureScreen extends StatefulWidget {
  const AddFeatureScreen({super.key});

  @override
  State<AddFeatureScreen> createState() => _AddFeatureScreenState();
}

class _AddFeatureScreenState extends State<AddFeatureScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SettingsController>();

    final categories = [
      {
        'label': 'category_reading'.tr,
        'icon': Icons.menu_book_rounded,
        'id': 'Reading',
      },
      {
        'label': 'category_audio'.tr,
        'icon': Icons.headphones_rounded,
        'id': 'Audio',
      },
      {
        'label': 'category_learning'.tr,
        'icon': Icons.school_rounded,
        'id': 'Learning',
      },
      {
        'label': 'category_interface'.tr,
        'icon': Icons.palette_rounded,
        'id': 'Interface',
      },
      {
        'label': 'category_progress'.tr,
        'icon': Icons.analytics_rounded,
        'id': 'Progress',
      },
      {
        'label': 'category_other'.tr,
        'icon': Icons.auto_awesome_rounded,
        'id': 'Other',
      },
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'add_feature_title'.tr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'add_feature_info'.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'select_category'.tr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value == cat['id'];
                    return CategorySelectCard(
                      icon: cat['icon'] as IconData,
                      label: cat['label'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        controller.selectedCategory.value = cat['id'] as String;
                      },
                    );
                  });
                },
              ),
              const SizedBox(height: 28),

              Text(
                'describe_feature'.tr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final textLength = controller.feedbackDescription.value.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? AppColors.primary
                              : (isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade200),
                          width: _focusNode.hasFocus ? 1.5 : 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 6,
                        maxLength: 500,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'describe_feature_placeholder'.tr,
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (text) {
                          controller.feedbackDescription.value = text;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$textLength/500',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 28),

              Obx(() {
                final isSubmitting = controller.isSubmittingFeedback.value;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final success = await controller
                                .submitFeatureRequest();
                            if (success) {
                              _textController.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'submit_request'.tr,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
