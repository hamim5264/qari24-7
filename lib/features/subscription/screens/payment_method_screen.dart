import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/payment_card_mock.dart';
import 'checkout_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SubscriptionController controller =
        Get.find<SubscriptionController>();

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

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
          'select_payment_title'.tr,
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
                    const PaymentCardMock(),
                    const SizedBox(height: 32),

                    Text(
                      'add_payment_method'.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      return Column(
                        children: [
                          _buildPaymentMethodTile(
                            context: context,
                            id: 'MasterCard',
                            title: 'Credit Card',
                            subtitle: 'Visa, MasterCard, Amex',
                            icon: Icons.credit_card_rounded,
                            isSelected:
                                controller.selectedPaymentMethod.value ==
                                'MasterCard',
                            onTap: () =>
                                controller.selectPaymentMethod('MasterCard'),
                          ),
                          const SizedBox(height: 12),

                          _buildPaymentMethodTile(
                            context: context,
                            id: 'GooglePay',
                            title: 'Google Pay',
                            subtitle: 'Fast, secure & simple checkout',
                            icon: Icons.account_balance_wallet_rounded,
                            isSelected:
                                controller.selectedPaymentMethod.value ==
                                'GooglePay',
                            onTap: () =>
                                controller.selectPaymentMethod('GooglePay'),
                          ),
                          const SizedBox(height: 12),

                          _buildPaymentMethodTile(
                            context: context,
                            id: 'ApplePay',
                            title: 'Apple Pay',
                            subtitle: 'Quick iOS safe authorization',
                            icon: Icons.apple_rounded,
                            isSelected:
                                controller.selectedPaymentMethod.value ==
                                'ApplePay',
                            onTap: () =>
                                controller.selectPaymentMethod('ApplePay'),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Add New Card',
                            'New credit card integrations are currently set to sandbox preview mode.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primary,
                            colorText: Colors.white,
                          );
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        label: Text(
                          'add_new_card'.tr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(top: BorderSide(color: borderColor, width: 0.5)),
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
                  onPressed: () {
                    Get.to(() => const CheckoutScreen());
                  },
                  child: Text(
                    'next_btn'.tr,
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

  Widget _buildPaymentMethodTile({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.07)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black54),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
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
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
