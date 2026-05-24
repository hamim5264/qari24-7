import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String provider;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String logoPath;
    String text;

    if (provider.toLowerCase() == 'apple') {
      logoPath = 'assets/images/apple_dark.png';
      text = 'Apple';
    } else {
      logoPath = 'assets/images/google.png';
      text = 'Google';
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoPath,
              height: 24,
              width: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  provider.toLowerCase() == 'apple'
                      ? Icons.apple
                      : Icons.g_mobiledata,
                  size: 24,
                  color: Colors.black,
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.2,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
