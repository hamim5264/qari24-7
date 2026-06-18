import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/network_service.dart';
import '../../progress/controllers/progress_controller.dart';
import '../models/quran_models.dart';
import '../services/recitation_ai_service.dart';

class RecitationController extends GetxController {
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  late final AudioPlayer _audioPlayer;
  late final AudioPlayer _wordAudioPlayer;

  final RecitationAIService _recitationAIService = RecitationAIService();
  final RxMap<String, String> wordHighlightStatuses = <String, String>{}.obs;
  var recitationServerUrl = 'ws://localhost:8000/recitation-stream'.obs;

  final List<GestureRecognizer> activeTapRecognizers = [];

  var isLoading = false.obs;
  final Rxn<Surah> currentSurah = Rxn<Surah>();
  var currentSurahNumber = 1.obs;

  var mushafLayout = 'text'.obs;
  var fontSizeArabic = 24.0.obs;
  var fontSizeTranslation = 14.0.obs;
  var showTajweed = true.obs;
  var isAyahHiddenMode = false.obs;
  final RxList<int> hiddenAyahNumbers = <int>[].obs;
  var showDebugDiagnostics = false.obs;

  var showEyeCapsule = false.obs;
  var showMicCapsule = false.obs;
  var showLinesWithAyahNumber = true.obs;

  final RxList<String> downloadedSurahKeys = <String>[].obs;
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var downloadProgressText = ''.obs;

  var isPlayingAudio = false.obs;
  var isRecitingMic = false.obs;
  var currentRecitingAyahNum = 1.obs;
  var playbackSpeed = 1.0.obs;
  var startingVerse = 1.obs;
  var endingVerse = 7.obs;
  var selectedReciter = 'Abdul Rahman'.obs;
  var loopEachVerseCount = 1.obs;
  var loopRangeCount = 1.obs;
  var currentPlayingAyahIndex = (-1).obs;
  var audioPosition = Duration.zero.obs;
  var audioDuration = Duration.zero.obs;

  var mistakeDetectionActive = false.obs;
  final RxList<int> detectedMistakeAyahs = <int>[].obs;
  var mistakeStatusMessage = ''.obs;
  var realTimeMistakeCount = 0.obs;

  var searchQuery = ''.obs;
  var selectedSearchTab = 'Chapters'.obs;
  final RxList<Map<String, dynamic>> allSurahsList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredSurahsList =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> recentlyReadSurahs =
      <Map<String, dynamic>>[
        {'number': 1, 'englishName': 'Al-Fatihah', 'page': 1, 'ayahs': 7},
        {'number': 67, 'englishName': 'Al-Mulk', 'page': 562, 'ayahs': 30},
      ].obs;

  String getReciterIdentifier(String reciterName) {
    switch (reciterName) {
      case 'Abdul Rahman':
        return 'ar.abdurrahmaansudais';
      case 'Abu Bakr Al-Shatri':
        return 'ar.shaatree';
      case 'Mahmoud Husary':
        return 'ar.husary';
      case 'Maher Al-Muaiqly':
        return 'ar.mahermuaiqly';
      case 'Mishary Al-Afasy':
        return 'ar.alafasy';
      case 'Ahmed Ajamy':
        return 'ar.ahmedajamy';
      case 'Female Reciter (Maria Ulfah)':
        return 'female.mariaulfah';
      default:
        return 'ar.alafasy';
    }
  }

  int _currentPlayingVerse = 1;
  int _currentVerseRepeatTimes = 0;
  int _currentRangeRepeatTimes = 0;

  late final NetworkService _networkService;
  DateTime? _sessionStartTime;
  int? _sessionStartVerse;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _wordAudioPlayer = AudioPlayer();
    _networkService = Get.find<NetworkService>();

