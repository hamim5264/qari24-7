import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import 'home_screen.dart';
import '../../../core/services/localization_service.dart';
import '../../library/screens/library_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    const activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: backgroundColor,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: inactiveColor),
              selectedIcon: const Icon(Icons.home, color: activeColor),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.local_library_outlined, color: inactiveColor),
              selectedIcon: const Icon(Icons.local_library, color: activeColor),
              label: 'nav_library'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: inactiveColor),
              selectedIcon: const Icon(Icons.bar_chart, color: activeColor),
              label: 'nav_progress'.tr,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: inactiveColor),
              selectedIcon: const Icon(Icons.settings, color: activeColor),
              label: 'nav_settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryPlaceholder extends StatelessWidget {
  const LibraryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('nav_library'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_library,
                  size: 64,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'nav_library'.tr,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore the full library of Surahs and recitation guides coming soon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressPlaceholder extends StatelessWidget {
  const ProgressPlaceholder({super.key});

  @override
  Widget build(BuildContext buildContext) {
    final isDark = Theme.of(buildContext).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('nav_progress'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'nav_progress'.tr,
                style: Theme.of(
                  buildContext,
                ).textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Interactive statistics, badges, and progress reports coming soon.',
                textAlign: TextAlign.center,
                style: Theme.of(buildContext).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext buildContext) {
    final isDark = Theme.of(buildContext).brightness == Brightness.dark;
    final localizationService = Get.find<LocalizationService>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('nav_settings'.tr),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Text(
                      'H',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'user_fullname'.tr,
                        style: Theme.of(buildContext).textTheme.bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'hamim@example.com',
                        style: Theme.of(buildContext).textTheme.bodyMedium
                            ?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'LANGUAGE SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: LocalizationService.langs.map((lang) {
                  return Obx(() {
                    final isSelected =
                        localizationService.currentLanguage.value == lang;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            lang,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            localizationService.changeLocale(lang);
                            Get.snackbar(
                              'Language',
                              'Language changed to $lang',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        if (lang != LocalizationService.langs.last)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                          ),
                      ],
                    );
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
