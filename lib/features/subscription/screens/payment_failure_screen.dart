import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/receipt_row.dart';
import 'checkout_screen.dart';
import 'payment_method_screen.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'payment_unsuccessful'.tr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'payment_unsuccessful_desc'.tr,
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
                    ReceiptRow(label: 'transaction_plan'.tr, value: planLabel),
                    Divider(height: 20, thickness: 0.5, color: borderColor),
                    ReceiptRow(
                      label: 'transaction_amount'.tr,
                      value: amountLabel,
                      isBoldValue: true,
                    ),
                    Divider(height: 20, thickness: 0.5, color: borderColor),
                    ReceiptRow(
                      label: 'reason_label'.tr,
                      value: 'insufficient_funds'.tr,
                      valueColor: AppColors.error,
                      trailingWidget: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Column(
                children: [
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
                        Get.off(() => const CheckoutScreen());
                      },
                      child: Text(
                        'try_again'.tr,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Get.off(() => const PaymentMethodScreen());
                      },
                      child: Text(
                        'change_payment_method'.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'QARI 24/7 Support',
                        'Connecting you to billing team sandbox customer service...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                      );
                    },
                    child: Text(
                      'contact_support'.tr,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
