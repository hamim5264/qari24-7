import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/screens/auth_welcome_screen.dart';
import '../../notification/repositories/notification_repository.dart';
import '../../../core/services/network_service.dart';
import '../../progress/controllers/progress_controller.dart';
import '../../recitation/controllers/recitation_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

class SettingsController extends GetxController {
  final userName = 'Ahmed Rahman'.obs;
  final email = 'ahmed.rahman@gmail.com'.obs;
  final photoUrl = ''.obs;
  final isPremium = false.obs;
  final joinedDate = '01/22/2025'.obs;
  final subscriptionStatus = 'Free User'.obs;
  final renewalDate = 'April 15, 2026'.obs;
  final planPrice = '\$0.00'.obs;
  final memberSince = 'January 15, 2025'.obs;

  final soundSettingsEnabled = true.obs;
  final tactileFeedbackEnabled = true.obs;

  final themeModeName = 'Dark'.obs;
  final highlightColorName = 'Green'.obs;

  final selectedCategory = 'Reading'.obs;
  final feedbackDescription = ''.obs;
  final isSubmittingFeedback = false.obs;

  late final AuthRepository _authRepository;
  late final NetworkService _networkService;

  final newProfileImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickNewProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 250,
        maxHeight: 250,
      );
      if (pickedFile != null) {
        newProfileImage.value = File(pickedFile.path);
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
      }
    } catch (e) {
      debugPrint("SettingsController.pickNewProfileImage caught error: $e");
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void removeNewProfileImage() {
    newProfileImage.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
    _networkService = Get.find<NetworkService>();
    loadThemePreference();
    loadHighlightColor();
    _loadCachedPremiumStatus();

    // Listen to current user changes and update local observables
    ever(_authRepository.currentUser, (user) {
      if (user != null) {
        userName.value = user.username;
        email.value = user.email;
        photoUrl.value = user.photo ?? '';
      }
    });

    // Initialize values from AuthRepository
    final user = _authRepository.currentUser.value;
    if (user != null) {
      userName.value = user.username;
      email.value = user.email;
      photoUrl.value = user.photo ?? '';
    }
  }

  void _loadCachedPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isPremium.value = prefs.getBool('auth_is_premium') ?? false;
      subscriptionStatus.value = isPremium.value ? 'Premium User' : 'Free User';
    } catch (_) {}
  }

  final isUpdatingProfile = false.obs;

  Future<void> logout() async {
    try {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          if (Get.isRegistered<NotificationRepository>()) {
            await Get.find<NotificationRepository>().unregisterDevice(token);
          }
        }
      } catch (_) {}

      // Reset local settings observables
      userName.value = '';
      email.value = '';
      photoUrl.value = '';
      isPremium.value = false;
      subscriptionStatus.value = 'Free User';
      renewalDate.value = '';
      planPrice.value = '';

      // Clear shared preferences cache completely except theme and onboarding
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedTheme = prefs.getString('theme_mode');
        final onboarding = prefs.getBool('onboarding_completed');
        await prefs.clear();
        if (savedTheme != null) {
          await prefs.setString('theme_mode', savedTheme);
        }
        if (onboarding != null) {
          await prefs.setBool('onboarding_completed', onboarding);
        }
      } catch (e) {
        debugPrint("SharedPreferences clear error: $e");
      }

      await _authRepository.logout();

      // Wipe user session specific controllers so they are reconstructed clean
      try {
        if (Get.isRegistered<ProgressController>()) {
          Get.delete<ProgressController>(force: true);
        }
        if (Get.isRegistered<RecitationController>()) {
          Get.delete<RecitationController>(force: true);
        }
        if (Get.isRegistered<SubscriptionController>()) {
          Get.delete<SubscriptionController>(force: true);
        }
      } catch (e) {
        debugPrint("Error resetting session controllers on logout: $e");
      }

      Get.offAll(() => const AuthWelcomeScreen());
    } catch (e) {
      debugPrint("SettingsController.logout caught error: $e");
      Get.snackbar(
        'Logout Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> updateProfile({required String username, File? photo}) async {
    isUpdatingProfile.value = true;
    try {
      await _authRepository.updateProfile(username: username, photo: photo);
      isUpdatingProfile.value = false;
      return true;
    } catch (e) {
      isUpdatingProfile.value = false;
      debugPrint("SettingsController.updateProfile caught error: $e");
      Get.snackbar(
        'Update Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }
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

  Future<void> loadHighlightColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highlightColorName.value = prefs.getString('highlight_color') ?? 'Green';
    } catch (_) {}
  }

  Future<void> setHighlightColor(String color) async {
    try {
      highlightColorName.value = color;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('highlight_color', color);
    } catch (_) {}
  }

  Future<bool> submitFeatureRequest() async {
    final category = selectedCategory.value.toLowerCase();
    final description = feedbackDescription.value.trim();

    if (description.length < 10) {
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
    try {
      final body = {
        'select_category': category,
        'feature_description': description,
      };

      final response = await _networkService.post(
        '/settings/add-feature/',
        data: body,
      );
      isSubmittingFeedback.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        feedbackDescription.value = '';
        Get.snackbar(
          'Success',
          'Thank you! Your feature request has been submitted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF06402B),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit feature request. Try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      isSubmittingFeedback.value = false;
      debugPrint("SettingsController.submitFeatureRequest error: $e");
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> submitAppRating({
    required int rating,
    required String review,
  }) async {
    try {
      final body = {'rating': rating, 'review': review};

      final response = await _networkService.post(
        '/settings/rate-app/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Thank you for rating QARI 24/7!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF06402B),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar('Error', 'Failed to submit rating.');
        return false;
      }
    } catch (e) {
      debugPrint("SettingsController.submitAppRating error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> deleteUserAccount({required String password}) async {
    try {
      final body = {'password': password};

      final response = await _networkService.post(
        '/settings/delete-account/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _authRepository.clearSession();
        Get.offAll(() => const AuthWelcomeScreen());
        Get.snackbar(
          'Account Deleted',
          'Your account has been deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return true;
      } else {
        final errorMsg = response.data['password']?[0] ?? 'Incorrect password.';
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("SettingsController.deleteUserAccount error: $e");
      Get.snackbar(
        'Error',
        'Incorrect password or connection issue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Color getHighlightColor(bool isDark) {
    switch (highlightColorName.value.toLowerCase()) {
      case 'blue':
        return isDark ? const Color(0x4460A5FA) : const Color(0x332563EB);
      case 'amber':
      case 'orange':
      case 'yellow':
        return isDark ? const Color(0x44FBBF24) : const Color(0x33D97706);
      case 'purple':
        return isDark ? const Color(0x44C084FC) : const Color(0x337C3AED);
      case 'green':
      default:
        return isDark ? const Color(0x444ADE80) : const Color(0x3316A34A);
    }
  }
}
