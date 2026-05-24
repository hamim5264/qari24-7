import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;

  final currentFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    prepopulateNotifications();
  }

  void prepopulateNotifications() {
    notifications.assignAll([
      NotificationModel(
        id: '1',
        titleKey: 'notification_goal_reached_title',
        descKey: 'notification_goal_reached_desc',
        timestamp: '2m ago',
        dayCategory: 'today',
        type: 'goal',
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        titleKey: 'notification_streak_risk_title',
        descKey: 'notification_streak_risk_desc',
        timestamp: '3h ago',
        dayCategory: 'today',
        type: 'streak',
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        titleKey: 'notification_challenge_title',
        descKey: 'notification_challenge_desc',
        timestamp: '5h ago',
        dayCategory: 'today',
        type: 'challenge',
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        titleKey: 'notification_achievement_title',
        descKey: 'notification_achievement_desc',
        timestamp: '1d ago',
        dayCategory: 'yesterday',
        type: 'achievement',
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        titleKey: 'notification_library_title',
        descKey: 'notification_library_desc',
        timestamp: '1d ago',
        dayCategory: 'yesterday',
        type: 'library',
        isRead: true,
      ),
    ]);
  }

  List<NotificationModel> get filteredNotifications {
    if (currentFilter.value == 'unread') {
      return notifications.where((n) => !n.isRead.value).toList();
    } else if (currentFilter.value == 'read') {
      return notifications.where((n) => n.isRead.value).toList();
    }
    return notifications;
  }

  int get unreadCount => notifications.where((n) => !n.isRead.value).length;

  void changeFilter(String filter) {
    currentFilter.value = filter;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead.value = true;
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead.value = true;
    }
    notifications.refresh();
  }

  void markSectionAsRead(String category) {
    for (var n in notifications) {
      if (n.dayCategory.toLowerCase() == category.toLowerCase()) {
        n.isRead.value = true;
      }
    }
    notifications.refresh();
  }

  void clearAll() {
    notifications.clear();
  }
}
