import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../../../core/services/network_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../community/controllers/community_controller.dart';

class NotificationController extends GetxController {
  late final NotificationRepository _repository;

  final currentFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<NotificationRepository>();
    fetchNotifications();
  }

  List<NotificationModel> get notifications => _repository.notifications;

  bool get isLoading => _repository.isLoading.value;

  Future<void> fetchNotifications() async {
    await _repository.fetchNotifications();
  }

  List<NotificationModel> get filteredNotifications {
    if (currentFilter.value == 'unread') {
      return notifications.where((n) => !n.isRead.value).toList();
    } else if (currentFilter.value == 'read') {
      return notifications.where((n) => n.isRead.value).toList();
    }
    return notifications;
  }

  int get unreadCount =>
      _repository.notifications.where((n) => !n.isRead.value).length;

  void changeFilter(String filter) {
    currentFilter.value = filter;
  }

  void markAsRead(String id) {
    _repository.markAsRead(id);
  }

  void markAllAsRead() {
    _repository.markAllAsRead();
  }

  void markSectionAsRead(String category) {
    _repository.markSectionAsRead(category);
  }

  void clearAll() {
    _repository.clearAll();
  }

  Future<void> respondToJoinRequest(String notificationId, int joinRequestId, String action) async {
    try {
      final networkService = Get.find<NetworkService>();
      final response = await networkService.post(
        '/community/join-requests/$joinRequestId/respond/',
        data: {'action': action},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Join Request',
          'Request ${action == 'approve' ? 'approved' : 'declined'} successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );

        // Update local actionStatus to show approved/declined immediately in UI
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index].actionStatus.value = action == 'approve' ? 'approved' : 'declined';
        }

        // Mark the notification as read on backend and locally
        markAsRead(notificationId);

        // Fetch communities list to update UI in CommunityScreen/YourCommunityScreen
        if (Get.isRegistered<CommunityController>()) {
          Get.find<CommunityController>().fetchCommunities();
        }
      } else {
        Get.snackbar('Error', 'Failed to respond to join request.');
      }
    } catch (e) {
      debugPrint("NotificationController.respondToJoinRequest error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
