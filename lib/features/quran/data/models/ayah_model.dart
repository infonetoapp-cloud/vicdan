import '../../domain/entities/ayah.dart';

/// Data model for Ayah with JSON serialization
///
/// This model handles conversion between JSON and domain entity.
/// Used by the data layer only.
class AyahModel {

  const AyahModel({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  /// Creates AyahModel from JSON
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "number": 1,
  ///   "arabic": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
  ///   "translation": "Rahman ve rahim olan Allah'ın adıyla."
  /// }
  /// ```
  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'] as int,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String,
    );
  }

  /// Creates AyahModel from domain entity
  factory AyahModel.fromEntity(Ayah entity) {
    return AyahModel(
      number: entity.number,
      arabic: entity.arabic,
      translation: entity.translation,
    );
  }
  final int number;
  final String arabic;
  final String translation;

  /// Converts AyahModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabic': arabic,
      'translation': translation,
    };
  }

  /// Converts AyahModel to domain entity
  Ayah toEntity() {
    return Ayah(
      number: number,
      arabic: arabic,
      translation: translation,
    );
  }

  @override
  String toString() => 'AyahModel(number: $number)';
}
