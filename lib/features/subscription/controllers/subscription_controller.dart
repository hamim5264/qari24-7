import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../../core/services/network_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 'Yearly'.obs;

  final selectedPaymentMethod = 'MasterCard'.obs;

  final cardNumber = ''.obs;
  final cardOwner = ''.obs;
  final cardExpiry = ''.obs;
  final cardCvv = ''.obs;
  final emailAddress = ''.obs;

  final notifyReminder = true.obs;

  final isProcessingPayment = false.obs;

  late final NetworkService _networkService;
  final rxHasActiveSubscription = false.obs;
  final rxPaymentHistory = <Map<String, dynamic>>[].obs;
  final rxPaymentError = ''.obs;
  final rxPlans = <Map<String, dynamic>>[].obs;

  DateTime? _lastSuccessfulPaymentTime;

  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<NetworkService>();
    _loadCachedSubscriptionState();
    fetchSubscriptionPlans().then((_) {
      fetchSubscriptionDetails().then((_) {
        // If backend says not active but we had cached premium, try restoring from Stripe
        if (!rxHasActiveSubscription.value) {
          _tryAutoRestore();
        }
      });
    });
    fetchPaymentHistory();
  }

  /// Load cached subscription state from SharedPreferences
  Future<void> _loadCachedSubscriptionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPremium = prefs.getBool('auth_is_premium') ?? false;
      if (cachedPremium) {
        rxHasActiveSubscription.value = true;
        try {
          final settingsController = Get.find<SettingsController>();
          settingsController.isPremium.value = true;
          final cachedPlan = prefs.getString('subscription_plan') ?? 'monthly';
          settingsController.subscriptionStatus.value = cachedPlan == 'yearly'
              ? 'Premium Yearly'
              : 'Premium Monthly';
          final cachedPrice = prefs.getString('subscription_price') ?? '';
          if (cachedPrice.isNotEmpty) {
            settingsController.planPrice.value = cachedPrice;
          }
          final cachedRenewal = prefs.getString('subscription_renewal') ?? '';
          if (cachedRenewal.isNotEmpty) {
            settingsController.renewalDate.value = cachedRenewal;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Attempt to restore subscription from Stripe if backend doesn't have it
  Future<void> _tryAutoRestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasPremium = prefs.getBool('auth_is_premium') ?? false;
      if (!wasPremium) return;
      
      debugPrint('SubscriptionController: Attempting auto-restore from Stripe...');
      final restored = await restoreSubscription();
      if (restored) {
        debugPrint('SubscriptionController: Auto-restore successful!');
      } else {
        debugPrint('SubscriptionController: Auto-restore failed. User may no longer have active subscription.');
        // Don't reset to free immediately, let fetchSubscriptionDetails handle it
      }
    } catch (e) {
      debugPrint('SubscriptionController: Auto-restore error: $e');
    }
  }

  void changePlan(String planType) {
    selectedPlan.value = planType;
  }

  /// Eagerly refresh and verify premium status.
  /// If already premium in memory, does a silent background fetch and returns true immediately.
  /// If free, shows a blocking loader while checking if a purchase was recently made.
  Future<bool> refreshAndVerifyPremium({bool showLoading = true}) async {
    final settingsController = Get.find<SettingsController>();
    if (settingsController.isPremium.value) {
      // Already premium, refresh in background silently to not interrupt UX
      fetchSubscriptionDetails();
      return true;
    }

    if (showLoading) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4E36)),
          ),
        ),
        barrierDismissible: false,
      );
    }

    try {
      await fetchSubscriptionDetails().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint("refreshAndVerifyPremium error: $e");
    } finally {
      if (showLoading) {
        Get.back();
      }
    }
    return settingsController.isPremium.value;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  double get activeAmount {
    if (rxPlans.isEmpty) {
      return selectedPlan.value == 'Yearly' ? 200.0 : 20.0;
    }
    final plan = rxPlans.firstWhere(
      (p) => p['interval'].toString().toLowerCase() == selectedPlan.value.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );
    if (plan.isEmpty) {
      return selectedPlan.value == 'Yearly' ? 200.0 : 20.0;
    }
    return double.tryParse(plan['price'].toString()) ?? (selectedPlan.value == 'Yearly' ? 200.0 : 20.0);
  }

  String get monthlyPriceText {
    if (rxPlans.isEmpty) return '\$20.00/month';
    final plan = rxPlans.firstWhere(
      (p) => p['interval'].toString().toLowerCase() == 'monthly',
      orElse: () => <String, dynamic>{},
    );
    if (plan.isEmpty) return '\$20.00/month';
    return '\$${double.tryParse(plan['price'].toString())?.toStringAsFixed(2) ?? '20.00'}/month';
  }

  String get yearlyPriceText {
    if (rxPlans.isEmpty) return '\$200.00/year';
    final plan = rxPlans.firstWhere(
      (p) => p['interval'].toString().toLowerCase() == 'yearly',
      orElse: () => <String, dynamic>{},
    );
    if (plan.isEmpty) return '\$200.00/year';
    return '\$${double.tryParse(plan['price'].toString())?.toStringAsFixed(2) ?? '200.00'}/year';
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      final response = await _networkService.get(
        '/subscriptions/plans/',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> plansData = response.data ?? [];
        rxPlans.assignAll(plansData.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("SubscriptionController.fetchSubscriptionPlans error: $e");
    }
  }

  Future<void> fetchSubscriptionDetails({int retryCount = 0}) async {
    try {
      final response = await _networkService.get(
        '/subscriptions/my-subscription/',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final hasActiveSub = data['has_active_subscription'] as bool? ?? false;
        
        final recentlyPaid = _lastSuccessfulPaymentTime != null &&
            DateTime.now().difference(_lastSuccessfulPaymentTime!).inSeconds < 25;

        if (recentlyPaid && !hasActiveSub && retryCount < 6) {
          debugPrint("Subscription details still not updated on backend. Retrying in 2 seconds... (Attempt ${retryCount + 1})");
          rxHasActiveSubscription.value = true;
          try {
            final settingsController = Get.find<SettingsController>();
            settingsController.isPremium.value = true;
            settingsController.subscriptionStatus.value =
                selectedPlan.value == 'Yearly'
                ? 'Premium Yearly'
                : 'Premium Monthly';
             settingsController.planPrice.value = selectedPlan.value == 'Yearly'
                 ? yearlyPriceText
                 : monthlyPriceText;
          } catch (_) {}
          
          Future.delayed(const Duration(seconds: 2), () {
            fetchSubscriptionDetails(retryCount: retryCount + 1);
          });
          return;
        }

        rxHasActiveSubscription.value = hasActiveSub || recentlyPaid;

        final subData = data['subscription'];

        try {
          final settingsController = Get.find<SettingsController>();
          final isPrem = hasActiveSub || recentlyPaid;
          settingsController.isPremium.value = isPrem;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('auth_is_premium', isPrem);
          if ((hasActiveSub || recentlyPaid) && subData != null) {
            final plan = subData['plan'] as String? ?? selectedPlan.value.toLowerCase();
            final autoRenew = subData['auto_renew'] as bool? ?? true;
            notifyReminder.value = autoRenew;

             final statusText = plan == 'yearly' || plan == 'Yearly'
                 ? 'Premium Yearly'
                 : 'Premium Monthly';
             settingsController.subscriptionStatus.value = statusText;
             final priceText = plan == 'yearly' || plan == 'Yearly'
                 ? yearlyPriceText
                 : monthlyPriceText;
             settingsController.planPrice.value = priceText;

            // Persist subscription details to SharedPreferences for restart survival
            await prefs.setString('subscription_plan', plan);
            await prefs.setString('subscription_price', priceText);

            final expiresAtStr = subData['expires_at'] as String? ?? '';
            if (expiresAtStr.isNotEmpty) {
              try {
                final date = DateTime.parse(expiresAtStr);
                final renewalStr = "${date.day}/${date.month}/${date.year}";
                settingsController.renewalDate.value = renewalStr;
                await prefs.setString('subscription_renewal', renewalStr);
              } catch (_) {
                settingsController.renewalDate.value = expiresAtStr;
                await prefs.setString('subscription_renewal', expiresAtStr);
              }
            } else {
              final fallback = selectedPlan.value == 'Yearly'
                  ? 'May 24, 2027'
                  : 'June 24, 2026';
              settingsController.renewalDate.value = fallback;
              await prefs.setString('subscription_renewal', fallback);
            }
          } else if (recentlyPaid) {
            settingsController.subscriptionStatus.value = selectedPlan.value == 'Yearly'
                ? 'Premium Yearly'
                : 'Premium Monthly';
            settingsController.planPrice.value = selectedPlan.value == 'Yearly'
                ? yearlyPriceText
                : monthlyPriceText;
            settingsController.renewalDate.value = selectedPlan.value == 'Yearly'
                ? 'May 24, 2027'
                : 'June 24, 2026';
          } else {
            settingsController.subscriptionStatus.value = 'None';
            // Clear cached subscription details
            await prefs.remove('subscription_plan');
            await prefs.remove('subscription_price');
            await prefs.remove('subscription_renewal');
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("SubscriptionController.fetchSubscriptionDetails error: $e");
    }
  }

  Future<void> fetchPaymentHistory({int retryCount = 0}) async {
    try {
      final response = await _networkService.get(
        '/subscriptions/payment-history/',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> historyData = response.data ?? [];
        
        final recentlyPaid = _lastSuccessfulPaymentTime != null &&
            DateTime.now().difference(_lastSuccessfulPaymentTime!).inSeconds < 25;

        if (recentlyPaid && historyData.isEmpty && retryCount < 6) {
          debugPrint("Payment history empty. Retrying in 2 seconds... (Attempt ${retryCount + 1})");
          Future.delayed(const Duration(seconds: 2), () {
            fetchPaymentHistory(retryCount: retryCount + 1);
          });
          return;
        }

        rxPaymentHistory.assignAll(historyData.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint("SubscriptionController.fetchPaymentHistory error: $e");
    }
  }

  Future<bool> processPayment({required bool simulateFailure}) async {
    isProcessingPayment.value = true;
    try {
      if (simulateFailure) {
        await Future.delayed(const Duration(seconds: 1));
        isProcessingPayment.value = false;
        Get.snackbar(
          'payment_unsuccessful'.tr,
          'insufficient_funds'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return false;
      }

      final planStr = selectedPlan.value.toLowerCase();
      final body = {'plan': planStr};

      dynamic response;
      try {
        response = await _networkService.post(
          '/subscriptions/create-subscription/',
          data: body,
        );
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 400) {
          final errorData = e.response?.data?.toString() ?? '';
          if (errorData.contains('already') || errorData.contains('active') || errorData.contains('subscription')) {
            debugPrint("User already has active subscription. Auto-cancelling first to allow re-subscribe...");
            try {
              await _networkService.post('/subscriptions/cancel-subscription/');
            } catch (cancelErr) {
              debugPrint("Auto-cancel failed: $cancelErr");
            }
            // Retry
            response = await _networkService.post(
              '/subscriptions/create-subscription/',
              data: body,
            );
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final clientSecret = data['client_secret'] as String? ?? '';
        final publishableKey = data['publishable_key'] as String? ?? '';
        final subscriptionId = data['subscription_id'] as String? ?? '';

        debugPrint("SubscriptionController.processPayment: Received Client Secret = $clientSecret, Sub ID = $subscriptionId");

        if (clientSecret.isNotEmpty) {
          debugPrint("SubscriptionController.processPayment: Initializing native Stripe Payment Sheet...");
          Stripe.publishableKey = publishableKey;
          await Stripe.instance.applySettings();

          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Qari 24/7',
              style: ThemeMode.dark,
              appearance: const PaymentSheetAppearance(
                colors: PaymentSheetAppearanceColors(
                  background: Color(0xFF161616),
                  primary: Color(0xFF0F4E36),
                  componentBackground: Color(0xFF1E1E1E),
                  componentBorder: Color(0xFF2E2E2E),
                  primaryText: Colors.white,
                  secondaryText: Colors.grey,
                  placeholderText: Colors.grey,
                ),
                shapes: PaymentSheetShape(
                  borderRadius: 16,
                  borderWidth: 1.0,
                ),
              ),
            ),
          );

          debugPrint("SubscriptionController.processPayment: Presenting native Stripe Payment Sheet...");
          await Stripe.instance.presentPaymentSheet();
          debugPrint("SubscriptionController.processPayment: Native Stripe Payment Sheet completed successfully.");

          if (subscriptionId.isNotEmpty) {
            debugPrint("SubscriptionController.processPayment: Confirming payment on backend for subscription ID: $subscriptionId");
            try {
              final confirmResponse = await _networkService.post(
                '/subscriptions/confirm-payment/',
                data: {'subscription_id': subscriptionId},
              );
              debugPrint("SubscriptionController.processPayment: Backend confirm response: ${confirmResponse.data}");
            } catch (confirmErr) {
              debugPrint("SubscriptionController.processPayment backend confirm error: $confirmErr");
              // Even if confirm fails, payment was successful on Stripe side
              // The subscription will be activated via webhook or next fetch
            }
          }
        }
      }

      _lastSuccessfulPaymentTime = DateTime.now();
      rxHasActiveSubscription.value = true;
      isProcessingPayment.value = false;

      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.isPremium.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('auth_is_premium', true);
        final planLower = selectedPlan.value.toLowerCase();
        settingsController.subscriptionStatus.value =
            selectedPlan.value == 'Yearly'
            ? 'Premium Yearly'
            : 'Premium Monthly';
         final priceText = selectedPlan.value == 'Yearly'
             ? yearlyPriceText
             : monthlyPriceText;
         settingsController.planPrice.value = priceText;
        final renewalText = selectedPlan.value == 'Yearly'
            ? 'May 24, 2027'
            : 'June 24, 2026';
        settingsController.renewalDate.value = renewalText;
        // Persist to SharedPreferences for restart survival
        await prefs.setString('subscription_plan', planLower);
        await prefs.setString('subscription_price', priceText);
        await prefs.setString('subscription_renewal', renewalText);
      } catch (e) {
        debugPrint('SettingsController error: $e');
      }

      Get.snackbar(
        'payment_successful'.tr,
        'Enjoy your premium access!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF06402B),
        colorText: Colors.white,
      );

      // Trigger immediate local fetch, which will trigger polling internally since recentlyPaid is true
      fetchSubscriptionDetails();
      fetchPaymentHistory();

      return true;
    } catch (e) {
      isProcessingPayment.value = false;
      debugPrint("SubscriptionController.processPayment error: $e");

      String errorMsg = e.toString();
      if (e is DioException) {
        debugPrint("SubscriptionController.processPayment failure response: ${e.response?.data}");
        if (e.response != null && e.response!.data != null) {
          final data = e.response!.data;
          if (data is Map) {
            if (data['error'] is Map) {
              errorMsg = data['error']['message']?.toString() ?? data['error'].toString();
            } else {
              errorMsg = data['detail']?.toString() ??
                  data['error']?.toString() ??
                  data['message']?.toString() ??
                  e.response!.statusMessage ??
                  e.message ??
                  e.toString();
            }
          } else {
            errorMsg = e.response!.statusMessage ?? e.message ?? e.toString();
          }
        } else {
          errorMsg = e.message ?? e.toString();
        }
      }
      rxPaymentError.value = errorMsg;

      Get.snackbar(
        'Payment Failed',
        'Payment confirmation failed: $errorMsg',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> restoreSubscription() async {
    isProcessingPayment.value = true;
    try {
      final response = await _networkService.post(
        '/subscriptions/restore-subscription/',
      );
      isProcessingPayment.value = false;
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSubscriptionDetails();
        return true;
      }
      return false;
    } catch (e) {
      isProcessingPayment.value = false;
      debugPrint("SubscriptionController.restoreSubscription error: $e");
      return false;
    }
  }

  Future<void> toggleAutoRenewal(bool value) async {
    try {
      final body = {'auto_renew': value};
      final response = await _networkService.post(
        '/subscriptions/toggle-auto-renewal/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyReminder.value = value;
        Get.snackbar(
          'Success',
          'Auto-renewal ${value ? 'enabled' : 'disabled'} successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF06402B),
          colorText: Colors.white,
        );
        fetchSubscriptionDetails();
      } else {
        Get.snackbar('Error', 'Failed to toggle auto-renewal.');
      }
    } catch (e) {
      debugPrint("SubscriptionController.toggleAutoRenewal error: $e");
      notifyReminder.value = value;
    }
  }

  Future<void> cancelPremiumSubscription() async {
    try {
      final response = await _networkService.post(
        '/subscriptions/cancel-subscription/',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final settingsController = Get.find<SettingsController>();
          settingsController.isPremium.value = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('auth_is_premium', false);
          await prefs.remove('subscription_plan');
          await prefs.remove('subscription_price');
          await prefs.remove('subscription_renewal');
          settingsController.subscriptionStatus.value = 'None';
          settingsController.planPrice.value = '\$0.00';
        } catch (_) {}

        Get.snackbar(
          'Subscription Cancelled',
          'Your premium subscription will cancel at the end of the billing period.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade900,
          colorText: Colors.white,
        );
        fetchSubscriptionDetails();
      } else {
        Get.snackbar('Error', 'Failed to cancel subscription.');
      }
    } catch (e) {
      debugPrint("SubscriptionController.cancelPremiumSubscription error: $e");
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.isPremium.value = false;
        settingsController.subscriptionStatus.value = 'None';
      } catch (_) {}
    }
  }
}
