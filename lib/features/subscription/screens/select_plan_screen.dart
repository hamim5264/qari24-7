import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/plan_card.dart';
import 'payment_success_screen.dart';
import 'payment_failure_screen.dart';

class SelectPlanScreen extends StatelessWidget {
  const SelectPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SubscriptionController controller =
        Get.isRegistered<SubscriptionController>()
            ? Get.find<SubscriptionController>()
            : Get.put(SubscriptionController());

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final bodyColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    final premiumBenefits = [
      'premium_feature_2'.tr,
      'premium_feature_3'.tr,
      'premium_feature_4'.tr,
      'premium_feature_5'.tr,
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'choose_plan'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'unlock_premium_features'.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'unlock_premium_desc'.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: bodyColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: premiumBenefits.map((benefit) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'select_payment_title'.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(
                      () => Column(
                        children: [
                          PlanCard(
                            title: 'yearly_plan_label'.tr,
                            price: controller.yearlyPriceText,
                            subtitle: 'yearly_plan_save'.tr,
                            badgeText: 'MOST POPULAR',
                            isSelected:
                                controller.selectedPlan.value == 'Yearly',
                            onTap: () => controller.changePlan('Yearly'),
                          ),
                          const SizedBox(height: 16),
                          PlanCard(
                            title: 'monthly_plan'.tr,
                            price: controller.monthlyPriceText,
                            isSelected:
                                controller.selectedPlan.value == 'Monthly',
                            onTap: () => controller.changePlan('Monthly'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: () async {
                    Get.dialog(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade900, width: 1.5),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Connecting to secure gateway...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );
                    final success = await controller.processPayment(simulateFailure: false);
                    Get.back(); // dismiss dialog
                    if (success) {
                      Get.to(() => const PaymentSuccessScreen());
                    } else {
                      Get.to(() => const PaymentFailureScreen());
                    }
                  },
                  child: Text(
                    'purchase_now'.tr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
