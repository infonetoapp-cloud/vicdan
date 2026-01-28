import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/surah_model.dart';

/// Local data source for Quran data
///
/// Responsible for loading and parsing quran_data.json from assets.
/// This is the single source of truth for Quran data in the app.
class QuranLocalDataSource {
  /// Path to the Quran JSON file in assets
  static const String _quranDataPath = 'assets/quran/quran_data.json';

  /// Cached parsed data (loaded once, reused)
  List<SurahModel>? _cachedSurahs;

  /// Loads all surahs from the JSON file
  ///
  /// Returns a list of 114 SurahModel objects.
  /// Data is cached after first load for performance.
  ///
  /// Throws [Exception] if JSON file is not found or malformed.
  Future<List<SurahModel>> loadAllSurahs() async {
    // Return cached data if available
    if (_cachedSurahs != null) {
      return _cachedSurahs!;
    }

    try {
      // Load JSON string from assets
      final jsonString = await rootBundle.loadString(_quranDataPath);

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract surahs array
      final surahsJson = jsonData['surahs'] as List<dynamic>;

      // Convert to models
      final surahs = surahsJson
          .map((surahJson) =>
              SurahModel.fromJson(surahJson as Map<String, dynamic>))
          .toList();

      // Validate count
      if (surahs.length != 114) {
        throw Exception(
            'Invalid Quran data: Expected 114 surahs, got ${surahs.length}');
      }

      // Cache and return
      _cachedSurahs = surahs;
      return surahs;
    } catch (e) {
      throw Exception('Failed to load Quran data: $e');
    }
  }

  /// Loads a single surah by its number (1-114)
  ///
  /// Returns null if surah not found.
  ///
  /// Throws [Exception] if data cannot be loaded.
  Future<SurahModel?> loadSurahByNumber(int number) async {
    if (number < 1 || number > 114) {
      throw ArgumentError(
          'Surah number must be between 1 and 114, got $number');
    }

    final surahs = await loadAllSurahs();

    try {
      return surahs.firstWhere((surah) => surah.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Searches surahs by name (Turkish or Arabic)
  ///
  /// Case-insensitive search. Returns matching surahs.
  ///
  /// Examples:
  /// - query: "fat" → matches "Fatiha"
  /// - query: "bak" → matches "Bakara"
  Future<List<SurahModel>> searchSurahsByName(String query) async {
    if (query.isEmpty) {
      return await loadAllSurahs();
    }

    final surahs = await loadAllSurahs();
    final lowerQuery = query.toLowerCase();

    return surahs.where((surah) {
      return surah.nameTurkish.toLowerCase().contains(lowerQuery) ||
          surah.nameArabic.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clears the cached data (useful for testing or memory management)
  void clearCache() {
    _cachedSurahs = null;
  }

  /// Returns metadata from the JSON file
  ///
  /// Returns a map containing version, source, total_surahs, etc.
  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(_quranDataPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonData['meta'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      throw Exception('Failed to load metadata: $e');
    }
  }
}
