import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

class ComparisonTable extends StatelessWidget {
  const ComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTitle = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final comparisonData = [
      {'feature': 'premium_feature_1'.tr, 'free': true, 'premium': true},
      {'feature': 'premium_feature_2'.tr, 'free': false, 'premium': true},
      {'feature': 'premium_feature_3'.tr, 'free': false, 'premium': true},
      {'feature': 'premium_feature_4'.tr, 'free': false, 'premium': true},
      {'feature': 'premium_feature_5'.tr, 'free': false, 'premium': true},
      {'feature': 'Mistake Frequency', 'free': false, 'premium': true},
      {'feature': 'premium_feature_6'.tr, 'free': false, 'premium': true},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'compare_features'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textTitle,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'free_column'.tr.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'premium_column'.tr.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comparisonData.length,
            separatorBuilder: (context, index) => Divider(
              height: 20,
              thickness: 0.5,
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final row = comparisonData[index];
              final hasFree = row['free'] as bool;
              final hasPremium = row['premium'] as bool;

              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      row['feature'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: hasFree
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 18,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              size: 16,
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: hasPremium
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 18,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
