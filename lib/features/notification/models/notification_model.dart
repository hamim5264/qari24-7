import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String titleKey;
  final String descKey;
  final String timestamp;
  final String dayCategory;
  final String type;
  final RxBool isRead;
  final int? libraryVerse;
  final Map<String, dynamic>? extraData;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.timestamp,
    required this.dayCategory,
    required this.type,
    bool isRead = false,
    this.libraryVerse,
    this.extraData,
    this.createdAt,
  }) : isRead = isRead.obs;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId != null ? rawId.toString() : '';

    final title = json['title'] as String? ?? json['titleKey'] as String? ?? '';
    final body = json['body'] as String? ?? json['descKey'] as String? ?? '';

    final created =
        json['created_at'] as String? ?? json['createdAt'] as String?;
    String timeStr = json['timestamp'] as String? ?? '';
    String dayCat = json['dayCategory'] as String? ?? 'today';

    if (created != null && created.isNotEmpty) {
      timeStr = _formatTimestamp(created);
      dayCat = _getDayCategory(created);
    }

    return NotificationModel(
      id: idStr,
      titleKey: title,
      descKey: body,
      timestamp: timeStr,
      dayCategory: dayCat,
      type:
          json['notification_type'] as String? ??
          json['type'] as String? ??
          'general',
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      libraryVerse:
          json['library_verse'] as int? ?? json['libraryVerse'] as int?,
      extraData:
          json['extra_data'] as Map<String, dynamic>? ??
          json['extraData'] as Map<String, dynamic>?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descKey': descKey,
      'timestamp': timestamp,
      'dayCategory': dayCategory,
      'type': type,
      'isRead': isRead.value,
      'library_verse': libraryVerse,
      'extra_data': extraData,
      'created_at': createdAt,
    };
  }

  static String _formatTimestamp(String createdAtStr) {
    try {
      final DateTime dt = DateTime.parse(createdAtStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(dt);

      if (diff.inSeconds < 60) {
        return 'just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  static String _getDayCategory(String createdAtStr) {
    try {
      final DateTime dt = DateTime.parse(createdAtStr).toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));

      final DateTime compareDate = DateTime(dt.year, dt.month, dt.day);
      if (compareDate == today) {
        return 'today';
      } else if (compareDate == yesterday) {
        return 'yesterday';
      } else {
        return 'older';
      }
    } catch (_) {
      return 'older';
    }
  }
}
