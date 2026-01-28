import 'package:equatable/equatable.dart';

/// Domain entity representing a single verse (ayah) from the Quran
///
/// This is a pure business entity with no dependencies on data layer.
/// Immutable and contains only business logic.
class Ayah extends Equatable {
  /// Ayah number within the surah (1-indexed)
  final int number;

  /// Arabic text of the ayah (Uthmani script)
  final String arabic;

  /// Translation of the ayah (Turkish)
  final String translation;

  const Ayah({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  /// Creates a copy of this Ayah with updated fields
  Ayah copyWith({
    int? number,
    String? arabic,
    String? translation,
  }) {
    return Ayah(
      number: number ?? this.number,
      arabic: arabic ?? this.arabic,
      translation: translation ?? this.translation,
    );
  }

  @override
  List<Object?> get props => [number, arabic, translation];

  @override
  String toString() =>
      'Ayah(number: $number, arabic: ${arabic.substring(0, 20)}...)';
}
