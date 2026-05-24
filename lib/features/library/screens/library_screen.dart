import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/library_controller.dart';
import '../models/book_model.dart';
import '../../../core/constants/app_colors.dart';
import 'qari_reader_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryController controller = Get.put(LibraryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textThemeColor = isDark ? Colors.white : Colors.black87;
    final searchBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final borderThemeColor = isDark
        ? Colors.grey.shade900
        : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'my_library'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textThemeColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                      child: Image(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: _fallbackAvatar,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: searchBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderThemeColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchTextController,
                  style: TextStyle(color: textThemeColor, fontSize: 15),
                  onChanged: controller.searchBooks,
                  decoration: InputDecoration(
                    hintText: 'search_book'.tr,
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.mic_none,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        size: 22,
                      ),
                      onPressed: controller.triggerVoiceSearch,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildCategorySelector(controller, isDark),
              const SizedBox(height: 16),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.filteredBooks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            color: Colors.grey.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No books found',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.58,
                        ),
                    itemCount: controller.filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = controller.filteredBooks[index];
                      return _buildBookCard(context, book, controller, isDark);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(LibraryController controller, bool isDark) {
    final categories = ['All', 'Quran', 'Tafseer', 'Hadith'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final localizedLabel = cat == 'All'
              ? 'category_all'.tr
              : cat == 'Quran'
              ? 'category_quran'.tr
              : cat == 'Tafseer'
              ? 'category_tafseer'.tr
              : 'category_hadith'.tr;

          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.filterByCategory(cat),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF161616) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  localizedLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    BookModel book,
    LibraryController controller,
    bool isDark,
  ) {
    final cardBgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textThemeColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image(
                      image: NetworkImage(book.coverUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildCoverPlaceholder(book),
                    ),
                  ),
                ),

                Obx(() {
                  final progress = book.downloadProgress.value;
                  if (progress <= 0.0) return const SizedBox.shrink();

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3.5,
                            color: AppColors.secondary,
                            backgroundColor: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textThemeColor,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (book.isDownloaded.value) {
                          Get.to(() => QariReaderScreen(book: book));
                        } else {
                          await controller.downloadBook(book);
                        }
                      },
                      child: Obx(() {
                        final downloaded = book.isDownloaded.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: downloaded
                                ? AppColors.primary
                                : Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            downloaded ? 'read'.tr : 'Download',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 13,
                          color: subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.views,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(BookModel book) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF023F26), Color(0xFF054F30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _fallbackAvatar(BuildContext c, Object e, StackTrace? s) {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Text(
          'H',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
