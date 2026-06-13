import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/auth_repository.dart';
import '../../home/screens/main_navigation_screen.dart';
import '../screens/check_email_screen.dart';

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
        imageQuality: 75,
        maxWidth: 250,
        maxHeight: 250,
      );
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        Get.snackbar(
          'Success',
          'Profile picture selected!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF06402B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  Future<void> login() async {
    final emailVal = emailController.text.trim();
    final passwordVal = passwordController.text;

    if (emailVal.isEmpty || passwordVal.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    isLoading.value = true;
    try {
      final authRepository = Get.find<AuthRepository>();
      await authRepository.login(email: emailVal, password: passwordVal);
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF06402B),
        colorText: Colors.white,
      );

      Get.offAll(() => const MainNavigationScreen());
    } catch (e) {
      isLoading.value = false;
      debugPrint("AuthController.login caught error: $e");
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signUp() async {
    final nameVal = nameController.text.trim();
    final emailVal = emailController.text.trim();
    final passwordVal = passwordController.text;
    final confirmPasswordVal = confirmPasswordController.text;

    if (nameVal.isEmpty || emailVal.isEmpty || passwordVal.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    if (passwordVal != confirmPasswordVal) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final authRepository = Get.find<AuthRepository>();
      await authRepository.register(
        username: nameVal,
        email: emailVal,
        password: passwordVal,
        confirmPassword: confirmPasswordVal,
        photo: profileImage.value,
      );
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF06402B),
        colorText: Colors.white,
      );

      Get.offAll(() => const MainNavigationScreen());
    } catch (e) {
      isLoading.value = false;
      debugPrint("AuthController.signUp caught error: $e");
      Get.snackbar(
        'Registration Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendForgotPasswordEmail() async {
    final emailVal = emailController.text.trim();
    if (emailVal.isEmpty) {
      Get.snackbar('Error', 'Please enter your email address');
      return;
    }

    isLoading.value = true;
    try {
      final authRepository = Get.find<AuthRepository>();
      await authRepository.forgotPassword(email: emailVal);
      isLoading.value = false;

      startResendTimer();
      Get.to(() => const CheckEmailScreen());
    } catch (e) {
      isLoading.value = false;
      debugPrint("AuthController.sendForgotPasswordEmail caught error: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> googleSignIn() async {
    isLoading.value = true;
    try {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw "Could not retrieve Google ID Token.";
      }

      final authRepo = Get.find<AuthRepository>();
      await authRepo.googleLogin(
        googleId: googleUser.id,
        email: googleUser.email,
        idToken: idToken,
        name: googleUser.displayName ?? '',
        photoUrl: googleUser.photoUrl ?? '',
      );

      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Google Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF06402B),
        colorText: Colors.white,
      );
      Get.offAll(() => const MainNavigationScreen());
    } catch (e) {
      isLoading.value = false;
      debugPrint("AuthController.googleSignIn caught error: $e");
      Get.snackbar(
        'Google Sign In Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    // Do not dispose text controllers here to avoid GetX route transition race conditions.
    // They will be garbage collected safely with the controller instance.
    super.onClose();
  }
}
