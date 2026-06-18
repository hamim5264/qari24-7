import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class RecitationAIService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSessionActive = false;
  bool _isCycling = false;

  List<Map<String, dynamic>>? _fullSurahAyahs;

  Function(Map<String, dynamic> feedback)? _onFeedbackReceived;
  Function(dynamic error)? _onError;
  Function()? _onDone;

  int _currentAyahListIndex = 0;

  final Set<String> _sentFeedbacks = {};

  final Map<int, String> _lastEmittedStatuses = {};

  int _totalSpokenWordsConsumed = 0;

  int _lastMaxSpkIdx = -1;

  Timer? _listeningTimeoutTimer;

  bool get isSessionActive => _isSessionActive;

  String normalizeArabic(String text) {
    if (text.isEmpty) return "";

    var normalized = text.toLowerCase();

    // 1. Handle Ya Maqsura followed by superscript alef (e.g. تَرَىٰ) -> normalize to just Ya/Alef Maqsura
    normalized = normalized.replaceAll('\u0649\u0670', '\u0649'); // ىٰ -> ى

    // 2. Replace other superscript alefs (\u0670) with normal alef (\u0627)
    normalized = normalized.replaceAll('\u0670', '\u0627');

    normalized = normalized.replaceAll(RegExp(r'[a-zA-Z0-9]'), '');

    // Tashkeel
    final tashkeel = RegExp(r'[\u064B-\u0652\u0653\u0654\u0655\u0640]');
    normalized = normalized.replaceAll(tashkeel, '');

    normalized = normalized.replaceAll(RegExp(r'[إأآٱ]'), 'ا');

    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ی', 'ي');

    normalized = normalized.replaceAll('ک', 'ك');

    normalized = normalized.replaceAll('ة', 'ه');

    normalized = normalized.replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '');

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // 3. Specific exceptions like الرحمان -> الرحمن
    var words = normalized.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i] == 'الرحمان') {
        words[i] = 'الرحمن';
      }
    }
    normalized = words.join(' ');

    return normalized.trim();
  }

  int getLevenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) {
      return getLevenshteinDistance(s2, s1);
    }
    if (s2.isEmpty) {
      return s1.length;
    }

    List<int> previousRow = List<int>.generate(s2.length + 1, (i) => i);
    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];
      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] != s2[j] ? 1 : 0);
        currentRow.add(min(insertions, min(deletions, substitutions)));
      }
      previousRow = currentRow;
    }
    return previousRow.last;
  }

  bool isSimilar(String w1, String w2) {
    final w1Clean = normalizeArabic(w1);
    final w2Clean = normalizeArabic(w2);
    if (w1Clean.isEmpty || w2Clean.isEmpty) return false;
    if (w1Clean == w2Clean) return true;

    final dist = getLevenshteinDistance(w1Clean, w2Clean);
    final maxLength = max(w1Clean.length, w2Clean.length);
    if (maxLength >= 7) {
      return dist <= 2;
    }
    return dist <= 1;
  }

  Future<void> startRecitationSession({
    required String serverUrl,
    required String ayahText,
    required int surahNumber,
    required int ayahNumber,
    List<Map<String, dynamic>>? fullSurahAyahs,
    required Function(Map<String, dynamic> feedback) onFeedbackReceived,
    required Function(dynamic error) onError,
    required Function() onDone,
  }) async {
    if (_isSessionActive) {
      await stopSession();
    }

    _fullSurahAyahs = fullSurahAyahs;
    _onFeedbackReceived = onFeedbackReceived;
    _onError = onError;
    _onDone = onDone;

    _sentFeedbacks.clear();
    _lastEmittedStatuses.clear();
    _totalSpokenWordsConsumed = 0;
    _lastMaxSpkIdx = -1;

    _currentAyahListIndex = 0;
    if (_fullSurahAyahs != null) {
      for (int i = 0; i < _fullSurahAyahs!.length; i++) {
        if (_fullSurahAyahs![i]["ayah_number"] == ayahNumber) {
          _currentAyahListIndex = i;
          break;
        }
      }
    }

    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (!status.isGranted) {
        onError("Microphone permission denied.");
        return;
      }

      debugPrint(
        "[RecitationAIService] Initializing native speech recognizer...",
      );
      bool available = await _speech.initialize(
        onError: (speechError) {
          debugPrint(
            "[RecitationAIService] Native speech error: ${speechError.errorMsg}",
          );
          final fatalErrors = {
            "error_audio",
            "error_permission",
            "error_insufficient_permissions",
          };

          if (fatalErrors.contains(speechError.errorMsg)) {
            onError(speechError.errorMsg);
            stopSession();
          } else {
            debugPrint(
              "[RecitationAIService] Transient or ignorable speech error occurred: ${speechError.errorMsg}",
            );
          }
        },
        onStatus: (status) {
          debugPrint("[RecitationAIService] Native speech status: $status");
          if (status == "notListening" && _isSessionActive) {
            _listeningTimeoutTimer?.cancel();
            _listeningTimeoutTimer = Timer(
              const Duration(milliseconds: 1000),
              () {
                if (_isSessionActive && !_speech.isListening) {
                  debugPrint(
                    "[RecitationAIService] Speech listener idle. Re-triggering microphone listener...",
                  );
                  _startSpeechListener();
                }
              },
            );
          }
        },
      );

      if (!available) {
        onError(
          "Speech recognition is not available or disabled on this device.",
        );
        return;
      }

      _isSessionActive = true;
      debugPrint(
        "[RecitationAIService] Native speech engine successfully active. Starting recording...",
      );
      _startSpeechListener();
    } catch (e) {
      debugPrint("[RecitationAIService] Exception starting session: $e");
      onError("Error starting recitation: $e");
      await stopSession();
    }
  }

  void _startSpeechListener() async {
    if (!_isSessionActive) return;

    _totalSpokenWordsConsumed = 0;
    _lastMaxSpkIdx = -1;

    try {
      const languageCode = "ar-SA";
      debugPrint(
        "[RecitationAIService] Listening active. Target locale: $languageCode",
      );

      await _speech.listen(
        onResult: (result) {
          if (!_isSessionActive || _isCycling) return;

          final spokenText = result.recognizedWords;
          debugPrint(
            "[RecitationAIService] Native ASR Raw Text: '$spokenText' (Final: ${result.finalResult})",
          );

          if (spokenText.isNotEmpty) {
            _processRecognizedText(spokenText);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 15),
          localeId: languageCode,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      debugPrint(
        "[RecitationAIService] Exception starting speech listener: $e",
      );
      if (_onError != null) {
        _onError!("Failed to start native microphone listener: $e");
      }
    }
  }

  void _processRecognizedText(String spokenText) async {
    if (!_isSessionActive ||
        _isCycling ||
        _fullSurahAyahs == null ||
        _currentAyahListIndex >= _fullSurahAyahs!.length) {
      return;
    }

    final ayahEntry = _fullSurahAyahs![_currentAyahListIndex];
    final int curAyahNum = ayahEntry["ayah_number"] ?? 0;
    final String curText = ayahEntry["text"] ?? "";

    final List<String> curWords = curText
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();

    final List<String> rawSpokenWords = spokenText
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (rawSpokenWords.isEmpty) return;

    List<String> spokenWords = rawSpokenWords;
    if (_totalSpokenWordsConsumed < rawSpokenWords.length) {
      spokenWords = rawSpokenWords.sublist(_totalSpokenWordsConsumed);
    } else if (rawSpokenWords.length < _totalSpokenWordsConsumed) {
      _totalSpokenWordsConsumed = 0;
      _lastMaxSpkIdx = -1;
      spokenWords = rawSpokenWords;
    } else {
      return;
    }

    if (spokenWords.isEmpty) return;

    final int N = curWords.length;
    final int M = spokenWords.length;

    final List<List<double>> dp = List.generate(
      N + 1,
      (_) => List<double>.filled(M + 1, 0.0),
    );

    for (int i = 0; i <= N; i++) {
      dp[i][0] = i * -1.5;
    }
    for (int j = 0; j <= M; j++) {
      dp[0][j] = j * -1.5;
    }

    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= M; j++) {
        final double matchScore =
            dp[i - 1][j - 1] +
            (isSimilar(curWords[i - 1], spokenWords[j - 1]) ? 2.0 : -1.0);
        final double deleteScore = dp[i - 1][j] - 1.5;
        final double insertScore = dp[i][j - 1] - 1.5;
        dp[i][j] = max(matchScore, max(deleteScore, insertScore));
      }
    }

    // Find the row index 'bestI' in the final column M that maximizes the alignment score
    int bestI = 0;
    double maxScore = -double.maxFinite;
    for (int i = 0; i <= N; i++) {
      if (dp[i][M] > maxScore) {
        maxScore = dp[i][M];
        bestI = i;
      }
    }

    int i = bestI;
    int j = M;
    final List<Map<String, dynamic>> alignment = [];

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final double score = dp[i][j];
        final double scoreDiag = dp[i - 1][j - 1];
        final bool similar = isSimilar(curWords[i - 1], spokenWords[j - 1]);
        final double stepScore = similar ? 2.0 : -1.0;

        if ((score - (scoreDiag + stepScore)).abs() < 1e-5) {
          alignment.add({
            "type": "align",
            "expIdx": i - 1,
            "spkIdx": j - 1,
            "word": curWords[i - 1],
            "spoken": spokenWords[j - 1],
          });
          i--;
          j--;
          continue;
        }
      }

      if (i > 0) {
        final double score = dp[i][j];
        final double scoreUp = dp[i - 1][j];
        if ((score - (scoreUp - 1.5)).abs() < 1e-5 || j == 0) {
          alignment.add({
            "type": "delete",
            "expIdx": i - 1,
            "word": curWords[i - 1],
          });
          i--;
          continue;
        }
      }

      if (j > 0) {
        alignment.add({
          "type": "insert",
          "spkIdx": j - 1,
          "spoken": spokenWords[j - 1],
        });
        j--;
      }
    }

    final List<Map<String, dynamic>> finalPath = alignment.reversed.toList();

    int maxAlignedExpIdx = -1;
    int maxAlignedSpkIdx = -1;
    for (var step in finalPath) {
      if (step["type"] == "align") {
        if (step["expIdx"] > maxAlignedExpIdx) {
          maxAlignedExpIdx = step["expIdx"];
        }
        if (step["spkIdx"] > maxAlignedSpkIdx) {
          maxAlignedSpkIdx = step["spkIdx"];
        }
      }
    }
    _lastMaxSpkIdx = maxAlignedSpkIdx;

    for (var step in finalPath) {
      if (step["type"] == "align") {
        final int expIdx = step["expIdx"];
        final String word = step["word"];
        final String spoken = step["spoken"];

        if (isSimilar(word, spoken)) {
          _sendFeedbackEvent(curAyahNum, expIdx, "correct", word);
        } else {
          final wordClean = normalizeArabic(word);
          final spokenClean = normalizeArabic(spoken);
          final dist = getLevenshteinDistance(wordClean, spokenClean);
          if (dist <= 2) {
            _sendFeedbackEvent(curAyahNum, expIdx, "minor_mistake", word);
          } else {
            _sendFeedbackEvent(curAyahNum, expIdx, "major_mistake", word);
          }
        }
      } else if (step["type"] == "delete") {
        final int expIdx = step["expIdx"];
        final String word = step["word"];

        if (expIdx < maxAlignedExpIdx) {
          _sendFeedbackEvent(curAyahNum, expIdx, "major_mistake", word);
        }
      }
    }

    final int curWordsCount = curWords.length;
    int correctCount = 0;
    _lastEmittedStatuses.forEach((idx, stat) {
      if (stat == "correct") {
        correctCount++;
      }
    });

    bool shouldAdvance = false;
    if (_lastEmittedStatuses[curWordsCount - 1] == "correct" &&
        correctCount >= curWordsCount / 2) {
      shouldAdvance = true;
    } else if (correctCount >= curWordsCount / 2 && maxAlignedExpIdx >= curWordsCount - 2) {
      final nextAyahListIndex = _currentAyahListIndex + 1;
      if (_fullSurahAyahs != null &&
          nextAyahListIndex < _fullSurahAyahs!.length) {
        final nextAyahEntry = _fullSurahAyahs![nextAyahListIndex];
        final String nextText = nextAyahEntry["text"] ?? "";
        final List<String> nextWords = nextText
            .split(RegExp(r'\s+'))
            .where((String w) => w.isNotEmpty)
            .toList();
        if (nextWords.isNotEmpty) {
          final String firstWordNext = nextWords[0];
          for (
            int k = max(0, spokenWords.length - 3);
            k < spokenWords.length;
            k++
          ) {
            if (isSimilar(firstWordNext, spokenWords[k])) {
              shouldAdvance = true;
              _lastMaxSpkIdx = k - 1;
              debugPrint(
                "[RecitationAIService] Next Ayah transition detected via first word: '$firstWordNext' at index $k of spokenWords",
              );
              break;
            }
          }
        }
      }
    }

    if (shouldAdvance) {
      _advanceAyahFlow();
    }
  }

  void _sendFeedbackEvent(
    int ayahNum,
    int wordIdx,
    String status,
    String wordText,
  ) {
    if (_lastEmittedStatuses[wordIdx] == "correct" && status != "correct") {
      return;
    }

    if (_lastEmittedStatuses[wordIdx] == status) {
      return;
    }

    _lastEmittedStatuses[wordIdx] = status;

    final payload = {
      "ayah_number": ayahNum,
      "word_index": wordIdx,
      "status": status,
      "word_text": wordText,
    };

    debugPrint(
      "[RecitationAIService] Native Feedback: Ayah $ayahNum word '$wordText' (Index $wordIdx) -> $status",
    );
    if (_onFeedbackReceived != null) {
      _onFeedbackReceived!(payload);
    }
  }

  void _advanceAyahFlow() async {
    if (_isCycling) return;

    final nextAyahListIndex = _currentAyahListIndex + 1;
    if (_fullSurahAyahs != null &&
        nextAyahListIndex < _fullSurahAyahs!.length) {
      debugPrint(
        "[RecitationAIService] Ayah complete. Progressing to next Ayah at list index $nextAyahListIndex.",
      );

      _isCycling = true;
      _currentAyahListIndex = nextAyahListIndex;

      if (_lastMaxSpkIdx != -1) {
        _totalSpokenWordsConsumed += _lastMaxSpkIdx + 1;
      }
      _lastMaxSpkIdx = -1;

      _sentFeedbacks.clear();
      _lastEmittedStatuses.clear();
      _isCycling = false;

      debugPrint(
        "[RecitationAIService] Progressed successfully. Continuous stream active for next verse.",
      );
    } else {
      debugPrint(
        "[RecitationAIService] Surah recitation range fully completed.",
      );
      stopSession();
      if (_onDone != null) {
        _onDone!();
      }
    }
  }

  Future<void> stopSession() async {
    if (!_isSessionActive) return;

    debugPrint("[RecitationAIService] Cleaning up local recitation session...");
    _isSessionActive = false;
    _isCycling = false;
    _listeningTimeoutTimer?.cancel();

    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
    } catch (e) {
      debugPrint("[RecitationAIService] Exception stopping speech: $e");
    }

    _onFeedbackReceived = null;
    _onError = null;
    _onDone = null;
    _fullSurahAyahs = null;
    _sentFeedbacks.clear();
    _lastEmittedStatuses.clear();
    _totalSpokenWordsConsumed = 0;
    _lastMaxSpkIdx = -1;

    debugPrint("[RecitationAIService] Local session cleanly disposed.");
  }
}
