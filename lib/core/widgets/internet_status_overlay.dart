import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';

class InternetStatusOverlay extends StatefulWidget {
  const InternetStatusOverlay({super.key});

  @override
  State<InternetStatusOverlay> createState() => _InternetStatusOverlayState();
}

class _InternetStatusOverlayState extends State<InternetStatusOverlay>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  StreamSubscription<bool>? _subscription;

  bool _showOverlay = false;
  String _status = 'none';
  bool _wasOffline = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_connectivityService.isConnected.value) {
        setState(() {
          _showOverlay = true;
          _status = 'offline';
          _wasOffline = true;
        });
      }

      _subscription = _connectivityService.isConnected.listen((isConnected) {
        _handleConnectionChange(isConnected);
      });
    });
  }

  void _handleConnectionChange(bool isConnected) {
    _dismissTimer?.cancel();
    if (!isConnected) {
      setState(() {
        _showOverlay = true;
        _status = 'offline';
        _wasOffline = true;
      });
    } else {
      if (_wasOffline) {
        setState(() {
          _status = 'restored';
        });

        _dismissTimer = Timer(const Duration(milliseconds: 2500), () {
          if (mounted && _connectivityService.isConnected.value) {
            setState(() {
              _showOverlay = false;
              _wasOffline = false;
            });
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted && !_showOverlay) {
                setState(() {
                  _status = 'none';
                });
              }
            });
          }
        });
      } else {
        setState(() {
          _showOverlay = false;
          _status = 'none';
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'none') return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    final isOffline = _status == 'offline';

    final cardBgColor = isOffline
        ? (isDark
              ? const Color(0xFF2D0E0E).withValues(alpha: 0.65)
              : const Color(0xFFFDF2F2).withValues(alpha: 0.85))
        : (isDark
              ? const Color(0xFF0F2D19).withValues(alpha: 0.65)
              : const Color(0xFFF0FDF4).withValues(alpha: 0.85));

    final borderColor = isOffline
        ? (isDark
              ? Colors.red.withValues(alpha: 0.25)
              : Colors.red.withValues(alpha: 0.15))
        : (isDark
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.green.withValues(alpha: 0.15));

    final iconColor = isOffline ? Colors.redAccent : Colors.greenAccent[700];

    final titleText = isOffline
        ? "no_connection_title".tr
        : "connection_restored_title".tr;
    final subtitleText = isOffline
        ? "no_connection_subtitle".tr
        : "connection_restored_subtitle".tr;

    final displayTitle = titleText == "no_connection_title"
        ? (isOffline ? "No Internet Connection" : "Connection Restored!")
        : titleText;
    final displaySubtitle = subtitleText == "no_connection_subtitle"
        ? (isOffline
              ? "Check your network settings. Retrying..."
              : "You are back online.")
        : subtitleText;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      top: _showOverlay ? topPadding + 16 : -120,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _showOverlay ? 1.0 : 0.0,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isOffline
                      ? Colors.red.withValues(alpha: isDark ? 0.08 : 0.04)
                      : Colors.green.withValues(alpha: isDark ? 0.08 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOffline
                              ? Colors.red.withValues(
                                  alpha: isDark ? 0.15 : 0.08,
                                )
                              : Colors.green.withValues(
                                  alpha: isDark ? 0.15 : 0.08,
                                ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOffline
                              ? Icons.wifi_off_rounded
                              : Icons.wifi_rounded,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTitle,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displaySubtitle,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isOffline)
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withValues(
                                  alpha: _pulseAnimation.value,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.4 * _pulseAnimation.value,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent[400],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent[400]!.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
