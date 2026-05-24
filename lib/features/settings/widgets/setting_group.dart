import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingGroup extends StatelessWidget {
  final String? title;
  final List<Widget> tiles;

  const SettingGroup({super.key, this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 4.0),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(tiles.length, (index) {
              return Column(
                children: [
                  tiles[index],
                  if (index < tiles.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
