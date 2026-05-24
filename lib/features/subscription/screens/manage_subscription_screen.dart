import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/plan_card.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SubscriptionController subController = Get.find<SubscriptionController>();
    final SettingsController settingsController = Get.find<SettingsController>();

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'manage_sub_title'.tr,
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
        child: Obx(() {
          final isPremium = settingsController.isPremium.value;
          final currentPlan = settingsController.subscriptionStatus.value;
          final planPrice = settingsController.planPrice.value;
          final renewalDate = settingsController.renewalDate.value;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [const Color(0xFF0F4E36), const Color(0xFF042417)]
                          : [Colors.grey.shade800, Colors.grey.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPremium ? 'QARI 24/7 PREMIUM' : 'QARI 24/7 FREE',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: AppColors.secondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPremium ? AppColors.success.withValues(alpha: 0.2) : Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isPremium ? 'premium_active'.tr.toUpperCase() : 'FREE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isPremium ? Colors.green.shade300 : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isPremium ? currentPlan : 'Free Tier Account',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPremium
                            ? 'next_billing'.tr.replaceAll('@date', renewalDate)
                            : 'Upgrade today to access mistake detection & rules',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.white12, thickness: 0.5),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'plan_price'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            planPrice,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (isPremium) ...[
                  Text(
                    'compare_features'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  PlanCard(
                    title: 'yearly_plan_label'.tr,
                    price: 'yearly_plan_price'.tr,
                    subtitle: currentPlan.contains('Yearly') ? 'current_plan'.tr : 'upgrade_plan'.tr,
                    isSelected: currentPlan.contains('Yearly'),
                    onTap: () {
                      if (!currentPlan.contains('Yearly')) {
                        _showChangePlanConfirmation(context, 'Yearly');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  PlanCard(
                    title: 'monthly_plan'.tr,
                    price: '\$20.00/month',
                    subtitle: currentPlan.contains('Monthly') ? 'current_plan'.tr : null,
                    isSelected: currentPlan.contains('Monthly'),
                    onTap: () {
                      if (!currentPlan.contains('Monthly')) {
                        _showChangePlanConfirmation(context, 'Monthly');
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'notification_reminder'.tr,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'notification_reminder_desc'.tr,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: subController.notifyReminder.value,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            subController.notifyReminder.value = val;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel_outlined, size: 20),
                      label: Text(
                        'cancel_subscription'.tr,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.star_border_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Subscription',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              'Upgrade Now',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showChangePlanConfirmation(BuildContext context, String newPlanType) {
    final SettingsController settingsController = Get.find<SettingsController>();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Plan?',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to switch your active subscription plan to $newPlanType?',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              settingsController.subscriptionStatus.value = newPlanType == 'Yearly' ? 'Premium Yearly' : 'Premium Monthly';
              settingsController.planPrice.value = newPlanType == 'Yearly' ? '\$200/year' : '\$20.00/month';
              settingsController.renewalDate.value = newPlanType == 'Yearly' ? 'May 24, 2027' : 'June 24, 2026';
              Get.back();
              Get.snackbar(
                'Plan Updated',
                'Your plan has been updated successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
            child: const Text('Confirm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final SubscriptionController subController = Get.find<SubscriptionController>();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'Cancel Subscription?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel your Premium subscription? You will lose access to all premium features including mistake detection, verse peeking, and mistake playback at the end of the current billing cycle.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Keep Premium',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              
              subController.cancelPremiumSubscription();
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
