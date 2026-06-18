import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/repositories/auth_repository.dart';
import '../controllers/library_controller.dart';
import '../models/book_model.dart';
import '../../../core/constants/app_colors.dart';
import 'pdf_reader_screen.dart';
import 'audio_player_screen.dart';
import '../../subscription/screens/go_premium_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LibraryController>()
        ? Get.find<LibraryController>()
        : Get.put(LibraryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authRepository = Get.find<AuthRepository>();

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
                  Obx(() {
                    final user = authRepository.currentUser.value;
                    final photoUrl = user?.photo;
                    final username = user?.username ?? '';

                    String initials = 'U';
                    if (username.isNotEmpty) {
                      final parts = username.trim().split(RegExp(r'\s+'));
                      if (parts.length > 1) {
                        initials = (parts[0][0] + parts[1][0]).toUpperCase();
                      } else if (username.length > 1) {
                        initials = username.substring(0, 2).toUpperCase();
                      } else {
                        initials = username[0].toUpperCase();
                      }
                    }

                    return Container(
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
                      child: ClipOval(
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildInitialsPlaceholder(initials),
                              )
                            : _buildInitialsPlaceholder(initials),
                      ),
                    );
                  }),
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
                    suffixIcon: Obx(() {
                      final isListening = controller.isListening.value;
                      return IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400),
                          size: 22,
                        ),
                        onPressed: controller.triggerVoiceSearch,
                      );
                    }),
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

                  if (controller.filteredItems.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchLibrary(force: true),
                      color: AppColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
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
                                    'No items found',
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
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchLibrary(force: true),
                    color: AppColors.primary,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.56,
                          ),
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        return _buildLibraryCard(
                          context,
                          item,
                          controller,
                          isDark,
                        );
                      },
                    ),
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
    final categories = ['All', 'PDF', 'Audio', 'Book'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final localizedLabel = cat == 'All' ? 'category_all'.tr : cat;

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

  Widget _buildLibraryCard(
    BuildContext context,
    LibraryItemModel item,
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
                // Cover Image
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
                    child: item.coverUrl.isNotEmpty
                        ? Image(
                            image: NetworkImage(item.coverUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                _buildCoverPlaceholder(item),
                          )
                        : _buildCoverPlaceholder(item),
                  ),
                ),

                // Premium Locked Badge
                if (item.locked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),

                // Download Progress
                Obx(() {
                  final progress = item.downloadProgress.value;
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
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textThemeColor,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Main Action (Play / Read)
                    GestureDetector(
                      onTap: () async {
                        if (item.locked) {
                          Get.to(() => const GoPremiumScreen());
                          Get.snackbar(
                            'Premium Content Locked',
                            item.message ??
                                'Please subscribe to unlock this item.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.amber.shade900,
                            colorText: Colors.white,
                          );
                        } else {
                          final path = await controller.getLocalPath(item);
                          if (item.contentType == 'audio') {
                            Get.to(
                              () => AudioPlayerScreen(
                                item: item,
                                localPath: path,
                              ),
                            );
                          } else {
                            Get.to(
                              () =>
                                  PdfReaderScreen(item: item, localPath: path),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: item.locked
                              ? AppColors.secondary
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.locked
                              ? 'Unlock'
                              : (item.contentType == 'audio' ? 'Play' : 'Read'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: item.locked ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Offline Download Action (only if not locked)
                    if (!item.locked)
                      Obx(() {
                        final downloaded = item.isDownloaded.value;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            downloaded
                                ? Icons.cloud_done
                                : Icons.cloud_download_outlined,
                            size: 20,
                            color: downloaded ? Colors.green : subtitleColor,
                          ),
                          onPressed: () async {
                            if (!downloaded) {
                              await controller.downloadItem(item);
                            }
                          },
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(LibraryItemModel item) {
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
                item.title,
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

  Widget _buildInitialsPlaceholder(String initials) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
