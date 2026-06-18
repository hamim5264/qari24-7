import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/book_model.dart';
import '../../../core/services/network_service.dart';
import '../screens/voice_search_bottom_sheet.dart';


class LibraryController extends GetxController {
  final RxList<LibraryItemModel> items = <LibraryItemModel>[].obs;
  final RxList<LibraryItemModel> filteredItems = <LibraryItemModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final TextEditingController searchTextController = TextEditingController();

  final Dio _dio = Dio();
  late SharedPreferences _prefs;
  late final NetworkService _networkService;

  final SpeechToText _speechToText = SpeechToText();
  final RxBool isSpeechInitialized = false.obs;
  final RxBool isListening = false.obs;
  final RxString voiceSearchText = ''.obs;


  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<NetworkService>();
    _initPreferencesAndLoad();
  }

  @override
  void onClose() {
    // Avoid disposing controllers to prevent GetX race conditions
    super.onClose();
  }

  DateTime? _lastFetchTime;

  Future<void> _initPreferencesAndLoad() async {
    _prefs = await SharedPreferences.getInstance();

    // Load cached library data first
    final String? cachedData = _prefs.getString('library_items_cache');
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<LibraryItemModel> loadedItems = decoded
            .map((json) => LibraryItemModel.fromJson(json))
            .toList();

        // Check downloads for cached items
        final appDir = await getApplicationDocumentsDirectory();
        for (var item in loadedItems) {
          final ext = item.contentType == 'audio' ? 'mp3' : 'pdf';
          final localFile = File('${appDir.path}/library/${item.id}.$ext');
          final isDownloadedLocal =
              _prefs.getBool('downloaded_${item.id}') ?? false;
          if (await localFile.exists() || isDownloadedLocal) {
            item.isDownloaded.value = true;
          }
        }

        items.assignAll(loadedItems);
        applyFilters();
        isLoading.value = false;
      } catch (e) {
        debugPrint("Error loading cached library items: $e");
      }
    } else {
      isLoading.value = true;
    }

    // Background refresh
    fetchLibrary();
  }

  /// Fetch library items from backend API
  Future<void> fetchLibrary({bool force = false}) async {
    if (!force && _lastFetchTime != null && DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 5)) {
      debugPrint("Library fetched recently. Skipping network fetch.");
      isLoading.value = false;
      return;
    }
    try {
      final response = await _networkService.get('/library/list-library/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastFetchTime = DateTime.now();
        final Map<String, dynamic> data = response.data;
        final List<LibraryItemModel> loadedItems = [];

        // Parse PDFs
        if (data.containsKey('pdfs') && data['pdfs'] is Map) {
          final pdfsData = data['pdfs']['results'] as List?;
          if (pdfsData != null) {
            for (var item in pdfsData) {
              loadedItems.add(LibraryItemModel.fromJson(item));
            }
          }
        }

        // Parse Audios
        if (data.containsKey('audios') && data['audios'] is Map) {
          final audiosData = data['audios']['results'] as List?;
          if (audiosData != null) {
            for (var item in audiosData) {
              loadedItems.add(LibraryItemModel.fromJson(item));
            }
          }
        }

        // Parse Books
        if (data.containsKey('books') && data['books'] is Map) {
          final booksData = data['books']['results'] as List?;
          if (booksData != null) {
            for (var item in booksData) {
              loadedItems.add(LibraryItemModel.fromJson(item));
            }
          }
        }

        // Update local download states
        final appDir = await getApplicationDocumentsDirectory();
        for (var item in loadedItems) {
          final ext = item.contentType == 'audio' ? 'mp3' : 'pdf';
          final localFile = File('${appDir.path}/library/${item.id}.$ext');
          final isDownloadedLocal =
              _prefs.getBool('downloaded_${item.id}') ?? false;
          if (await localFile.exists() || isDownloadedLocal) {
            item.isDownloaded.value = true;
          }
        }

        items.assignAll(loadedItems);
        applyFilters();

        // Save to cache
        final cacheData = items.map((item) => item.toJson()).toList();
        await _prefs.setString('library_items_cache', jsonEncode(cacheData));
      }
    } catch (e) {
      debugPrint("LibraryController.fetchLibrary caught error: $e");
      if (items.isEmpty) {
        Get.snackbar(
          'Offline Mode Active',
          'Unable to reach server. Loading offline cache...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal.shade800,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void searchBooks(String query) {
    searchQuery.value = query;
    if (searchTextController.text != query) {
      searchTextController.text = query;
    }
    applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void applyFilters() {
    List<LibraryItemModel> result = items;

    // Filter by category
    if (selectedCategory.value != 'All') {
      final type = selectedCategory.value.toLowerCase();
      result = result.where((item) => item.contentType == type).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }

    filteredItems.assignAll(result);
  }

  /// Download a file to local cache
  Future<void> downloadItem(LibraryItemModel item) async {
    if (item.isDownloaded.value) return;
    if (item.fileUrl == null || item.fileUrl!.isEmpty) {
      Get.snackbar(
        'Subscription Required',
        item.message ?? 'This content is locked.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/library');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final ext = item.contentType == 'audio' ? 'mp3' : 'pdf';
    final savePath = '${directory.path}/${item.id}.$ext';

    try {
      item.downloadProgress.value = 0.05;

      await _dio.download(
        item.fileUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            item.downloadProgress.value = received / total;
          }
        },
      );

      item.isDownloaded.value = true;
      item.downloadProgress.value = 0.0;
      await _prefs.setBool('downloaded_${item.id}', true);

      Get.snackbar(
        'Downloaded Successfully',
        item.title,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      item.downloadProgress.value = 0.0;
      debugPrint("LibraryController.downloadItem caught error: $e");
      Get.snackbar(
        'Download Failed',
        'Could not download file. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }
  }

  Future<String> getLocalPath(LibraryItemModel item) async {
    final appDir = await getApplicationDocumentsDirectory();
    final ext = item.contentType == 'audio' ? 'mp3' : 'pdf';
    return '${appDir.path}/library/${item.id}.$ext';
  }

  Future<void> startListening() async {
    searchTextController.clear();
    searchQuery.value = '';
    voiceSearchText.value = '';
    applyFilters();

    await _speechToText.listen(
      onResult: (result) {
        voiceSearchText.value = result.recognizedWords;
        searchTextController.text = result.recognizedWords;
        searchBooks(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    isListening.value = false;
  }

  Future<void> triggerVoiceSearch() async {
    // 1. Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone permission is required for voice search.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    try {
      if (!isSpeechInitialized.value) {
        final available = await _speechToText.initialize(
          onStatus: (status) {
            debugPrint('Speech status: $status');
            if (status == 'listening') {
              isListening.value = true;
            } else if (status == 'notListening' || status == 'done') {
              isListening.value = false;
            }
          },
          onError: (errorNotification) {
            debugPrint('Speech error: $errorNotification');
            isListening.value = false;
            if (Get.isBottomSheetOpen ?? false) {
              Get.back();
            }
            Get.snackbar(
              'Voice Search Error',
              errorNotification.errorMsg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade900,
              colorText: Colors.white,
            );
          },
        );
        isSpeechInitialized.value = available;
      }

      if (isSpeechInitialized.value) {
        // Show the voice search bottom sheet
        startListening();
        Get.bottomSheet(
          VoiceSearchBottomSheet(controller: this),
          isDismissible: true,
          enableDrag: true,
          backgroundColor: Colors.transparent,
        ).then((_) {
          stopListening();
        });
      } else {
        Get.snackbar(
          'Not Supported',
          'Voice recognition is not available on this device.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Voice search exception: $e');
    }
  }
}
