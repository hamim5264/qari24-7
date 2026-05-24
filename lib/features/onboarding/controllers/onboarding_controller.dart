import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../auth/screens/auth_welcome_screen.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  final PageController pageController = PageController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  var isListening = false.obs;
  var isRecitationPerfect = false.obs;
  var isRecitationWrong = false.obs;
  var speechText = "".obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint("Speech initialization failed: $e");
    }
  }

  void startListening() async {
    if (!isListening.value) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          isListening.value = true;
          isRecitationWrong.value = false;
          _speech.listen(
            onResult: (val) {
              speechText.value = val.recognizedWords;
              String text = speechText.value.toLowerCase();

              if (text.contains("bismillah") ||
                  text.contains("bismilla") ||
                  text.contains("بسم الله") ||
                  text.contains("bismi") ||
                  text.contains("rahmani") ||
                  text.contains("rahim") ||
                  text.contains("رحيم") ||
                  text.contains("رحمن") ||
                  text.contains("بسم")) {
                isRecitationPerfect.value = true;
                isRecitationWrong.value = false;
                Future.delayed(const Duration(milliseconds: 500), () {
                  stopListening();
                });
              } else {
                isRecitationPerfect.value = false;
                if (text.isNotEmpty) {
                  isRecitationWrong.value = true;
                }
              }
            },
          );
        }
      } else {
        Get.snackbar(
          "Permission Denied",
          "Microphone permission is required for recitation.",
        );
      }
    } else {
      stopListening();
    }
  }

  void stopListening() {
    isListening.value = false;
    _speech.stop();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    isRecitationPerfect.value = false;
    isRecitationWrong.value = false;
    speechText.value = "";
    stopListening();
  }

  void next() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      completeOnboarding();
    }
  }

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Get.offAll(() => const AuthWelcomeScreen());
  }
}
