import 'dart:math' as math;
import 'package:flutter/material.dart';

class AyahOrnamentPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  AyahOrnamentPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 3;

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, outerRadius, outerPaint);

    canvas.drawCircle(center, outerRadius - 2.5, innerPaint);

    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = isDark ? Colors.black54 : Colors.white60
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    const numPetals = 8;
    const petalRadius = 1.8;

    for (int i = 0; i < numPetals; i++) {
      final angle = i * (2 * math.pi / numPetals);
      final x = center.dx + outerRadius * math.cos(angle);
      final y = center.dy + outerRadius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), petalRadius, petalPaint);
      canvas.drawCircle(Offset(x, y), petalRadius, outlinePaint);
    }

    final notchPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, outerRadius - 4.5, notchPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuranAyahNumberOrnament extends StatelessWidget {
  final int number;
  final double size;

  const QuranAyahNumberOrnament({
    super.key,
    required this.number,
    this.size = 30,
  });

  String _toArabicIndic(int number) {
    const Map<String, String> digits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return number
        .toString()
        .split('')
        .map((char) => digits[char] ?? char)
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldColor = Color(0xFFE2B93C);

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomPaint(
        painter: AyahOrnamentPainter(color: goldColor, isDark: isDark),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              _toArabicIndic(number),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
