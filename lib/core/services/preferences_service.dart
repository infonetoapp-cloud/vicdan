import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyLastSurah = 'last_read_surah';
  static const String keyLastAyah = 'last_read_ayah';

  Future<void> saveLastRead(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLastSurah, surah);
    await prefs.setInt(keyLastAyah, ayah);
  }

  Future<Map<String, int>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(keyLastSurah);
    final ayah = prefs.getInt(keyLastAyah);

    if (surah != null && ayah != null) {
      return {
        'surah': surah,
        'ayah': ayah,
      };
    }
    return null;
  }
}
