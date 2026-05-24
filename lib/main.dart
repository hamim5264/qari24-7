import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/network_service.dart';
import 'core/services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(LocalizationService());
  await Get.putAsync(() => ConnectivityService().init());
  await Get.putAsync(() => NetworkService().init());

  runApp(const QariApp());
}
