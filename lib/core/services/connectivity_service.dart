import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  var isConnected = true.obs;
  Timer? _timer;

  Future<ConnectivityService> init() async {
    final connectivity = Connectivity();

    final result = await connectivity.checkConnectivity();
    await _updateState(result);

    connectivity.onConnectivityChanged.listen((results) {
      _updateState(results);
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollInternetStatus();
    });

    return this;
  }

  Future<void> _pollInternetStatus() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    await _updateState(result);
  }

  Future<void> _updateState(List<ConnectivityResult> results) async {
    final hasNoHardwareConnection =
        results.isEmpty || results.contains(ConnectivityResult.none);
    if (hasNoHardwareConnection) {
      isConnected.value = false;
    } else {
      await _checkRealInternet();
    }
  }

  Future<void> _checkRealInternet() async {
    try {
      final lookup = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));
      if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
        isConnected.value = true;
        return;
      }
    } catch (_) {}
    isConnected.value = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
