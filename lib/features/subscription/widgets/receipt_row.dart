import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final Color? valueColor;
  final Widget? trailingWidget;

  const ReceiptRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
    this.valueColor,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final defaultValColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (trailingWidget != null) ...[
                  trailingWidget!,
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
                      color: valueColor ?? defaultValColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
