import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/language_bottom_sheet.dart';
import 'onboarding_intro_screen.dart';
import '../../../core/services/localization_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    final localizationService = Get.find<LocalizationService>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background_image.jpg', fit: BoxFit.cover),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Obx(
              () => TextButton.icon(
                onPressed: () {
                  Get.bottomSheet(const LanguageBottomSheet());
                },
                icon: const Icon(Icons.language, color: Colors.white, size: 20),
                label: Text(
                  localizationService.currentLanguage.value,
                  style: const TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                localizationService.currentLanguage.value;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      'welcome'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/qari_logo.png',
                      width: 250,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "quran_recitation_subtitle".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      text: 'get_started'.tr,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      textColor: Colors.white,
                      onPressed: () {
                        Get.to(() => const OnboardingIntroScreen());
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
