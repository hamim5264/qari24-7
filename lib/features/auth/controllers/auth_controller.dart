import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../home/screens/main_navigation_screen.dart';

class AuthController extends GetxController {
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var rememberMe = false.obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final Rxn<File> profileImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  Timer? _resendTimer;
  var timerSeconds = 120.obs;
  var canResend = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  void startResendTimer() {
    _resendTimer?.cancel();
    timerSeconds.value = 120;
    canResend.value = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        Get.snackbar(
          'Success',
          'Profile picture updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      isLoading.value = false;
      Get.snackbar('Login', 'Logged in as ${emailController.text}');
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  void signUp() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      isLoading.value = false;
      Get.snackbar('Sign Up', 'Creating account for ${nameController.text}');
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();

    super.onClose();
  }
}
