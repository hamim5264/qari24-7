import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/book_model.dart';
import '../../../core/constants/app_colors.dart';

class AudioPlayerScreen extends StatefulWidget {
  final LibraryItemModel item;
  final String localPath;

  const AudioPlayerScreen({
    super.key,
    required this.item,
    required this.localPath,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;

  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;
  final Rx<PlayerState> _playerState = PlayerState.stopped.obs;
  final RxDouble _volume = 1.0.obs;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _initPlayerListeners();
    _startPlayback();
  }

  void _initPlayerListeners() {
    _audioPlayer.onPositionChanged.listen((p) {
      _position.value = p;
    });

    _audioPlayer.onDurationChanged.listen((d) {
      _duration.value = d;
    });

    _audioPlayer.onPlayerStateChanged.listen((s) {
      _playerState.value = s;
      if (s == PlayerState.playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  Future<void> _startPlayback() async {
    final File localFile = File(widget.localPath);
    final bool useLocalFile =
        widget.item.isDownloaded.value && localFile.existsSync();

    try {
      if (useLocalFile) {
        await _audioPlayer.play(DeviceFileSource(widget.localPath));
      } else if (widget.item.fileUrl != null &&
          widget.item.fileUrl!.isNotEmpty) {
        await _audioPlayer.play(UrlSource(widget.item.fileUrl!));
      } else {
        Get.snackbar("Error", "Audio URL not available.");
      }
    } catch (e) {
      Get.snackbar(
        "Error Playing Audio",
        e.toString(),
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    if (_playerState.value == PlayerState.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  void _seekForward() {
    final current = _position.value;
    final target = current + const Duration(seconds: 10);
    if (target < _duration.value) {
      _audioPlayer.seek(target);
    } else {
      _audioPlayer.seek(_duration.value);
    }
  }

  void _seekBackward() {
    final current = _position.value;
    final target = current - const Duration(seconds: 10);
    if (target > Duration.zero) {
      _audioPlayer.seek(target);
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.7);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Large Background Image (Cover Art)
          Positioned.fill(
            child: widget.item.coverUrl.isNotEmpty
                ? Image.network(widget.item.coverUrl, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF062A1B), const Color(0xFF03160E)]
                            : [
                                const Color(0xFFC8E6C9),
                                const Color(0xFFE8F5E9),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
          ),

          // 2. Glassmorphic Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(color: overlayColor),
            ),
          ),

          // 3. Player UI Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: textColor,
                          size: 22,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        "NOW PLAYING",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(
                        width: 48,
                      ), // Spacer to balance back button
                    ],
                  ),
                  const Spacer(),

                  // Rotating Album Art
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: widget.item.coverUrl.isNotEmpty
                            ? Image.network(
                                widget.item.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Image.asset(
                                  'assets/images/qari_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/qari_logo.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    widget.item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),

                  const Spacer(),

                  // Slider and Timestamps
                  Obx(() {
                    final double progress = _duration.value.inMilliseconds > 0
                        ? _position.value.inMilliseconds /
                              _duration.value.inMilliseconds
                        : 0.0;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: textColor.withValues(
                              alpha: 0.15,
                            ),
                            thumbColor: AppColors.primary,
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (val) {
                              final targetMs =
                                  (val * _duration.value.inMilliseconds)
                                      .toInt();
                              _audioPlayer.seek(
                                Duration(milliseconds: targetMs),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position.value),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                _formatDuration(_duration.value),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  // Controls
                  Obx(() {
                    final isPlaying = _playerState.value == PlayerState.playing;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.replay_10,
                            size: 36,
                            color: textColor,
                          ),
                          onPressed: _seekBackward,
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            Icons.forward_10,
                            size: 36,
                            color: textColor,
                          ),
                          onPressed: _seekForward,
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  // Volume Controls
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volume_down,
                          size: 18,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                        SizedBox(
                          width: 120,
                          child: Slider(
                            value: _volume.value,
                            onChanged: (val) {
                              _volume.value = val;
                              _audioPlayer.setVolume(val);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Icon(
                          Icons.volume_up,
                          size: 18,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
