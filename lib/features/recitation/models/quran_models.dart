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
    required this.text,
    required this.numberInSurah,
    required this.textTranslation,
    required this.page,
    required this.juz,
    this.isHidden = false,
    this.tajweedSpans,
  });

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
