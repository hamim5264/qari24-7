import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../settings/controllers/settings_controller.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 'Yearly'.obs;

  final selectedPaymentMethod = 'MasterCard'.obs;

  final cardNumber = '4000 1234 5678 9012'.obs;
  final cardOwner = 'MD. RAFIUL ISLAM'.obs;
  final cardExpiry = '12/28'.obs;
  final cardCvv = '123'.obs;
  final emailAddress = 'rafiul.islam@gmail.com'.obs;

  final notifyReminder = true.obs;

  final isProcessingPayment = false.obs;

  void changePlan(String planType) {
    selectedPlan.value = planType;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  double get activeAmount => selectedPlan.value == 'Yearly' ? 200.0 : 20.0;

  Future<bool> processPayment({required bool simulateFailure}) async {
    isProcessingPayment.value = true;

    await Future.delayed(const Duration(milliseconds: 2000));

    isProcessingPayment.value = false;

    if (simulateFailure) {
      Get.snackbar(
        'payment_unsuccessful'.tr,
        'insufficient_funds'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.isPremium.value = true;
      settingsController.subscriptionStatus.value =
          selectedPlan.value == 'Yearly' ? 'Premium Yearly' : 'Premium Monthly';
      settingsController.planPrice.value = selectedPlan.value == 'Yearly'
          ? '\$200/year'
          : '\$20.00/month';
      settingsController.renewalDate.value = selectedPlan.value == 'Yearly'
          ? 'May 24, 2027'
          : 'June 24, 2026';
    } catch (e) {
      debugPrint('SettingsController not active yet: $e');
    }

    Get.snackbar(
      'payment_successful'.tr,
      'Enjoy your premium access!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF06402B),
      colorText: Colors.white,
    );
    return true;
  }

  void cancelPremiumSubscription() {
    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.isPremium.value = false;
      settingsController.subscriptionStatus.value = 'None';
      settingsController.planPrice.value = '\$0.00';
    } catch (e) {
      debugPrint('SettingsController error: $e');
    }

    Get.snackbar(
      'Subscription Cancelled',
      'Your premium subscription has been successfully cancelled.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade900,
      colorText: Colors.white,
    );
  }
}
