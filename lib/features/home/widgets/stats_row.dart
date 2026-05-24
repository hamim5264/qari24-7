import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final subtextColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;
    final valueColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              height: 146,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 20,
                        color: Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'daily_streak'.tr.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    "15 ${'days_streak'.tr.toUpperCase()}",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    'keep_it_up'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              height: 146,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.query_builder,
                        size: 20,
                        color: Color(0xFFFFD60A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'time_spent'.tr.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    "45 ${'minutes_spent'.tr}",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    'today_focus'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
