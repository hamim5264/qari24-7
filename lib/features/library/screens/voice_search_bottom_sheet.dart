import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/library_controller.dart';
import '../../../core/constants/app_colors.dart';

class VoiceSearchBottomSheet extends StatefulWidget {
  final LibraryController controller;

  const VoiceSearchBottomSheet({super.key, required this.controller});

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: MainVoiceSearchContent(
            controller: widget.controller,
            scaleAnimation: _scaleAnimation,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
        ),
      ),
    );
  }
}

class MainVoiceSearchContent extends StatelessWidget {
  final LibraryController controller;
  final Animation<double> scaleAnimation;
  final Color textColor;
  final Color subtitleColor;

  const MainVoiceSearchContent({
    super.key,
    required this.controller,
    required this.scaleAnimation,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title and Status
        Obx(() {
          final isListening = controller.isListening.value;
          return Text(
            isListening ? "Listening..." : "Click to Speak",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          "Say the name of the book or topic you want to find",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 20),

        // Pulsating Microphone Button
        Center(
          child: Obx(() {
            final isListening = controller.isListening.value;
            return GestureDetector(
              onTap: () {
                if (isListening) {
                  controller.stopListening();
                } else {
                  controller.startListening();
                }
              },
              child: AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  final scale = isListening ? scaleAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                          child: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.white : Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Real-time voice transcript box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          constraints: const BoxConstraints(minHeight: 60, maxHeight: 90),
          child: SingleChildScrollView(
            child: Obx(() {
              final text = controller.voiceSearchText.value;
              return Text(
                text.isEmpty ? "Speak to see transcription..." : text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: text.isEmpty ? FontWeight.normal : FontWeight.w500,
                  color: text.isEmpty ? subtitleColor : textColor,
                  fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Done / Close button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Done",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
