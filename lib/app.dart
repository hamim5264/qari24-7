import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/services/localization_service.dart';
import 'features/onboarding/screens/splash_screen.dart';

import 'core/widgets/internet_status_overlay.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class QariApp extends StatelessWidget {
  const QariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'QARI 24/7',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],


      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      translations: Get.find<LocalizationService>(),
      locale: LocalizationService.defaultLocale,
      fallbackLocale: LocalizationService.fallbackLocale,

      home: const SplashScreen(),

      builder: (context, child) {
        return Stack(
          children: [if (child != null) child, const InternetStatusOverlay()],
        );
      },

      defaultTransition: Transition.cupertino,
    );
  }
}
