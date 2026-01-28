import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_datasource.dart';

/// Implementation of QuranRepository
///
/// This class bridges the data layer (datasource) with the domain layer (entities).
/// It depends on QuranLocalDataSource for data access and converts models to entities.
///
/// Following Clean Architecture:
/// - Implements domain interface (QuranRepository)
/// - Depends on data source for raw data
/// - Converts data models to domain entities
/// - Adds business logic (filtering, validation, etc.)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _dataSource;

  QuranRepositoryImpl(this._dataSource);

  @override
  Future<List<Surah>> getAllSurahs() async {
    try {
      final surahModels = await _dataSource.loadAllSurahs();
      return surahModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all surahs: $e');
    }
  }

  @override
  Future<Surah?> getSurahByNumber(int number) async {
    // Validate input
    if (number < 1 || number > 114) {
      throw ArgumentError(
          'Surah number must be between 1 and 114, got $number');
    }

    try {
      final surahModel = await _dataSource.loadSurahByNumber(number);
      return surahModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to get surah $number: $e');
    }
  }

  @override
  Future<List<Surah>> searchSurahsByName(String query) async {
    try {
      final surahModels = await _dataSource.searchSurahsByName(query);
      return surahModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search surahs by name "$query": $e');
    }
  }

  @override
  Future<List<Surah>> getSurahsByRevelationPlace(String place) async {
    try {
      // Normalize input
      final normalizedPlace = place.trim().toLowerCase();

      if (normalizedPlace != 'makkah' && normalizedPlace != 'madinah') {
        throw ArgumentError(
          'Revelation place must be "Makkah" or "Madinah", got "$place"',
        );
      }

      // Get all surahs
      final allSurahs = await getAllSurahs();

      // Filter by revelation place
      return allSurahs.where((surah) {
        return surah.revelationPlace.toLowerCase() == normalizedPlace;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get surahs by revelation place "$place": $e');
    }
  }

  /// Returns metadata about the Quran dataset
  ///
  /// Useful for displaying version info, source attribution, etc.
  Future<Map<String, dynamic>> getMetadata() async {
    try {
      return await _dataSource.getMetadata();
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  /// Clears cached data (useful for testing or memory management)
  void clearCache() {
    _dataSource.clearCache();
  }
}
