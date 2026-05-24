import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final userName = 'Ahmed Rahman'.obs;
  final email = 'ahmed.rahman@gmail.com'.obs;
  final isPremium = true.obs;
  final joinedDate = '01/22/2025'.obs;
  final subscriptionStatus = 'Premium'.obs;
  final renewalDate = 'April 15, 2026'.obs;
  final planPrice = '\$9.99/month'.obs;
  final memberSince = 'January 15, 2025'.obs;

  final soundSettingsEnabled = true.obs;
  final tactileFeedbackEnabled = true.obs;

  final themeModeName = 'Dark'.obs;

  final selectedCategory = 'Reading'.obs;
  final feedbackDescription = ''.obs;
  final isSubmittingFeedback = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null) {
        themeModeName.value = savedTheme;
        _applyThemeMode(savedTheme);
      } else {
        themeModeName.value = 'Dark';
        _applyThemeMode('Dark');
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> updateThemeMode(String themeName) async {
    themeModeName.value = themeName;
    _applyThemeMode(themeName);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', themeName);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  void _applyThemeMode(String themeName) {
    if (themeName == 'Light') {
      Get.changeThemeMode(ThemeMode.light);
    } else if (themeName == 'Dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  Future<bool> submitFeatureRequest() async {
    if (feedbackDescription.value.trim().length < 10) {
      Get.snackbar(
        'validation_error'.tr,
        'Please enter at least 10 characters describing the feature.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmittingFeedback.value = true;

    await Future.delayed(const Duration(milliseconds: 1500));

    isSubmittingFeedback.value = false;
    feedbackDescription.value = '';

    Get.snackbar(
      'Success',
      'Thank you! Your feature request has been submitted successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF06402B),
      colorText: Colors.white,
    );
    return true;
  }
}
