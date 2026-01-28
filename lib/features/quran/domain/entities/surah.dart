import 'package:equatable/equatable.dart';
import 'ayah.dart';

/// Domain entity representing a complete surah (chapter) from the Quran
///
/// This is a pure business entity with no dependencies on data layer.
/// Immutable and contains only business logic.
class Surah extends Equatable {
  /// Surah number in the Quran (1-114)
  final int number;

  /// Arabic name of the surah
  final String nameArabic;

  /// Turkish name of the surah
  final String nameTurkish;

  /// Place of revelation: "Makkah" or "Madinah"
  final String revelationPlace;

  /// Total number of ayahs in this surah
  final int totalAyahs;

  /// List of all ayahs in this surah
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameTurkish,
    required this.revelationPlace,
    required this.totalAyahs,
    required this.ayahs,
  });

  /// Creates a copy of this Surah with updated fields
  Surah copyWith({
    int? number,
    String? nameArabic,
    String? nameTurkish,
    String? revelationPlace,
    int? totalAyahs,
    List<Ayah>? ayahs,
  }) {
    return Surah(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameTurkish: nameTurkish ?? this.nameTurkish,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      ayahs: ayahs ?? this.ayahs,
    );
  }

  /// Returns true if this surah was revealed in Makkah
  bool get isMakki => revelationPlace.toLowerCase() == 'makkah';

  /// Returns true if this surah was revealed in Madinah
  bool get isMadani => revelationPlace.toLowerCase() == 'madinah';

  /// Returns the ayah at the given index (0-based)
  /// Throws RangeError if index is out of bounds
  Ayah ayahAt(int index) {
    if (index < 0 || index >= ayahs.length) {
      throw RangeError(
          'Ayah index $index out of range (0-${ayahs.length - 1})');
    }
    return ayahs[index];
  }

  /// Returns the ayah with the given number (1-based)
  /// Returns null if not found
  Ayah? ayahByNumber(int number) {
    try {
      return ayahs.firstWhere((ayah) => ayah.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Returns a formatted display name: "1. Al-Fatihah (Fatiha)"
  String get displayName => '$number. $nameArabic ($nameTurkish)';

  /// Returns a short display name: "Fatiha"
  String get shortName => nameTurkish;

  @override
  List<Object?> get props => [
        number,
        nameArabic,
        nameTurkish,
        revelationPlace,
        totalAyahs,
        ayahs,
      ];

  @override
  String toString() =>
      'Surah(number: $number, name: $nameTurkish, ayahs: ${ayahs.length})';
}
