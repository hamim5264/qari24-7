import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/book_model.dart';
import '../controllers/library_controller.dart';
import '../../../core/constants/app_colors.dart';

class PdfReaderScreen extends StatefulWidget {
  final LibraryItemModel item;
  final String localPath;

  const PdfReaderScreen({
    super.key,
    required this.item,
    required this.localPath,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late PdfViewerController _pdfViewerController;
  final RxInt _currentPage = 1.obs;
  final RxInt _pageCount = 0.obs;
  final RxBool _isLoading = true.obs;
  final RxDouble _downloadProgress = 0.0.obs;
  final RxBool _isDownloading = false.obs;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _checkAndDownloadFile();
  }

  Future<void> _checkAndDownloadFile() async {
    final File localFile = File(widget.localPath);
    if (widget.item.isDownloaded.value && localFile.existsSync()) {
      _isLoading.value = true;
      _isDownloading.value = false;
      return;
    }

    _isDownloading.value = true;
    _isLoading.value = false;

    try {
      final controller = Get.isRegistered<LibraryController>()
          ? Get.find<LibraryController>()
          : Get.put(LibraryController());

      // Bind local progress to item progress
      widget.item.downloadProgress.listen((progress) {
        _downloadProgress.value = progress;
      });

      await controller.downloadItem(widget.item);

      if (widget.item.isDownloaded.value && localFile.existsSync()) {
        _isDownloading.value = false;
        _isLoading.value = true;
      } else {
        throw Exception("Download failed or file not found.");
      }
    } catch (e) {
      _isDownloading.value = false;
      _showErrorSnackbar("Failed to download PDF: $e");
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : Colors.black87;

    final File localFile = File(widget.localPath);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.item.title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in, color: textColor),
            onPressed: () => _pdfViewerController.zoomLevel =
                (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0),
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: textColor),
            onPressed: () => _pdfViewerController.zoomLevel =
                (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (_isDownloading.value) {
              return const SizedBox.shrink();
            }
            if (!localFile.existsSync()) {
              return const Center(
                child: Text(
                  "Preparing document...",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return SfPdfViewer.file(
              localFile,
              controller: _pdfViewerController,
              enableTextSelection: false,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                _pageCount.value = details.document.pages.count;
                _isLoading.value = false;
              },
              onPageChanged: (PdfPageChangedDetails details) {
                _currentPage.value = details.newPageNumber;
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                _isLoading.value = false;
                _showErrorSnackbar(details.description);
              },
            );
          }),
          Obx(() {
            if (!_isDownloading.value && !_isLoading.value) return const SizedBox.shrink();
            return Container(
              color: bgColor.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    if (_isDownloading.value) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Downloading... ${(_downloadProgress.value * 100).toInt()}%",
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (_pageCount.value <= 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Page ${_currentPage.value} of ${_pageCount.value}",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showErrorSnackbar(String description) {
    Get.snackbar(
      'Load Failed',
      description,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
