import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/or_divider.dart';
import '../widgets/profile_picture_uploader.dart';
import '../widgets/social_login_button.dart';
import 'auth_welcome_screen.dart';
import 'login_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

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
              const SizedBox(height: 20),
              // Header
              Text(
                'create_account'.tr,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'create_account_subtitle'.tr,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              const ProfilePictureUploader(),
              const SizedBox(height: 28),

              CustomTextField(
                label: 'name'.tr,
                hint: 'John Doe',
                controller: controller.nameController,
                prefixIcon: Icons.person_outline,
                labelAbove: false,
              ),
              const SizedBox(height: 16),
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
              Obx(
                () => CustomTextField(
                  label: 'confirm_password'.tr,
                  hint: '••••••••',
                  controller: controller.confirmPasswordController,
                  isPassword: true,
                  isVisible: controller.isConfirmPasswordVisible.value,
                  onToggleVisibility:
                      controller.toggleConfirmPasswordVisibility,
                  prefixIcon: Icons.lock_clock_outlined,
                  labelAbove: false,
                ),
              ),
              const SizedBox(height: 32),

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
                        text: 'create_account'.tr,
                        onPressed: controller.signUp,
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
                    'already_have_account'.tr,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Get.off(() => const LoginScreen()),
                    child: Text(
                      'login'.tr,
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
