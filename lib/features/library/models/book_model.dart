import 'package:get/get.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String pdfUrl;
  final String views;
  final String category;
  final List<String> pages;

  final RxBool isDownloaded = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.pdfUrl,
    required this.views,
    required this.category,
    required this.pages,
    bool initialDownloaded = false,
  }) {
    isDownloaded.value = initialDownloaded;
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      views: json['views'] ?? '0',
      category: json['category'] ?? 'All',
      pages: List<String>.from(json['pages'] ?? []),
      initialDownloaded: json['isDownloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'pdfUrl': pdfUrl,
      'views': views,
      'category': category,
      'pages': pages,
      'isDownloaded': isDownloaded.value,
    };
  }
}
