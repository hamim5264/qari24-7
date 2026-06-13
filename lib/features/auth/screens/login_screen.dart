import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_login_button.dart';
import 'auth_welcome_screen.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAll(() => const AuthWelcomeScreen());
            }
          },
        ),
        title: Text(
          'QARI 24/7',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/auth_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'log_in_header'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'log_in_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 36),

              CustomTextField(
                label: 'email_address'.tr,
                hint: 'name@example.com',
                controller: controller.emailController,
                prefixIcon: Icons.email_outlined,
                labelAbove: false,
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomTextField(
                  label: 'password'.tr,
                  hint: '••••••••',
                  controller: controller.passwordController,
                  isPassword: true,
                  isVisible: controller.isPasswordVisible.value,
                  onToggleVisibility: controller.togglePasswordVisibility,
                  prefixIcon: Icons.lock_outline,
                  labelAbove: false,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Obx(
                          () => Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: controller.toggleRememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'remember_me'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const ForgotPasswordScreen()),
                    child: Text(
                      'forgot_password_question'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    : CustomButton(
                        text: 'login'.tr,
                        onPressed: controller.login,
                      ),
              ),
              const SizedBox(height: 32),

              const OrDivider(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SocialLoginButton(
                      provider: 'apple',
                      onPressed: () {
                        Get.snackbar(
                          'Apple Sign In',
                          'Simulating Apple integration',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SocialLoginButton(
                      provider: 'google',
                      onPressed: controller.googleSignIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account'.tr,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Get.off(() => const CreateAccountScreen()),
                    child: Text(
                      'create_account'.tr,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
