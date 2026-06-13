import 'package:get/get.dart';

class LibraryItemModel {
  final int id;
  final String title;
  final String description;
  final String contentType; // "pdf", "audio", "book"
  final String access; // "free", "premium"
  final String? fileUrl;
  final String coverUrl;
  final String createdAt;
  final bool locked;
  final String? message;

  // Local state for downloads
  final RxBool isDownloaded = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  LibraryItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.contentType,
    required this.access,
    this.fileUrl,
    required this.coverUrl,
    required this.createdAt,
    required this.locked,
    this.message,
    bool initialDownloaded = false,
  }) {
    isDownloaded.value = initialDownloaded;
  }

  factory LibraryItemModel.fromJson(Map<String, dynamic> json) {
    return LibraryItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      contentType: json['content_type'] ?? '',
      access: json['access'] ?? 'free',
      fileUrl: json['file_url'],
      coverUrl: json['cover_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      locked: json['locked'] ?? false,
      message: json['message'],
      initialDownloaded: json['isDownloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content_type': contentType,
      'access': access,
      'file_url': fileUrl,
      'cover_url': coverUrl,
      'created_at': createdAt,
      'locked': locked,
      'message': message,
      'isDownloaded': isDownloaded.value,
    };
  }
}
