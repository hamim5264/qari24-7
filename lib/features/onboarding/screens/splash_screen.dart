import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/auth_welcome_screen.dart';
import 'welcome_screen.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../home/screens/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final authRepo = Get.find<AuthRepository>();
      await authRepo.loadSession();

      if (authRepo.isLogged.value) {
        Get.off(() => const MainNavigationScreen());
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final bool completed = prefs.getBool('onboarding_completed') ?? false;
      if (completed) {
        Get.off(() => const AuthWelcomeScreen());
      } else {
        Get.off(() => const WelcomeScreen());
      }
    } catch (e) {
      Get.off(() => const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/qari_logo.png',
              width: 200,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.menu_book,
                size: 100,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
