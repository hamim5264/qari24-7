import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import '../../../core/services/network_service.dart';

class NotificationApiService extends GetxService {
  late final dio_lib.Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Get.find<NetworkService>().dio;
  }

  /// Get notifications list
  Future<dio_lib.Response> getNotifications() async {
    return await _dio.get('/settings/notifications/');
  }

  /// Create a notification
  Future<dio_lib.Response> createNotification({
    required String title,
    required String body,
    int? libraryVerse,
    required String notificationType,
    bool isRead = false,
    Map<String, dynamic>? extraData,
  }) async {
    return await _dio.post(
      '/settings/notifications/',
      data: {
        'title': title,
        'body': body,
        'library_verse': libraryVerse,
        'notification_type': notificationType,
        'is_read': isRead,
        'extra_data': extraData ?? {},
      },
    );
  }

  /// Update notifications (e.g. mark read/unread)
  Future<dio_lib.Response> updateNotifications({
    required Map<String, dynamic> data,
  }) async {
    return await _dio.put('/settings/notifications/', data: data);
  }

  /// Register device token
  Future<dio_lib.Response> registerDevice({required String token}) async {
    return await _dio.post(
      '/settings/notifications/register-device/',
      data: {'token': token},
    );
  }

  /// Delete device token
  Future<dio_lib.Response> unregisterDevice({required String token}) async {
    // Delete request with body needs to pass the data in the options/data field in Dio
    return await _dio.delete(
      '/settings/notifications/register-device/',
      data: {'token': token},
    );
  }
}
