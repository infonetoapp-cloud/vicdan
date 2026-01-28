import '../entities/surah.dart';

/// Repository interface for Quran data
///
/// Defines the contract for accessing Quran data.
/// This interface belongs to the domain layer and is implemented by the data layer.
///
/// Following Clean Architecture principles:
/// - Domain layer defines the interface (this file)
/// - Data layer provides the implementation
/// - Allows for easy testing with mocks
/// - Enables dependency inversion
abstract class QuranRepository {
  /// Retrieves all 114 surahs from the Quran
  ///
  /// Returns a list of Surah entities.
  /// Throws [Exception] if data cannot be loaded.
  Future<List<Surah>> getAllSurahs();

  /// Retrieves a single surah by its number (1-114)
  ///
  /// Returns null if the surah is not found.
  /// Throws [ArgumentError] if number is out of range.
  /// Throws [Exception] if data cannot be loaded.
  Future<Surah?> getSurahByNumber(int number);

  /// Searches surahs by name (Turkish or Arabic)
  ///
  /// Case-insensitive search. Returns all matching surahs.
  /// Returns all surahs if query is empty.
  ///
  /// Examples:
  /// - "fat" → Fatiha
  /// - "bak" → Bakara
  /// - "ya" → Yasin, Yunus, etc.
  Future<List<Surah>> searchSurahsByName(String query);

  /// Retrieves surahs by revelation place
  ///
  /// [place] should be either "Makkah" or "Madinah" (case-insensitive)
  /// Returns an empty list if no matches found.
  Future<List<Surah>> getSurahsByRevelationPlace(String place);
}
