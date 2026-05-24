import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../widgets/feature_checklist_item.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  bool _yearlySelected = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'subscription_status_title'.tr,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0F5A3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '👑',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'premium_badge'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                'active_subscription'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF81C784),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'premium_active'.tr.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF81C784),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSubscriptionInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'renewal_date'.tr,
                          value: controller.renewalDate.value,
                        ),
                        const Divider(
                          height: 24,
                          thickness: 0.5,
                          color: Colors.white12,
                        ),
                        _buildSubscriptionInfoRow(
                          icon: Icons.monetization_on_rounded,
                          label: 'plan_price'.tr,
                          value: controller.planPrice.value,
                        ),
                        const Divider(
                          height: 24,
                          thickness: 0.5,
                          color: Colors.white12,
                        ),
                        _buildSubscriptionInfoRow(
                          icon: Icons.verified_user_rounded,
                          label: 'member_since'.tr.replaceAll(
                            'member since @year',
                            'Member Since',
                          ),
                          value: controller.memberSince.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'premium_features'.tr.isEmpty
                  ? 'Premium Features'
                  : 'premium_features'.tr,
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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  FeatureChecklistItem(label: 'premium_feature_1'.tr),
                  FeatureChecklistItem(label: 'premium_feature_2'.tr),
                  FeatureChecklistItem(label: 'premium_feature_3'.tr),
                  FeatureChecklistItem(label: 'premium_feature_4'.tr),
                  FeatureChecklistItem(label: 'premium_feature_5'.tr),
                  FeatureChecklistItem(label: 'premium_feature_6'.tr),
                ],
              ),
            ),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: () {
                setState(() {
                  _yearlySelected = !_yearlySelected;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _yearlySelected
                      ? AppColors.primary.withValues(
                          alpha: isDark ? 0.15 : 0.07,
                        )
                      : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _yearlySelected
                        ? AppColors.primary
                        : (isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200),
                    width: _yearlySelected ? 2 : 1,
                  ),
                ),
                child: RadioGroup<bool>(
                  groupValue: _yearlySelected,
                  onChanged: (val) {
                    setState(() {
                      _yearlySelected = val ?? false;
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'yearly_plan_label'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'MOST POPULAR',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'yearly_plan_price'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'yearly_plan_save'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Radio<bool>(
                        value: true,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _yearlySelected
                    ? () {
                        Get.snackbar(
                          'Upgrade successful',
                          'Alhamdulillah! You have successfully upgraded to the Yearly Plan.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF06402B),
                          colorText: Colors.white,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade200,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _yearlySelected ? 4 : 0,
                ),
                child: Text(
                  'upgrade_plan'.tr,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
