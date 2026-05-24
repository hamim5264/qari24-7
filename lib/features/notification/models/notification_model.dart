import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String titleKey;
  final String descKey;
  final String timestamp;
  final String dayCategory;
  final String type;
  final RxBool isRead;

  NotificationModel({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.timestamp,
    required this.dayCategory,
    required this.type,
    bool isRead = false,
  }) : isRead = isRead.obs;
}