    _wordAudioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    _initializeSurahsList();
    _loadDownloadedSurahsKeys();
    loadSavedSurahs();
    loadSurah(1);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlayingAudio.value = (state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _handleAyahPlaybackComplete();
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      audioPosition.value = pos;
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      audioDuration.value = dur;
    });
  }

  @override
  void onClose() {
    _logSessionProgress(wasReciting: isRecitingMic.value);
    for (var r in activeTapRecognizers) {
      try {
        r.dispose();
      } catch (_) {}
    }
    activeTapRecognizers.clear();

    _recitationAIService.stopSession();
    _wordAudioPlayer.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  void playAudioForRange() async {
    if (currentSurah.value == null) return;

    isRecitingMic.value = false;
    mistakeDetectionActive.value = false;
    showMicCapsule.value = false;

    if (isPlayingAudio.value) {
      await _audioPlayer.pause();
      isPlayingAudio.value = false;
      _logSessionProgress();
      return;
    }

    if (_audioPlayer.state == PlayerState.paused) {
      await _audioPlayer.resume();
      isPlayingAudio.value = true;
      _sessionStartTime = DateTime.now();
      _sessionStartVerse = _currentPlayingVerse;
      return;
    }

    _currentPlayingVerse = startingVerse.value;
    _currentVerseRepeatTimes = 0;
    _currentRangeRepeatTimes = 0;

    _sessionStartTime = DateTime.now();
    _sessionStartVerse = startingVerse.value;

    _playCurrentVerseAudio();
  }

  Future<void> _playCurrentVerseAudio() async {
    if (currentSurah.value == null) {
      isPlayingAudio.value = false;
      currentPlayingAyahIndex.value = -1;
      return;
    }

    final ayahs = currentSurah.value!.ayahs;
    final ayah = ayahs.firstWhere(
      (a) => a.numberInSurah == _currentPlayingVerse,
      orElse: () => ayahs.first,
    );

    currentPlayingAyahIndex.value = ayah.numberInSurah;
    audioPosition.value = Duration.zero;
    audioDuration.value = Duration.zero;

    var reciterId = getReciterIdentifier(selectedReciter.value);

    if (reciterId == 'female.mariaulfah') {
      if (_currentPlayingVerse == startingVerse.value &&
          _currentVerseRepeatTimes == 0) {
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFE2B93C),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  "Qari'at Female Reciter",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Verse-by-verse studio audio for female reciters is currently not hosted on public CDNs due to a lack of open-source recordings. Qari24/7 fully supports female recitation initiatives! While we work on custom recordings, we will stream Mishary Al-Afasy as a beautiful placeholder.",
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Inter',
                height: 1.5,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      reciterId = 'ar.alafasy';
    }

    final bitrate = (reciterId == 'ar.abdurrahmaansudais') ? '192' : '128';
    final audioUrl =
        'https://cdn.islamic.network/quran/audio/$bitrate/$reciterId/${ayah.number}.mp3';

    try {
      final localPath = await _getLocalAyahFilePath(
        currentSurahNumber.value,
        reciterId,
        ayah.number,
      );
      final localFile = File(localPath);

      if (await localFile.exists()) {
        debugPrint("Playing local offline audio: $localPath");
        await _audioPlayer.setPlaybackRate(playbackSpeed.value);
        await _audioPlayer.play(DeviceFileSource(localPath));
      } else {
        debugPrint("Streaming online audio: $audioUrl");
        await _audioPlayer.setPlaybackRate(playbackSpeed.value);
        await _audioPlayer.play(UrlSource(audioUrl));
      }
      isPlayingAudio.value = true;
    } catch (e) {
      debugPrint("Error playing audio: $e");
      Get.snackbar(
        'Audio Playback Error',
        'Failed to play Ayah ${ayah.numberInSurah}. Skipping...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      _handleAyahPlaybackComplete();
    }
  }

  void _handleAyahPlaybackComplete() async {
    if (currentSurah.value == null) return;

    _currentVerseRepeatTimes++;
    final maxVerseRepeats = loopEachVerseCount.value;

    if (maxVerseRepeats != 999 && _currentVerseRepeatTimes < maxVerseRepeats) {
      await _playCurrentVerseAudio();
      return;
    }

    _currentVerseRepeatTimes = 0;
    _currentPlayingVerse++;

    if (_currentPlayingVerse > endingVerse.value) {
      _currentRangeRepeatTimes++;
      final maxRangeRepeats = loopRangeCount.value;

      if (maxRangeRepeats == 999 ||
          _currentRangeRepeatTimes < maxRangeRepeats) {
        _currentPlayingVerse = startingVerse.value;
        await _playCurrentVerseAudio();
      } else {
        await _audioPlayer.stop();
        isPlayingAudio.value = false;
        currentPlayingAyahIndex.value = -1;
        _logSessionProgress();

        Get.snackbar(
          'Playback Completed',
          'Recitation range play completed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F3A27),
          colorText: Colors.white,
        );
      }
    } else {
      await _playCurrentVerseAudio();
    }
  }

  void stopAudioPlayback() async {
    await _audioPlayer.stop();
    isPlayingAudio.value = false;
    currentPlayingAyahIndex.value = -1;
    _logSessionProgress();
  }

  void toggleAudioPlayback() {
    playAudioForRange();
  }

  void toggleMushafLayout(String layout) {
    mushafLayout.value = layout;
  }

  void toggleTajweed() {
    showTajweed.value = !showTajweed.value;
  }

  void toggleAyahHiddenMode() {
    isAyahHiddenMode.value = !isAyahHiddenMode.value;
    if (isAyahHiddenMode.value) {
      if (currentSurah.value != null) {
        hiddenAyahNumbers.assignAll(
          currentSurah.value!.ayahs.map((e) => e.numberInSurah).toList(),
        );
      }
    } else {
      hiddenAyahNumbers.clear();
    }
  }

  void toggleSingleAyahVisibility(int numberInSurah) {
    if (hiddenAyahNumbers.contains(numberInSurah)) {
      hiddenAyahNumbers.remove(numberInSurah);
    } else {
      hiddenAyahNumbers.add(numberInSurah);
    }
  }

  bool isAyahCurrentlyHidden(int numberInSurah) {
    return isAyahHiddenMode.value && hiddenAyahNumbers.contains(numberInSurah);
  }

  void changePlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    if (isPlayingAudio.value) {
      _audioPlayer.setPlaybackRate(speed);
    }
  }

  void toggleRecitingMic() async {
    if (isPlayingAudio.value) {
      _logSessionProgress();
    }

    isRecitingMic.value = !isRecitingMic.value;
    showMicCapsule.value = false;

    if (isRecitingMic.value) {
      isPlayingAudio.value = false;
      await _audioPlayer.stop();
      currentPlayingAyahIndex.value = -1;

      final surah = currentSurah.value;

      _sessionStartTime = DateTime.now();
      _sessionStartVerse = startingVerse.value;
      if (surah == null) {
        isRecitingMic.value = false;
        Get.snackbar(
          'Recitation Error',
          'Please load a Surah first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      final activeAyahNum = startingVerse.value;

      final bool prependBismillah =
          (surah.number != 1 && surah.number != 9 && activeAyahNum == 1);
      currentRecitingAyahNum.value = prependBismillah ? 0 : activeAyahNum;

      wordHighlightStatuses.removeWhere(
        (key, value) => key.startsWith("${surah.number}_"),
      );
      realTimeMistakeCount.value = 0;
      mistakeDetectionActive.value = true;
      mistakeStatusMessage.value = "Connecting to Recitation Engine...";

      final List<Map<String, dynamic>> remainingAyahs = [];
      if (prependBismillah) {
        remainingAyahs.add({
          'ayah_number': 0,
          'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        });
      }
      remainingAyahs.addAll(
        surah.ayahs
            .where((a) => a.numberInSurah >= activeAyahNum)
            .map((a) => {'ayah_number': a.numberInSurah, 'text': a.text})
            .toList(),
      );

      final String activeAyahText = prependBismillah
          ? 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'
          : surah.ayahs
                .firstWhere(
                  (a) => a.numberInSurah == activeAyahNum,
                  orElse: () => surah.ayahs.first,
                )
                .text;

      debugPrint(
        "[RecitationController] Starting continuous streaming session. Prepend Bismillah: $prependBismillah",
      );

      await _recitationAIService.startRecitationSession(
        serverUrl: recitationServerUrl.value,
        ayahText: activeAyahText,
        surahNumber: surah.number,
        ayahNumber: prependBismillah ? 0 : activeAyahNum,
        fullSurahAyahs: remainingAyahs,
        onFeedbackReceived: (feedback) {
          try {
            final int? wordIdx = feedback['word_index'];
            final String? status = feedback['status'];
            final int activeAyahNum =
                feedback['ayah_number'] ?? currentRecitingAyahNum.value;

            if (activeAyahNum != currentRecitingAyahNum.value) {
              currentRecitingAyahNum.value = activeAyahNum;
            }

            if (wordIdx != null && status != null) {
              final key = "${surah.number}_${activeAyahNum}_$wordIdx";
              wordHighlightStatuses[key] = status;

              int totalMistakes = 0;
              wordHighlightStatuses.forEach((k, v) {
                if (k.startsWith("${surah.number}_") &&
                    (v == 'minor_mistake' || v == 'major_mistake')) {
                  totalMistakes++;
                }
              });
              realTimeMistakeCount.value = totalMistakes;

              if (status == 'minor_mistake' || status == 'major_mistake') {
                if (!detectedMistakeAyahs.contains(activeAyahNum)) {
                  detectedMistakeAyahs.add(activeAyahNum);
                }
                mistakeStatusMessage.value =
                    "Discrepancies found! Tap words to listen to correct pronunciation.";
                prefetchWordAudio(surah.number, activeAyahNum, wordIdx);
              } else {
                mistakeStatusMessage.value =
                    "Reciting... Word ${wordIdx + 1} of Ayah $activeAyahNum analyzed successfully.";
              }
            }
          } catch (e) {
            debugPrint(
              "[RecitationController] Error parsing feedback event: $e",
            );
          }
        },
        onError: (err) {
          isRecitingMic.value = false;
          mistakeDetectionActive.value = false;
          _logSessionProgress(wasReciting: true);
          Get.snackbar(
            'Recitation Error',
            'Connection to recitation engine failed: $err',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade900,
            colorText: Colors.white,
          );
        },
        onDone: () {
          isRecitingMic.value = false;
          mistakeDetectionActive.value = false;
          _logSessionProgress(wasReciting: true);
        },
      );
    } else {
      mistakeDetectionActive.value = false;
      await _recitationAIService.stopSession();
      _logSessionProgress(wasReciting: true);
    }
  }

  void _logSessionProgress({bool wasReciting = false}) {
    if (_sessionStartTime == null || currentSurah.value == null) return;

    final startTime = _sessionStartTime!;
    final endTime = DateTime.now();
    final durationSeconds = endTime.difference(startTime).inSeconds;

    if (durationSeconds < 1) {
      _sessionStartTime = null;
      _sessionStartVerse = null;
      return;
    }

    final surahId = currentSurah.value!.number;
    final startVerse = _sessionStartVerse ?? startingVerse.value;

    int endVerse = startVerse;
    if (wasReciting) {
      endVerse = currentRecitingAyahNum.value > 0
          ? currentRecitingAyahNum.value
          : startVerse;
    } else {
      endVerse = _currentPlayingVerse > 0 ? _currentPlayingVerse : startVerse;
    }

    if (endVerse < startVerse) {
      endVerse = startVerse;
    }
    final maxAyahs = currentSurah.value!.numberOfAyahs;
    if (endVerse > maxAyahs) {
      endVerse = maxAyahs;
    }

    _sessionStartTime = null;
    _sessionStartVerse = null;

    _logProgressToBackend(
      surahId: surahId,
      startVerse: startVerse,
      endVerse: endVerse,
      timeSpentSeconds: durationSeconds,
    );
  }

  Future<void> _logProgressToBackend({
    required int surahId,
    required int startVerse,
    required int endVerse,
    required int timeSpentSeconds,
  }) async {
    try {
      final body = {
        'surah_id': surahId,
        'verse_start': startVerse,
        'verse_end': endVerse,
        'time_spent': timeSpentSeconds,
      };

      debugPrint("[RecitationController] Logging progress to backend: $body");
      final response = await _networkService.post('/progress/log/', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("[RecitationController] Progress logged successfully.");
        if (Get.isRegistered<ProgressController>()) {
          Get.find<ProgressController>().fetchProgress();
        }
      } else {
        debugPrint(
          "[RecitationController] Progress log failed: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e) {
      debugPrint(
        "[RecitationController] Error logging progress to backend: $e",
      );
    }
  }

  Future<String> _getLocalWordAudioPath(int surahNum, int ayahNum, int wordIndex) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final surahStr = surahNum.toString().padLeft(3, '0');
    final ayahStr = ayahNum.toString().padLeft(3, '0');
    final wordStr = (wordIndex + 1).toString().padLeft(3, '0');
    return '${appDocDir.path}/cache/wbw/${surahStr}_${ayahStr}_$wordStr.mp3';
  }

  Future<void> prefetchWordAudio(int surahNum, int ayahNum, int wordIndex) async {
    int finalSurahNum = surahNum;
    int finalAyahNum = ayahNum;
    if (ayahNum == 0) {
      finalSurahNum = 1;
      finalAyahNum = 1;
    }

    try {
      final localPath = await _getLocalWordAudioPath(finalSurahNum, finalAyahNum, wordIndex);
      final file = File(localPath);
      if (await file.exists()) {
        return;
      }

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      final wIndex = wordIndex + 1;
      final surahStr = finalSurahNum.toString().padLeft(3, '0');
      final ayahStr = finalAyahNum.toString().padLeft(3, '0');
      final wordStr = wIndex.toString().padLeft(3, '0');
      final wbwUrl = 'https://audio.qurancdn.com/wbw/${surahStr}_${ayahStr}_$wordStr.mp3';

      debugPrint("[RecitationController] Prefetching word pronunciation: $wbwUrl");
      final client = dio.Dio();
      client.options.connectTimeout = const Duration(seconds: 5);
      client.options.receiveTimeout = const Duration(seconds: 5);
      await client.download(wbwUrl, localPath);
      debugPrint("[RecitationController] Prefetched word pronunciation to: $localPath");
    } catch (e) {
      debugPrint("[RecitationController] Error prefetching word pronunciation: $e");
    }
  }

  Future<void> playWordAudio(int surahNum, int ayahNum, int wordIndex) async {
    int finalSurahNum = surahNum;
    int finalAyahNum = ayahNum;
    if (ayahNum == 0) {
      finalSurahNum = 1;
      finalAyahNum = 1;
    }

    try {
      await _wordAudioPlayer.stop();
      final localPath = await _getLocalWordAudioPath(finalSurahNum, finalAyahNum, wordIndex);
      final file = File(localPath);

      if (await file.exists()) {
        debugPrint("[RecitationController] Playing local word pronunciation: $localPath");
        await _wordAudioPlayer.play(DeviceFileSource(localPath));
      } else {
        final wIndex = wordIndex + 1;
        final surahStr = finalSurahNum.toString().padLeft(3, '0');
        final ayahStr = finalAyahNum.toString().padLeft(3, '0');
        final wordStr = wIndex.toString().padLeft(3, '0');
        final wbwUrl = 'https://audio.qurancdn.com/wbw/${surahStr}_${ayahStr}_$wordStr.mp3';

        debugPrint("[RecitationController] Streaming word pronunciation fallback: $wbwUrl");
        await _wordAudioPlayer.play(UrlSource(wbwUrl));
        // Prefetch for subsequent taps
        prefetchWordAudio(surahNum, ayahNum, wordIndex);
      }
    } catch (e) {
      debugPrint("[RecitationController] Error playing word pronunciation: $e");
    }
  }

  void resetRecitationState() {
    debugPrint("[RecitationController] resetRecitationState invoked.");
    _recitationAIService.stopSession();
    _audioPlayer.stop();
    _wordAudioPlayer.stop();
    isPlayingAudio.value = false;
    isRecitingMic.value = false;
    currentPlayingAyahIndex.value = -1;
    mistakeDetectionActive.value = false;
    detectedMistakeAyahs.clear();
    wordHighlightStatuses.clear();
    realTimeMistakeCount.value = 0;
  }

  void triggerAIMistakeDetection() {
    if (currentSurah.value == null) return;

    mistakeDetectionActive.value = true;
    detectedMistakeAyahs.clear();
    realTimeMistakeCount.value = 0;
    mistakeStatusMessage.value = 'detecting_mistakes'.tr;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mistakeDetectionActive.value) return;

      final ayahsCount = currentSurah.value!.ayahs.length;
      if (ayahsCount > 1) {
        int mistakeIndex = ayahsCount > 2 ? 3 : 2;
        detectedMistakeAyahs.add(mistakeIndex);
        realTimeMistakeCount.value = 1;
        mistakeStatusMessage.value = 'Mistake found at Ayah $mistakeIndex!';

        Get.snackbar(
          'mistake_detection'.tr,
          'Simulated memorization discrepancy detected at Ayah $mistakeIndex.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        mistakeStatusMessage.value = 'no_mistakes_found'.tr;
      }
    });
  }

  void stopMistakeDetection() {
    mistakeDetectionActive.value = false;
    detectedMistakeAyahs.clear();
    realTimeMistakeCount.value = 0;
  }

  Future<void> loadSurah(int surahNumber) async {
    debugPrint("==================================================");
    debugPrint("[Qari24/7 Debug] loadSurah started for Surah #$surahNumber");

    for (var r in activeTapRecognizers) {
      try {
        r.dispose();
      } catch (_) {}
    }
    activeTapRecognizers.clear();
    wordHighlightStatuses.clear();

    isLoading.value = true;
    currentSurahNumber.value = surahNumber;
    detectedMistakeAyahs.clear();
    mistakeDetectionActive.value = false;
    realTimeMistakeCount.value = 0;
    currentPlayingAyahIndex.value = -1;

    try {
      final existingIndex = recentlyReadSurahs.indexWhere(
        (element) => element['number'] == surahNumber,
      );
      if (existingIndex != -1) {
        final item = recentlyReadSurahs.removeAt(existingIndex);
        recentlyReadSurahs.insert(0, item);
      } else {
        final surahInfo = allSurahsList.firstWhere(
          (element) => element['number'] == surahNumber,
          orElse: () => {'englishName': 'Surah', 'ayahs': 10},
        );
        recentlyReadSurahs.insert(0, {
          'number': surahNumber,
          'englishName': surahInfo['englishName'],
          'page': surahNumber == 67 ? 562 : (surahNumber == 2 ? 2 : 1),
          'ayahs': surahInfo['ayahs'],
        });
      }
      debugPrint("[Qari24/7 Debug] Recently read list updated successfully.");
    } catch (e, stack) {
      debugPrint(
        "[Qari24/7 Debug] Error updating recently read list: $e\n$stack",
      );
    }

    if (surahNumber == 1) {
      startingVerse.value = 1;
      endingVerse.value = 7;
    } else if (surahNumber == 67) {
      startingVerse.value = 1;
      endingVerse.value = 30;
    } else if (surahNumber == 2) {
      startingVerse.value = 1;
      endingVerse.value = 10;
    } else {
      startingVerse.value = 1;
      endingVerse.value = 10;
    }
    debugPrint(
      "[Qari24/7 Debug] Starting/ending verse defaults set: ${startingVerse.value} to ${endingVerse.value}",
    );

    try {
      final isConnected = _connectivity.isConnected.value;
      debugPrint(
        "[Qari24/7 Debug] Network connection status (isConnected): $isConnected",
      );

      if (isConnected) {
        final surahUrl = 'https://api.alquran.cloud/v1/surah/$surahNumber';
        final translationUrl =
            'https://api.alquran.cloud/v1/surah/$surahNumber/en.pickthall';
        debugPrint(
          "[Qari24/7 Debug] Attempting network fetch from endpoints:\n- Arabic: $surahUrl\n- English Translation: $translationUrl",
        );

        final client = dio.Dio();
        client.options.connectTimeout = const Duration(seconds: 10);
        client.options.receiveTimeout = const Duration(seconds: 10);

        final arabicResponse = await client.get(surahUrl);
        final transResponse = await client.get(translationUrl);

        debugPrint(
          "[Qari24/7 Debug] Network responses received:\n- Arabic status code: ${arabicResponse.statusCode}\n- English status code: ${transResponse.statusCode}",
        );

        if (arabicResponse.statusCode == 200 &&
            transResponse.statusCode == 200) {
          final arabicData = arabicResponse.data['data'];
          final transData = transResponse.data['data'];

          debugPrint("[Qari24/7 Debug] Parsing Ayah translations...");
          final List<String> translations = (transData['ayahs'] as List)
              .map((a) => a['text'] as String)
              .toList();

          debugPrint(
            "[Qari24/7 Debug] Reconstructing Surah model from network data...",
          );
          final fetchedSurah = Surah.fromJson(arabicData, translations);

          debugPrint(
            "[Qari24/7 Debug] Generating tajweed rules markup representation for verses...",
          );
          for (var ayah in fetchedSurah.ayahs) {
            ayah.tajweedSpans = _generateTajweedSpansForAyah(ayah.text);
          }

          currentSurah.value = fetchedSurah;
          isLoading.value = false;
          debugPrint(
            "[Qari24/7 Debug] Surah Al-${fetchedSurah.englishName} loaded successfully from Islamic Network API.",
          );
          debugPrint("==================================================");
          return;
        } else {
          debugPrint(
            "[Qari24/7 Debug] API returned unsuccessful status code(s): Arabic=${arabicResponse.statusCode}, English=${transResponse.statusCode}",
          );
        }
      }
    } catch (e, stack) {
      debugPrint(
        "[Qari24/7 Debug] Quran API Network Exception caught: $e\n$stack",
      );
    }

    debugPrint("[Qari24/7 Debug] Triggering offline mock database fallback...");
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final localMockSurah = _loadLocalMockSurah(surahNumber);
      currentSurah.value = localMockSurah;
      isLoading.value = false;
      debugPrint(
        "[Qari24/7 Debug] Offline mock database fallback successful. Surah: ${localMockSurah.englishName}",
      );
    } catch (e, stack) {
      debugPrint(
        "[Qari24/7 Debug] CRITICAL: Failed to load offline mock Surah: $e\n$stack",
      );
      isLoading.value = false;
    }
    debugPrint("==================================================");
  }

  Surah _loadLocalMockSurah(int number) {
    if (number == 67) {
      return Surah(
        number: 67,
        name: "سُورَةُ المُلۡكِ",
        englishName: "Al-Mulk",
        englishNameTranslation: "The Sovereignty",
        numberOfAyahs: 30,
        revelationType: "Meccan",
        ayahs: List.generate(30, (index) {
          final ayahNum = index + 1;
          final String text = _getAlMulkArabic(ayahNum);
          final String translation = _getAlMulkTranslation(ayahNum);
          final ayah = Ayah(
            number: index + 5248,
            text: text,
            numberInSurah: ayahNum,
            textTranslation: translation,
            page: 562,
            juz: 29,
          );
          ayah.tajweedSpans = _generateTajweedSpansForAyah(text);
          return ayah;
        }),
      );
    } else if (number == 2) {
      return Surah(
        number: 2,
        name: "سُورَةُ البَقَرَةِ",
        englishName: "Al-Baqarah",
        englishNameTranslation: "The Cow",
        numberOfAyahs: 286,
        revelationType: "Medinan",
        ayahs: List.generate(10, (index) {
          final ayahNum = index + 1;
          final String text = _getAlBaqarahArabic(ayahNum);
          final String translation = _getAlBaqarahTranslation(ayahNum);
          final ayah = Ayah(
            number: index + 8,
            text: text,
            numberInSurah: ayahNum,
            textTranslation: translation,
            page: 2,
            juz: 1,
          );
          ayah.tajweedSpans = _generateTajweedSpansForAyah(text);
          return ayah;
        }),
      );
    } else {
      return Surah(
        number: 1,
        name: "سُورَةُ الفَاتِحَةِ",
        englishName: "Al-Fatihah",
        englishNameTranslation: "The Opening",
        numberOfAyahs: 7,
        revelationType: "Meccan",
        ayahs: List.generate(7, (index) {
          final ayahNum = index + 1;
          final String text = _getAlFatihahArabic(ayahNum);
          final String translation = _getAlFatihahTranslation(ayahNum);
          final ayah = Ayah(
            number: index + 1,
            text: text,
            numberInSurah: ayahNum,
            textTranslation: translation,
            page: 1,
            juz: 1,
          );
          ayah.tajweedSpans = _generateTajweedSpansForAyah(text);
          return ayah;
        }),
      );
    }
  }

  List<TajweedSpan> _generateTajweedSpansForAyah(String text) {
    List<TajweedSpan> spans = [];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      String suffix = (i == words.length - 1) ? "" : " ";

      if (word.contains('ّ') && (word.contains('ن') || word.contains('م'))) {
        spans.add(TajweedSpan(text: "$word$suffix", rule: TajweedRule.ghunnah));
      } else if (word.contains('ق') ||
          word.contains('ط') ||
          word.contains('ب') ||
          word.contains('ج') ||
          word.contains('د')) {
        spans.add(
          TajweedSpan(text: "$word$suffix", rule: TajweedRule.qalqalah),
        );
      } else if (word.contains('آ') ||
          word.contains('ـٰ') ||
          word.contains('ىٰ') ||
          word.length > 7) {
        spans.add(TajweedSpan(text: "$word$suffix", rule: TajweedRule.madd));
      } else if (word.contains('ً') ||
          word.contains('ٍ') ||
          word.contains('ٌ')) {
        spans.add(TajweedSpan(text: "$word$suffix", rule: TajweedRule.idgham));
      } else {
        spans.add(TajweedSpan(text: "$word$suffix", rule: TajweedRule.none));
      }
    }
    return spans;
  }

  String _getAlFatihahArabic(int ayahNum) {
    final list = [
      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
      "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
      "الرَّحْمَٰنِ الرَّحِيمِ",
      "مَالِكِ يَوْمِ الدِّينِ",
      "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
      "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
      "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "";
  }

  String _getAlFatihahTranslation(int ayahNum) {
    final list = [
      "In the name of Allah, the Beneficent, the Merciful.",
      "Praise be to Allah, Lord of the Worlds,",
      "The Beneficent, the Merciful.",
      "Owner of the Day of Judgment,",
      "Thee alone we worship; Thee alone we ask for help.",
      "Show us the straight path,",
      "The path of those whom Thou hast favoured; Not the path of those who earn Thine anger nor of those who go astray.",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "";
  }

  String _getAlMulkArabic(int ayahNum) {
    final list = [
      "تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
      "الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ",
      "الَّذِي خَلَقَ سَبْعَ سَمَاوَاتٍ طِبَاقًا ۖ مَّا تَرَىٰ فِي خَلْقِ الرَّحْمَٰنِ مِن تَفَاوُتٍ ۖ فَارْجِعِ الْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍ",
      "ثُمَّ ارْجِعِ الْبَصَرَ كَرَّتَيْنِ يَنقَلِبْ إِلَيْكَ الْبَصَرُ خَاسِئًا وَهُوَ حَسِيرٌ",
      "وَلَقَدْ زَيَّنَّا السَّمَاءَ الدُّنْيَا بِمَصَابِيحَ وَجَعَلْنَاهَا رُجُومًا لِّلشَّيَاطِينِ ۖ وَأَعْتَدْنَا لَهُمْ عَذَابَ السَّعِيرِ",
      "وَلِلَّذِينَ كَفَرُوا بِرَبِّهِمْ عَذَابُ جَهَنَّمَ ۖ وَبِئْسَ الْمَصِيرُ",
      "إِذَا أُلْقُوا فِيهَا سَمِعُوا لَهَا شَهِيقًا وَهِيَ تَفُورُ",
      "تَكَادُ تَمَيَّزُ مِنَ الْغَيْظِ ۖ كُلَّمَا أُلْقِيَ فِيهَا فَوْجٌ سَأَلَهُمْ خَزَنَتُهَا أَلَمْ يَأْتِكُمْ نَذِيرٌ",
      "قَالُوا بَلَىٰ قَدْ جَاءَنَا نَذِيرٌ فَكَذَّبْنَا وَقُلْنَا مَا نَزَّلَ اللَّهُ مِن شَيْءٍ إِنْ أَنتُمْ إِلَّا فِي ضَلَالٍ كَبِيرٍ",
      "وَقَالُوا لَوْ كُنَّا نَسْمَعُ أَوْ نَعْقِلُ مَا كُنَّا فِي أَصْحَابِ السَّعِيرِ",
      "فَاعْتَرَفُوا بِذَنبِهِمْ فَسُحْقًا لِّأَصْحَابِ السَّعِيرِ",
      "إِنَّ الَّذِينَ يَخْشَوْنَ رَبَّهُم بِالْغَيْبِ لَهُم مَّغْفِرَةٌ وَأَجْرٌ كَبِيرٌ",
      "وَأَسِرُّوا قَوْلَكُمْ أَوِ اجْهَرُوا بِهِ ۖ إِنَّهُ عَلِيمٌ بِذَاتِ الصُّدُورِ",
      "أَلَا يَعْلَمُ مَنْ خَلَقَ وَهُوَ اللَّطِيفُ الْخَبِيرُ",
      "هُوَ الَّذِي جَعَلَ لَكُمُ الْأَرْضَ ذَلُولًا فَامْشُوا فِي مَنَاكِبِهَا وَكُلُوا مِن رِّزْقِهِ ۖ وَإِلَيْهِ النُّشُورُ",
      "أَأَمِنتُم مَّن فِي السَّمَاءِ أَن يَخْسِفَ بِكُمُ الْأَرْضَ فَإِذَا هِيَ تَمُمرُ",
      "أَمْ أَمِنتُم مَّن فِي السَّمَاءِ أَن يُرْسِلَ عَلَيْكُمْ حَاصِبًا ۖ فَسَتَعْلَمُونَ كَيْفَ نَذِيرِ",
      "وَلَقَدْ كَذَّبَ الَّذِينَ مِن قَبْلِهِمْ فَكَيْفَ كَانَ نَكِيرِ",
      "أَوَلَمْ يَرَوْا إِلَى الطَّيْرِ فَوْقَهُمْ صَافَّاتٍ وَيَقْبِضْنَ ۚ مَا يُمْسِكُهُنَّ إِلَّا الرَّحْمَٰنُ ۚ إِنَّهُ بِكُلِّ شَيْءٍ بَصِيرٌ",
      "أَمَّنْ هَٰذَا الَّذِي هُوَ جُندٌ لَّكُمْ يَنصُرُكُم مِّن دُونِ الرَّحْمَٰنِ ۚ إِنِ الْكَافِرُونَ إِلَّا فِي غُرُورٍ",
      "أَمَّنْ هَٰذَا الَّذِي يَرْزُقُكُمْ إِنْ أَمْسَكَ رِزْقَهُ ۚ بَل لَّجُّوا فِي عُتُوٍّ وَنُفُورٍ",
      "أَفَمَن يَمْشِي مُكِبًّا عَلَىٰ وَجْهِهِ أَهْدَىٰ أَمَّن يَمْشِي سَوِيًّا عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ",
      "قُلْ هُوَ الَّذِي أَنشَأَكُمْ وَجَعَلَ لَكُمُ السَّمْعَ وَالْأَبْصَارَ وَالْأَفْئِدَةَ ۖ قَلِيلًا مَّا تَشْكُرُونَ",
      "قُلْ هُوَ الَّذِي ذَرَأَكُمْ فِي الْأَرْضِ وَإِلَيْهِ تُحْشَرُونَ",
      "وَيَقُولُونَ مَتَىٰ هَٰذَا الْوَعْدُ إِن كُنتُمْ صَادِقِينَ",
      "قُلْ إِنَّمَا الْعِلْمُ عِندَ اللَّهِ وَإِنَّمَا أَنَا نَذِيرٌ مُّبِينٌ",
      "فَلَمَّا رَأَوْهُ زُلْفَةً سِيئَتْ وُجُوهُ الَّذِينَ كَفَرُوا وَقِيلَ هَٰذَا الَّذِي كُنتُم بِهِ تَدَّعُونَ",
      "قُلْ أَرَأَيْتُمْ إِنْ أَهْلَكَنِيَ اللَّهُ وَمَن مَّعِيَ أَوْ رَحِمَنَا فَمَن يُجِيرُ الْكَافِرِينَ مِنْ عَذَابٍ أَلِيمٍ",
      "قُلْ هُوَ الرَّحْمَٰنُ آمَنَّا بِهِ وَعَلَيْهِ تَوَكَّلْنَا ۖ فَسَتَعْلَمُونَ مَنْ هُوَ فِي ضَلَالٍ مُّبِينٍ",
      "قُلْ أَرَأَيْتُمْ إِنْ أَصْبَحَ مَاؤُكُمْ غَوْرًا فَمَن يَأْتِيكُم بِمَاءٍ مَّعِينٍ",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "آية غير متوفرة";
  }

  String _getAlMulkTranslation(int ayahNum) {
    final list = [
      "Blessed is He in Whose hand is the Sovereignty, and, He is Able to do all things.",
      "Who hath created life and death that He may try you, which of you is best in conduct; and He is the Mighty, the Forgiving,",
      "Who hath created seven heavens in harmony. Thou canst see no fault in the Beneficent One's creation; then look again: Canst thou see any rifts?",
      "Then look again and yet again, thy sight will return unto thee weakened and made dim.",
      "And We have adorned the lowest heaven with lamps, and We have made them missiles for the devils, and for them We have prepared the doom of flame.",
      "And for those who disbelieve in their Lord there is the doom of hell, a hapless journey's end!",
      "When they are flung therein they hear it sighing as it boileth up,",
      "As it would burst with rage. Whenever a host is flung therein the wardens thereof ask them: Came there no warner unto you?",
      "They say: Yea, verily, a warner came unto us; but we denied and said: Allah hath revealed nothing; ye are in nought but a great error.",
      "And they say: Had we been wont to listen or have sense, we had not been among the dwellers in the flames.",
      "So they confess their sins. A far removal for the dwellers in the flames!",
      "Lo! those who fear their Lord in secret, theirs will be forgiveness and a great reward.",
      "And keep your opinion secret or proclaim it, lo! He is Knower of all that is in the breasts.",
      "Should He not know Who created? And He is the Subtile, the Aware.",
      "He it is Who hath made the earth subservient unto you, so walk in the paths thereof and eat of His providence. And unto Him will be the resurrection.",
      "Have ye taken security that He Who is in the heaven will not cause the earth to swallow you when lo! it is shaking?",
      "Or have ye taken security that He Who is in the heaven will not send against you a hurricane? But ye will know the truth of My warning.",
      "And verily those before them denied, then how was My abhorrence!",
      "Have they not seen the birds above them, spreading out their wings and shrinking them? Nought upholdeth them save the Beneficent. Lo! He is Seer of all things.",
      "Or who is he that will be an army for you to help you against the Beneficent? The disbelievers are in nought but illusion.",
      "Or who is he that will provide for you if He should withhold His providence? Nay, but they are set in pride and frowardness.",
      "Is he who goeth grovelling on his face more rightly guided, or he who walketh upright on a straight road?",
      "Say (unto them, O Muhammad): He it is Who gave you being, and attributed unto you ears and eyes and hearts. Small thanks give ye!",
      "Say: He it is Who hath multiplied you in the earth, and unto Him ye will be gathered.",
      "And they say: When will this promise be, if ye are truthful?",
      "Say: The knowledge is with Allah only, and I am but a plain warner.",
      "But when they see it nigh, the faces of those who disbelieve will be awry, and it will be said (unto them): This is that which ye used to call for.",
      "Say: Have ye thought: Whether Allah cause me to perish and those with me, or have mercy on us, who will protect the disbelievers from a painful doom?",
      "Say: He is the Beneficent. In Him we believe and in Him we put our trust. And ye will soon know who it is that is in error manifest.",
      "Say: Have ye thought: If your water were to disappear into the earth, who then could bring you gushing water?",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "";
  }

  String _getAlBaqarahArabic(int ayahNum) {
    final list = [
      "الم",
      "ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ",
      "الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ",
      "وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ",
      "أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ",
      "إِنَّ الَّذِينَ كَفَرُوا سَوَاءٌ عَلَيْهِمْ أَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ",
      "خَتَمَ اللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰ أَبْصَارِهِمْ غِشَاوَةٌ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌ",
      "وَمِنَ النَّاسِ مَن يَقُولُ آمَنَّا بِاللَّهِ وَبِالْيَوْمِ الْآخِرِ وَمَا هُم بِمُؤْمِنِينَ",
      "يُخَادِعُونَ اللَّهَ وَالَّذِينَ آمَنُوا وَمَا يَخْدَعُونَ إِلَّا أَنفُسَهُمْ وَمَا يَشْعُرُونَ",
      "فِي قُلُوبِهِم مَّرَضٌ فَزَادَهُمُ اللَّهُ مَرَضًا ۖ وَلَهُمْ عَذَابٌ أَلِيمٌ بِمَا كَانُوا يَكْذِبُونَ",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "";
  }

  String _getAlBaqarahTranslation(int ayahNum) {
    final list = [
      "Alif. Lam. Mim.",
      "This is the Scripture whereof there is no doubt, a guidance unto those who ward off (evil);",
      "Who believe in the Unseen, and establish worship, and spend of that We have bestowed upon them;",
      "And who believe in that which is revealed unto thee (Muhammad) and that which was revealed before thee, and are certain of the Hereafter.",
      "These depend on guidance from their Lord. These are the successful.",
      "As for the Disbelievers, Whether thou warn them or thou warn them not, it is all one for them; they believe not.",
      "Allah hath sealed their hearing and their hearts, and on their eyes there is a covering. Theirs will be an awful doom.",
      "And of mankind are some who say: We believe in Allah and the Last Day, when they believe not.",
      "They think to beguile Allah and those who believe, and they beguile none save themselves; but they perceive not.",
      "In their hearts is a disease, and Allah increaseth their disease. A painful doom is theirs because they lie.",
    ];
    return ayahNum <= list.length ? list[ayahNum - 1] : "";
  }

  void _initializeSurahsList() {
    final List<Map<String, dynamic>> surahs = [
      {
        'number': 1,
        'name': 'الفاتحة',
        'englishName': 'Al-Fatihah',
        'ayahs': 7,
        'type': 'Meccan',
        'juz': 1,
      },
      {
        'number': 2,
        'name': 'البقرة',
        'englishName': 'Al-Baqarah',
        'ayahs': 286,
        'type': 'Medinan',
        'juz': 1,
      },
      {
        'number': 3,
        'name': 'آل عمران',
        'englishName': 'Al-Imran',
        'ayahs': 200,
        'type': 'Medinan',
        'juz': 3,
      },
      {
        'number': 4,
        'name': 'النساء',
        'englishName': 'An-Nisa',
        'ayahs': 176,
        'type': 'Medinan',
        'juz': 4,
      },
      {
        'number': 5,
        'name': 'المائدة',
        'englishName': 'Al-Ma\'idah',
        'ayahs': 120,
        'type': 'Medinan',
        'juz': 6,
      },
      {
        'number': 6,
        'name': 'الأنعام',
        'englishName': 'Al-An\'am',
        'ayahs': 165,
        'type': 'Meccan',
        'juz': 7,
      },
      {
        'number': 7,
        'name': 'الأعراف',
        'englishName': 'Al-A\'raf',
        'ayahs': 206,
        'type': 'Meccan',
        'juz': 8,
      },
      {
        'number': 8,
        'name': 'الأنفال',
        'englishName': 'Al-Anfal',
        'ayahs': 75,
        'type': 'Medinan',
        'juz': 9,
      },
      {
        'number': 9,
        'name': 'التوبة',
        'englishName': 'At-Tawbah',
        'ayahs': 129,
        'type': 'Medinan',
        'juz': 10,
      },
      {
        'number': 10,
        'name': 'يونس',
        'englishName': 'Yunus',
        'ayahs': 109,
        'type': 'Meccan',
        'juz': 11,
      },
      {
        'number': 11,
        'name': 'هود',
        'englishName': 'Hud',
        'ayahs': 123,
        'type': 'Meccan',
        'juz': 12,
      },
      {
        'number': 12,
        'name': 'يوسف',
        'englishName': 'Yusuf',
        'ayahs': 111,
        'type': 'Meccan',
        'juz': 12,
      },
      {
        'number': 36,
        'name': 'يس',
        'englishName': 'Ya-Sin',
        'ayahs': 83,
        'type': 'Meccan',
        'juz': 22,
      },
      {
        'number': 55,
        'name': 'الرحمن',
        'englishName': 'Ar-Rahman',
        'ayahs': 78,
        'type': 'Medinan',
        'juz': 27,
      },
      {
        'number': 56,
        'name': 'الواقعة',
        'englishName': 'Al-Waqi\'ah',
        'ayahs': 96,
        'type': 'Meccan',
        'juz': 27,
      },
      {
        'number': 67,
        'name': 'الملك',
        'englishName': 'Al-Mulk',
        'ayahs': 30,
        'type': 'Meccan',
        'juz': 29,
      },
      {
        'number': 112,
        'name': 'الإخلاص',
        'englishName': 'Al-Ikhlas',
        'ayahs': 4,
        'type': 'Meccan',
        'juz': 30,
      },
      {
        'number': 113,
        'name': 'الفلق',
        'englishName': 'Al-Falaq',
        'ayahs': 5,
        'type': 'Meccan',
        'juz': 30,
      },
      {
        'number': 114,
        'name': 'الناس',
        'englishName': 'An-Nas',
        'ayahs': 6,
        'type': 'Meccan',
        'juz': 30,
      },
    ];
    allSurahsList.assignAll(surahs);
    filteredSurahsList.assignAll(surahs);
  }

  void filterSurahs(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSurahsList.assignAll(allSurahsList);
    } else {
      filteredSurahsList.assignAll(
        allSurahsList
            .where(
              (surah) =>
                  surah['englishName'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  surah['name'].toString().contains(query) ||
                  surah['number'].toString() == query,
            )
            .toList(),
      );
    }
  }

  Future<void> _loadDownloadedSurahsKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('downloaded_surahs_keys') ?? [];
    downloadedSurahKeys.assignAll(keys);
  }

  Future<String> _getLocalAyahFilePath(
    int surahNum,
    String reciterId,
    int globalAyahNumber,
  ) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/downloads/recitations/$reciterId/$surahNum/$globalAyahNumber.mp3';
  }

  String _getReciterNameFromId(String id) {
    switch (id) {
      case 'ar.abdurrahmaansudais':
        return 'Abdul Rahman';
      case 'ar.shaatree':
        return 'Abu Bakr Al-Shatri';
      case 'ar.husary':
        return 'Mahmoud Husary';
      case 'ar.mahermuaiqly':
        return 'Maher Al-Muaiqly';
      case 'ar.alafasy':
        return 'Mishary Al-Afasy';
      case 'ar.ahmedajamy':
        return 'Ahmed Ajamy';
      case 'female.mariaulfah':
        return 'Female Reciter (Maria Ulfah)';
      default:
        return 'Mishary Al-Afasy';
    }
  }

  Future<double> _getSurahDirectorySize(int surahNum, String reciterId) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dirPath =
          '${appDocDir.path}/downloads/recitations/$reciterId/$surahNum';
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        int totalSize = 0;
        await for (final file in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
        return totalSize / (1024 * 1024);
      }
    } catch (e) {
      debugPrint("Error calculating size: $e");
    }
    return 0.0;
  }

  Future<List<Map<String, dynamic>>> getDownloadedSurahsList() async {
    final list = <Map<String, dynamic>>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('downloaded_surahs_keys') ?? [];

      for (final key in keys) {
        final parts = key.split('_');
        if (parts.length == 2) {
          final surahNum = int.tryParse(parts[0]) ?? 1;
          final reciterId = parts[1];

          final surahInfo = allSurahsList.firstWhere(
            (element) => element['number'] == surahNum,
            orElse: () => {
              'englishName': 'Surah $surahNum',
              'name': 'سورة',
              'ayahs': 0,
            },
          );

          final reciterName = _getReciterNameFromId(reciterId);
          final size = await _getSurahDirectorySize(surahNum, reciterId);

          list.add({
            'key': key,
            'surahNumber': surahNum,
            'englishName': surahInfo['englishName'],
            'name': surahInfo['name'],
            'ayahsCount': surahInfo['ayahs'],
            'reciterId': reciterId,
            'reciterName': reciterName,
            'size': size,
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching downloads: $e");
    }
    return list;
  }

  Future<void> deleteDownloadedSurah(int surahNum, String reciterId) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dirPath =
          '${appDocDir.path}/downloads/recitations/$reciterId/$surahNum';
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final key = '${surahNum}_$reciterId';
      downloadedSurahKeys.remove(key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'downloaded_surahs_keys',
        downloadedSurahKeys.toList(),
      );

      Get.snackbar(
        'Download Removed',
        'Offline audio removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error deleting downloaded surah: $e");
      Get.snackbar(
        'Deletion Error',
        'Failed to remove downloaded surah.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> downloadCurrentSurah() async {
    if (currentSurah.value == null) {
      Get.snackbar(
        'Download Error',
        'No Surah is currently active to download.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    if (isDownloading.value) {
      Get.snackbar(
        'Download in Progress',
        'Please wait for the current download to finish.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final surah = currentSurah.value!;
    final surahNum = surah.number;
    final reciterId = getReciterIdentifier(selectedReciter.value);

    if (reciterId == 'female.mariaulfah') {
      Get.snackbar(
        'Download Unavailable',
        "Offline downloads for Female Reciters are currently not supported since public CDNs do not host their recordings. Qari24/7 is working to host high-quality female recitations in a future release!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1C1C1E),
        colorText: Colors.white,
      );
      return;
    }

    final key = '${surahNum}_$reciterId';

    if (downloadedSurahKeys.contains(key)) {
      Get.snackbar(
        'Already Downloaded',
        '${surah.englishName} has already been downloaded for ${selectedReciter.value}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;
    downloadProgressText.value = 'Starting download...';

    try {
      final client = dio.Dio();

      final bitrate = (reciterId == 'ar.abdurrahmaansudais') ? '192' : '128';
      final ayahs = surah.ayahs;

      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        final audioUrl =
            'https://cdn.islamic.network/quran/audio/$bitrate/$reciterId/${ayah.number}.mp3';
        final localPath = await _getLocalAyahFilePath(
          surahNum,
          reciterId,
          ayah.number,
        );

        final file = File(localPath);
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }

        downloadProgressText.value =
            'Downloading verse ${i + 1} of ${ayahs.length}...';
        await client.download(audioUrl, localPath);

        downloadProgress.value = (i + 1) / ayahs.length;
      }

      downloadedSurahKeys.add(key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'downloaded_surahs_keys',
        downloadedSurahKeys.toList(),
      );

      Get.snackbar(
        'Download Completed',
        'Surah Al-${surah.englishName} downloaded successfully for offline listening!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F3A27),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint("Error downloading Surah: $e");
      Get.snackbar(
        'Download Failed',
        'An error occurred while downloading the audio files. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
      downloadProgressText.value = '';
    }
  }

  final stt.SpeechToText _searchSpeech = stt.SpeechToText();
  var isVoiceSearching = false.obs;

  Future<void> startVoiceSearch(
    TextEditingController searchFieldController,
  ) async {
    if (isVoiceSearching.value) {
      isVoiceSearching.value = false;
      await _searchSpeech.stop();
      return;
    }

    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _searchSpeech.initialize(
          onStatus: (val) {
            debugPrint('[VoiceSearch] Status: $val');
            if (val == 'notListening' || val == 'done') {
              isVoiceSearching.value = false;
            }
          },
          onError: (val) {
            debugPrint('[VoiceSearch] Error: $val');
            isVoiceSearching.value = false;
            Get.snackbar(
              'voice_search'.tr,
              'Voice search error: ${val.errorMsg}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade900,
              colorText: Colors.white,
            );
          },
        );

        if (available) {
          isVoiceSearching.value = true;
          Get.snackbar(
            'voice_search'.tr,
            'listening_search'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          await _searchSpeech.listen(
            listenOptions: stt.SpeechListenOptions(
              localeId: Get.locale?.toString() ?? 'ar-SA',
            ),
            onResult: (val) {
              searchFieldController.text = val.recognizedWords;
              filterSurahs(val.recognizedWords);
              if (val.finalResult) {
                isVoiceSearching.value = false;
                _searchSpeech.stop();
              }
            },
          );
        } else {
          Get.snackbar(
            'voice_search'.tr,
            'Speech recognition is unavailable on this device.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Microphone permission is required for voice search.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[VoiceSearch] Exception: $e');
      isVoiceSearching.value = false;
    }
  }

  final RxList<int> savedSurahNumbers = <int>[].obs;

  Future<void> loadSavedSurahs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('saved_surahs') ?? [];
      savedSurahNumbers.assignAll(savedList.map((e) => int.parse(e)).toList());
      debugPrint("[SavedSurahs] Loaded bookmarked surahs: $savedSurahNumbers");
    } catch (e) {
      debugPrint("[SavedSurahs] Error loading: $e");
    }
  }

  Future<void> toggleSaveSurah(int surahNum) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (savedSurahNumbers.contains(surahNum)) {
        savedSurahNumbers.remove(surahNum);
        Get.snackbar(
          'saved'.tr,
          'Removed Surah from saved list.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      } else {
        savedSurahNumbers.add(surahNum);
        Get.snackbar(
          'saved'.tr,
          'Added Surah to saved list successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F3A27),
          colorText: Colors.white,
        );
      }
      await prefs.setStringList(
        'saved_surahs',
        savedSurahNumbers.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint("[SavedSurahs] Error toggling: $e");
    }
  }

  bool isSurahSaved(int surahNum) {
    return savedSurahNumbers.contains(surahNum);
  }
}
