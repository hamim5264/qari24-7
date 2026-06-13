import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/screens/main_navigation_screen.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/receipt_row.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SubscriptionController controller =
        Get.find<SubscriptionController>();

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    final planLabel = controller.selectedPlan.value == 'Yearly'
        ? 'Premium Yearly'
        : 'Premium Monthly';
    final amountLabel = controller.selectedPlan.value == 'Yearly'
        ? '\$200.00'
        : '\$20.00';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        const Spacer(),

                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: AppColors.success,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'payment_successful'.tr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'payment_successful_desc'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 36),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ReceiptRow(
                                label: 'transaction_id'.tr,
                                value: '4148-000012',
                              ),
                              Divider(height: 20, thickness: 0.5, color: borderColor),
                              ReceiptRow(
                                label: 'transaction_date'.tr,
                                value: 'May 24, 2026',
                              ),
                              Divider(height: 20, thickness: 0.5, color: borderColor),
                              ReceiptRow(
                                label: 'transaction_type'.tr,
                                value: 'Credit Card',
                              ),
                              Divider(height: 20, thickness: 0.5, color: borderColor),
                              ReceiptRow(label: 'transaction_plan'.tr, value: planLabel),
                              Divider(height: 20, thickness: 0.5, color: borderColor),
                              ReceiptRow(
                                label: 'transaction_amount'.tr,
                                value: amountLabel,
                                isBoldValue: true,
                                valueColor: AppColors.primary,
                              ),
                              Divider(height: 20, thickness: 0.5, color: borderColor),
                              ReceiptRow(
                                label: 'transaction_status'.tr,
                                value: 'success_label'.tr,
                                valueColor: AppColors.success,
                                trailingWidget: const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        SizedBox(
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
                            onPressed: () {
                              Get.offAll(() => const MainNavigationScreen());
                            },
                            child: Text(
                              'back_home'.tr,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
