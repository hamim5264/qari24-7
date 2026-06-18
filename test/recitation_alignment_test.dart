import 'package:flutter_test/flutter_test.dart';
import 'package:qari24_7/features/recitation/services/recitation_ai_service.dart';
import 'package:qari24_7/features/recitation/models/quran_models.dart';

void main() {
  group('RecitationAIService Normalization Tests', () {
    final service = RecitationAIService();

    test('should normalize standard Quranic spelling variations', () {
      expect(service.normalizeArabic("تَرَىٰ"), equals("تري"));
      expect(service.normalizeArabic("ٱلرَّحْمَٰنِ"), equals("الرحمن"));
      expect(service.normalizeArabic("سَمَٰوَٰتٍ"), equals("سماوات"));
      expect(service.normalizeArabic("مَٰلِكِ"), equals("مالك"));
      expect(service.normalizeArabic("لِّلْمُتَّقِينَ"), equals("للمتقين"));
      expect(service.normalizeArabic("بِالْغَيْبِ"), equals("بالغيب"));
    });

    test('should match standard ASR output', () {
      final quran = service.normalizeArabic("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ");
      final asr = service.normalizeArabic("بسم الله الرحمن الرحيم");
      expect(quran, equals(asr));
    });

    test('should clean accidental spaces before diacritics', () {
      expect(Ayah.cleanQuranicText("ٱلصِّرَ ٰطَ"), equals("ٱلصِّرَٰطَ"));
    });

    test('should strip Bismillah prefix if content follows', () {
      expect(
        Ayah.stripBismillahPrefix("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ تَبَٰرَكَ", 1),
        equals("تَبَٰرَكَ"),
      );
      // Should NOT strip if it is exactly the Bismillah (e.g. Al-Fatihah)
      expect(
        Ayah.stripBismillahPrefix("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", 1),
        equals("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"),
      );
    });
  });
}
