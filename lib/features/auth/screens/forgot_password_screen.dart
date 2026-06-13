import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
              Get.offAll(() => const LoginScreen());
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
              const SizedBox(height: 30),

              Text(
                'forgot_password_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'forgot_password_desc'.tr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                label: 'email_address'.tr,
                hint: 'name@example.com',
                controller: controller.emailController,
                prefixIcon: Icons.email_outlined,
                labelAbove: false,
              ),
              const SizedBox(height: 40),

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
                        text: 'continue_btn'.tr,
                        onPressed: controller.sendForgotPasswordEmail,
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
