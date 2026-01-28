import '../../domain/entities/surah.dart';
import 'ayah_model.dart';

/// Data model for Surah with JSON serialization
///
/// This model handles conversion between JSON and domain entity.
/// Used by the data layer only.
class SurahModel {
  final int number;
  final String nameArabic;
  final String nameTurkish;
  final String revelationPlace;
  final int totalAyahs;
  final List<AyahModel> ayahs;

  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameTurkish,
    required this.revelationPlace,
    required this.totalAyahs,
    required this.ayahs,
  });

  /// Creates SurahModel from JSON
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "number": 1,
  ///   "name_arabic": "Al-Fatihah",
  ///   "name_turkish": "Fatiha",
  ///   "revelation_place": "Makkah",
  ///   "total_ayahs": 7,
  ///   "ayahs": [...]
  /// }
  /// ```
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      nameArabic: json['name_arabic'] as String,
      nameTurkish: json['name_turkish'] as String,
      revelationPlace: json['revelation_place'] as String,
      totalAyahs: json['total_ayahs'] as int,
      ayahs: (json['ayahs'] as List<dynamic>)
          .map((ayahJson) =>
              AyahModel.fromJson(ayahJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts SurahModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_arabic': nameArabic,
      'name_turkish': nameTurkish,
      'revelation_place': revelationPlace,
      'total_ayahs': totalAyahs,
      'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
    };
  }

  /// Converts SurahModel to domain entity
  Surah toEntity() {
    return Surah(
      number: number,
      nameArabic: nameArabic,
      nameTurkish: nameTurkish,
      revelationPlace: revelationPlace,
      totalAyahs: totalAyahs,
      ayahs: ayahs.map((model) => model.toEntity()).toList(),
    );
  }

  /// Creates SurahModel from domain entity
  factory SurahModel.fromEntity(Surah entity) {
    return SurahModel(
      number: entity.number,
      nameArabic: entity.nameArabic,
      nameTurkish: entity.nameTurkish,
      revelationPlace: entity.revelationPlace,
      totalAyahs: entity.totalAyahs,
      ayahs: entity.ayahs.map((ayah) => AyahModel.fromEntity(ayah)).toList(),
    );
  }

  @override
  String toString() =>
      'SurahModel(number: $number, name: $nameTurkish, ayahs: ${ayahs.length})';
}
