class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final String textTranslation;
  final int page;
  final int juz;
  bool isHidden;
  List<TajweedSpan>? tajweedSpans;

  Ayah({
    required this.number,
    required String text,
    required this.numberInSurah,
    required this.textTranslation,
    required this.page,
    required this.juz,
    this.isHidden = false,
    this.tajweedSpans,
  }) : text = cleanQuranicText(stripBismillahPrefix(text, numberInSurah));

  static String normalizeArabicSimple(String text) {
    if (text.isEmpty) return "";
    var normalized = text.toLowerCase();
    normalized = normalized.replaceAll('\u0649\u0670', '\u0649'); // ىٰ -> ى
    normalized = normalized.replaceAll('\u0670', '\u0627');
    normalized = normalized.replaceAll(RegExp(r'[a-zA-Z0-9]'), '');
    final tashkeel = RegExp(r'[\u064B-\u0652\u0653\u0654\u0655\u0640]');
    normalized = normalized.replaceAll(tashkeel, '');
    normalized = normalized.replaceAll(RegExp(r'[إأآٱ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ی', 'ي');
    normalized = normalized.replaceAll('ک', 'ك');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    var words = normalized.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i] == 'الرحمان') {
        words[i] = 'الرحمن';
      }
    }
    return words.join(' ').trim();
  }

  static String stripBismillahPrefix(String text, int numberInSurah) {
    if (numberInSurah == 1) {
      final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.length > 4) {
        final first4Normalized = words.take(4).map(normalizeArabicSimple).toList();
        if (first4Normalized[0] == "بسم" &&
            first4Normalized[1] == "الله" &&
            first4Normalized[2] == "الرحمن" &&
            first4Normalized[3] == "الرحيم") {
          return words.skip(4).join(' ');
        }
      }
    }
    return text;
  }

  static String cleanQuranicText(String text) {
    if (text.isEmpty) return text;
    // Remove spaces before Arabic combining diacritics and superscript alef (e.g. ٱلصِّرَ ٰطَ)
    return text.replaceAll(RegExp(r'\s+(?=[\u064B-\u065F\u0670])'), '');
  }

  factory Ayah.fromJson(Map<String, dynamic> json, String translation) {
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      textTranslation: translation,
      page: json['page'] ?? 1,
      juz: json['juz'] ?? 1,
    );
  }
}

class TajweedSpan {
  final String text;
  final TajweedRule rule;

  TajweedSpan({required this.text, required this.rule});
}

enum TajweedRule { ghunnah, qalqalah, idgham, ikhfa, madd, none }

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json, List<String> translations) {
    var list = json['ayahs'] as List? ?? [];
    List<Ayah> parsedAyahs = [];
    for (int i = 0; i < list.length; i++) {
      String trans = i < translations.length
          ? translations[i]
          : 'Translation not available.';
      parsedAyahs.add(Ayah.fromJson(list[i], trans));
    }
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'Meccan',
      ayahs: parsedAyahs,
    );
  }
}
