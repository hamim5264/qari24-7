import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

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
}
