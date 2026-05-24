import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_model.dart';
import '../../../core/constants/app_colors.dart';

class QariReaderScreen extends StatefulWidget {
  final BookModel book;

  const QariReaderScreen({super.key, required this.book});

  @override
  State<QariReaderScreen> createState() => _QariReaderScreenState();
}

class _QariReaderScreenState extends State<QariReaderScreen> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 1.obs;
  final RxDouble _fontSize = 16.0.obs;
  final RxString _readerTheme = 'sepia'.obs;
  final RxBool _showControls = true.obs;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = _readerTheme.value;

      Color readerBg;
      Color textColor;
      Color accentColor;
      Color controlBg;
      Brightness systemUiBrightness;

      if (theme == 'white') {
        readerBg = Colors.white;
        textColor = const Color(0xFF1E1E1E);
        accentColor = AppColors.primary;
        controlBg = const Color(0xFFF5F5F7).withValues(alpha: 0.95);
        systemUiBrightness = Brightness.dark;
      } else if (theme == 'dark') {
        readerBg = const Color(0xFF0F0F0F);
        textColor = const Color(0xFFE2E2E6);
        accentColor = AppColors.secondary;
        controlBg = const Color(0xFF1C1C1E).withValues(alpha: 0.95);
        systemUiBrightness = Brightness.light;
      } else {
        readerBg = const Color(0xFFFBF0D9);
        textColor = const Color(0xFF3E2723);
        accentColor = const Color(0xFF7B5E43);
        controlBg = const Color(0xFFF4E5C3).withValues(alpha: 0.95);
        systemUiBrightness = Brightness.dark;
      }

      return Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: systemUiBrightness,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: readerBg,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => _showControls.toggle(),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (pageIndex) {
                    _currentPage.value = pageIndex + 1;
                  },
                  itemCount: widget.book.pages.length,
                  itemBuilder: (context, index) {
                    final pageHtml = widget.book.pages[index];
                    return SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_renderFormattedText(pageHtml, textColor)],
                        ),
                      ),
                    );
                  },
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                top: _showControls.value ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 12),
                  decoration: BoxDecoration(
                    color: controlBg,
                    border: Border(
                      bottom: BorderSide(
                        color: textColor.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: textColor,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Text(
                          widget.book.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.text_format,
                          color: textColor,
                          size: 24,
                        ),
                        onPressed: () => _showSettingsSheet(
                          context,
                          textColor,
                          controlBg,
                          readerBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: _showControls.value ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  decoration: BoxDecoration(
                    color: controlBg,
                    border: Border(
                      top: BorderSide(
                        color: textColor.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.book.pages.isEmpty
                              ? 0
                              : _currentPage.value / widget.book.pages.length,
                          color: accentColor,
                          backgroundColor: textColor.withValues(alpha: 0.1),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Page ${_currentPage.value} of ${widget.book.pages.length}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                          GestureDetector(
                            onTap: _openOriginalPdfLink,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: accentColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'open_original_pdf'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _renderFormattedText(String rawHtml, Color textColor) {
    final List<Widget> textSpans = [];

    final List<String> blocks = rawHtml.split(
      RegExp(r'(?=<h3>)|(?=</h3>)|(?=<p>)|(?=</p>)'),
    );

    for (var block in blocks) {
      String cleanText = block
          .replaceAll('<h3>', '')
          .replaceAll('</h3>', '')
          .replaceAll('<p>', '')
          .replaceAll('</p>', '')
          .replaceAll('<i>', '')
          .replaceAll('</i>', '')
          .replaceAll('<b>', '')
          .replaceAll('</b>', '')
          .trim();

      if (cleanText.isEmpty) continue;

      if (block.contains('<h3>')) {
        textSpans.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              cleanText,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: _fontSize.value + 6,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        );
      } else {
        final isItalic = block.contains('<i>');
        final isBold = block.contains('<b>');

        textSpans.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              cleanText,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: _fontSize.value,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: textColor.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textSpans,
    );
  }

  void _showSettingsSheet(
    BuildContext context,
    Color textColor,
    Color sheetBg,
    Color readerBg,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'reader_settings'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'text_size'.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: textColor),
                      onPressed: () {
                        if (_fontSize.value > 12.0) _fontSize.value -= 2.0;
                      },
                    ),
                    Obx(
                      () => Text(
                        '${_fontSize.value.toInt()}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: textColor),
                      onPressed: () {
                        if (_fontSize.value < 26.0) _fontSize.value += 2.0;
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Theme',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeCircle(
                  'white',
                  Colors.white,
                  Colors.black87,
                  'Light',
                ),
                _buildThemeCircle(
                  'sepia',
                  const Color(0xFFFBF0D9),
                  const Color(0xFF3E2723),
                  'Sepia',
                ),
                _buildThemeCircle(
                  'dark',
                  const Color(0xFF0F0F0F),
                  Colors.white70,
                  'Dark',
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      elevation: 10,
    );
  }

  Widget _buildThemeCircle(
    String code,
    Color bg,
    Color textBorder,
    String label,
  ) {
    return GestureDetector(
      onTap: () => _readerTheme.value = code,
      child: Obx(() {
        final isSelected = _readerTheme.value == code;
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 3.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : textBorder.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _openOriginalPdfLink() async {
    SystemSound.play(SystemSoundType.click);
    final urlString = widget.book.pdfUrl;

    try {
      final Uri url = Uri.parse(urlString);
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: urlString));

      Get.snackbar(
        'Full Rebuild Required',
        'A full cold restart is required to link the newly added url_launcher plugin. The PDF URL has been copied to your clipboard!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    }
  }
}
