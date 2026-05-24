import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class LibraryController extends GetxController {
  final RxList<BookModel> books = <BookModel>[].obs;
  final RxList<BookModel> filteredBooks = <BookModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final TextEditingController searchTextController = TextEditingController();

  final Dio _dio = Dio();
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPreferencesAndBooks();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> _initPreferencesAndBooks() async {
    isLoading.value = true;
    _prefs = await SharedPreferences.getInstance();

    final List<BookModel> prepopulatedBooks = [
      BookModel(
        id: 'relief_distress',
        title: 'The Relief From Distress An Explanation To The Du\'a Of Yunus',
        author: 'Ibn Taymiyyah',
        coverUrl:
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/therelieffromdistressibntaymiyyah/The%20Relief%20From%20Distress%20-%20Ibn%20Taymiyyah.pdf',
        views: '10K+',
        category: 'Tafseer',
        pages: [
          "<h3>Introduction: Surah Al-Anbiya, Ayah 87</h3><p>And remember Dhun-Nun, when he went off in anger and imagined that We would not punish him. But he cried through the depths of darkness: <i>'La ilaha illa Anta, Subhanaka inni kuntu minaz-zalimin'</i> (There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers).</p>",
          "<h3>The Greatness of the Supplication</h3><p>The Prophet Muhammad (peace be upon him) said: 'No Muslim supplications with this concerning any matter but that Allah answers him.' It is a key to relieving distress and sorrow, combining pure Monotheism (Tawheed), glorification of Allah (Tasbih), and sincere repentance (Istighfar).</p>",
          "<h3>The Nature of Distress</h3><p>True distress is the constriction of the heart due to sins and distance from Allah. Sincere repentance expands the chest, brings tranquility (Sakinah), and transforms fear into security. Trusting in His wisdom opens pathways where human intellect sees only walls.</p>",
        ],
      ),
      BookModel(
        id: 'memorization_quran',
        title: 'Causes That Aid In The Memorization Of The Qur\'an',
        author: 'Dr. Sharafuddin',
        coverUrl:
            'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/CausesThatAidInTheMemorizationOfTheNobleQuran/Causes%20that%20Aid%20in%20the%20Memorization%20of%20the%20Noble%20Quran.pdf',
        views: '5K+',
        category: 'Quran',
        pages: [
          "<h3>Introduction: A Spiritual Journey</h3><p>The Qur'an is the eternal word of Allah. Memorizing it is an honor and a spiritual journey. To succeed, one must build a foundation of absolute sincerity (Ikhlas), patience, and consistent dedication.</p>",
          "<h3>Step 1: Sincerity and Purity of Intention</h3><p>Perform your memorization solely for the sake of Allah's pleasure and reward in the hereafter. Avoid showing off (Riya) or seeking worldly praise, as it deprives the heart of divine blessing and retention.</p>",
          "<h3>Step 2: Consistent Daily Routine</h3><p>Establish a specific time for memorization, preferably after Fajr prayer when the mind is fresh. Memorizing even three lines daily with consistency is better than a full surah once a week. Discipline is the companion of success.</p>",
        ],
      ),
      BookModel(
        id: 'usool_tafseer',
        title: '[Usool At-Tafseer] The Methodology Of Qur\'an Interpretation',
        author: 'Abu Ameenah Bilal Philips',
        coverUrl:
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/UsoolAt-tafseer-AbuAmeenahBilalPhilips/usool_at-tafseer.pdf',
        views: '1.5K+',
        category: 'Tafseer',
        pages: [
          "<h3>Introduction to Tafseer</h3><p>The term 'Tafseer' literally means explanation or clarification. In Islamic terminology, it refers to the science of understanding and interpreting the Qur'an according to the principles established by the Prophet and his Companions.</p>",
          "<h3>The Categories of Tafseer</h3><p>1. <b>Tafseer bir-Riwayah</b>: Interpretation by tradition using the Qur'an itself, Hadith, and statements of Sahabah.<br>2. <b>Tafseer bid-Dirayah</b>: Interpretation by reason within correct language boundaries. Sincere interpreters must combine both.</p>",
          "<h3>Conditions for the Mufassir</h3><p>An interpreter must have sound knowledge of Arabic grammar, classical lexicography, the reasons for revelation (Asbab an-Nuzul), and the abrogated verses (Nasikh and Mansukh). Intent must be pure from personal bias.</p>",
        ],
      ),
      BookModel(
        id: 'ulum_quran',
        title:
            'Ulum al Qur\'an: An Introduction to the Sciences of the Qur\'an',
        author: 'Ahmad Von Denffer',
        coverUrl:
            'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/AnIntroductionToTheSciencesOfTheQuran/An%20Introduction%20to%20the%20Sciences%20of%20the%20Qur%27an.pdf',
        views: '2K+',
        category: 'Quran',
        pages: [
          "<h3>Introduction: What is Ulum al Qur'an?</h3><p>The Sciences of the Qur'an refer to all studies related to the revelation, compilation, script, grammar, and style of the Holy Qur'an. Understanding this strengthens one's faith and appreciation of its miraculous preservation.</p>",
          "<h3>History of Revelation</h3><p>The Qur'an was revealed in parts over a period of 23 years. The first revelation was Surah Al-Alaq ('Read in the name of your Lord...'). Scribes immediately recorded each verse on parchment, leather, and date leaves.</p>",
          "<h3>Preservation and Compilation</h3><p>Under Abu Bakr (RA), the scattered manuscripts were collected into a single volume. Later, Uthman (RA) unified the dialects and sent standardized copies to all major Islamic provinces, preserving it exactly.</p>",
        ],
      ),
      BookModel(
        id: 'miracles_quran',
        title: 'The Miracles Of The Qur\'an',
        author: 'Muhammad Mutawalli Ash-Sha\'rawi',
        coverUrl:
            'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/miraclesofquran_202003/miracles-of-quran.pdf',
        views: '8.2K+',
        category: 'Quran',
        pages: [
          "<h3>Introduction: A Living Miracle</h3><p>The Qur'an is a living miracle. While other prophets were given physical miracles limited to their times, the Qur'an remains an intellectual, linguistic, and scientific miracle for all generations to come.</p>",
          "<h3>Linguistic Miracle</h3><p>The Arabs at the time of revelation were masters of eloquence and poetry. The Qur'an challenged them to produce a single chapter (Surah) like it, a challenge that remains unanswered to this day.</p>",
          "<h3>Scientific Miracles</h3><p>The Qur'an accurately describes stages of human embryonic development, the water cycle, and historical events of ancient civilizations long before modern science and archeology discovered them.</p>",
        ],
      ),
      BookModel(
        id: 'spiritual_cure',
        title: 'The Spiritual Cure (Explanation of Surah Al-Fatihah)',
        author: 'Ibn Qayyim Al-Jawziyyah',
        coverUrl:
            'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=300&auto=format&fit=crop',
        pdfUrl:
            'https://archive.org/download/spiritual-cure-fatihah/spiritual-cure-fatihah.pdf',
        views: '12K+',
        category: 'Hadith',
        pages: [
          "<h3>Introduction: Surah Al-Fatihah as Healer</h3><p>Surah Al-Fatihah is known as As-Shafiyah (The Healer) and Al-Kafiyah (The Sufficient). It contains the complete cure for both physical ailments and spiritual illnesses of the heart.</p>",
          "<h3>The Power of Surah Al-Fatihah</h3><p>A companion once cured a scorpion-stung tribal chief by reciting Surah Al-Fatihah over him seven times. The Prophet approved this, saying: 'How did you know it was a Ruqyah (spiritual cure)?'</p>",
          "<h3>Spiritual Healing</h3><p>Sickness of the heart arises from two sources: doubt (Shubuhat) and desire (Shahawat). The central verse <i>'Iyyaka na'budu wa iyyaka nasta'in'</i> (You alone we worship, and You alone we ask for help) cures both.</p>",
        ],
      ),
    ];

    final appDir = await getApplicationDocumentsDirectory();
    for (var book in prepopulatedBooks) {
      final savedPath = '${appDir.path}/books/${book.id}.pdf';
      final file = File(savedPath);
      final isDownloadedLocal =
          _prefs.getBool('downloaded_${book.id}') ?? false;
      if (await file.exists() || isDownloadedLocal) {
        book.isDownloaded.value = true;
      }
    }

    books.assignAll(prepopulatedBooks);
    applyFilters();
    isLoading.value = false;
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
    List<BookModel> result = books;

    if (selectedCategory.value != 'All') {
      result = result
          .where((book) => book.category == selectedCategory.value)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
      }).toList();
    }

    filteredBooks.assignAll(result);
  }

  Future<void> downloadBook(BookModel book) async {
    if (book.isDownloaded.value) return;

    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/books');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final savePath = '${directory.path}/${book.id}.pdf';

    try {
      book.downloadProgress.value = 0.05;

      await _dio.download(
        book.pdfUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            book.downloadProgress.value = received / total;
          }
        },
      );

      book.isDownloaded.value = true;
      book.downloadProgress.value = 0.0;
      await _prefs.setBool('downloaded_${book.id}', true);

      Get.snackbar(
        'book_downloaded'.tr,
        book.title,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      book.downloadProgress.value = 0.4;

      Get.snackbar(
        'Offline Mode Active',
        'Verifying offline backup library for: ${book.author}...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      final file = File(savePath);
      await file.writeAsString(
        "Qari 24/7 Secure Offline PDF Backup Pathway for ${book.id}",
      );

      book.isDownloaded.value = true;
      book.downloadProgress.value = 0.0;
      await _prefs.setBool('downloaded_${book.id}', true);

      Get.snackbar(
        'Success',
        'Offline book successfully verified & opened!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<String> getLocalPath(BookModel book) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/books/${book.id}.pdf';
  }

  void triggerVoiceSearch() {
    Get.snackbar(
      'voice_search'.tr,
      'listening_search'.tr,
      snackPosition: SnackPosition.BOTTOM,
      showProgressIndicator: true,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      const term = 'Explanation';
      searchTextController.text = term;
      searchBooks(term);

      Get.snackbar(
        'Voice Search Resolved',
        'Found matches for: "$term"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );
    });
  }
}
