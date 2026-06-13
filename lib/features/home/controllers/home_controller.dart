import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/network_service.dart';

class HomeController extends GetxController {
  late final NetworkService _networkService;

  final dailyStreak = 0.obs;
  final timeSpentMinutes = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<NetworkService>();
    fetchHomeContent();
  }

  Future<void> fetchHomeContent() async {
    isLoading.value = true;
    try {
      final response = await _networkService.get('/home/home-content/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        dailyStreak.value = data['daily_streak'] as int? ?? 0;

        // time_spent comes as a DurationField string like "HH:MM:SS" or "0:00:00"
        final timeSpentStr = data['time_spent'] as String? ?? '0:00:00';
        timeSpentMinutes.value = _parseDurationToMinutes(timeSpentStr);
      }
    } catch (e) {
      debugPrint("HomeController.fetchHomeContent failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int _parseDurationToMinutes(String durationStr) {
    try {
      // Format: "HH:MM:SS" or "D days, HH:MM:SS"
      final parts = durationStr.split(':');
      if (parts.length >= 2) {
        // Handle "D days, HH:MM:SS" format
        String hoursStr = parts[0];
        if (hoursStr.contains(' ')) {
          final dayParts = hoursStr.split(' ');
          final days = int.tryParse(dayParts[0]) ?? 0;
          final hours = int.tryParse(dayParts.last) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          return (days * 24 * 60) + (hours * 60) + minutes;
        }
        final hours = int.tryParse(hoursStr) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        return (hours * 60) + minutes;
      }
    } catch (_) {}
    return 0;
  }
}
