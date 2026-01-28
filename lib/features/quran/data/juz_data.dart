class JuzData {
  /// Maps Juz number (1-30) to its starting Surah number and Ayah number.
  /// Format: { 'surah': surahNumber, 'ayah': ayahNumber }
  static const Map<int, Map<String, int>> _juzStartMap = {
    1: {'surah': 1, 'ayah': 1}, // Fatiha 1
    2: {'surah': 2, 'ayah': 142}, // Baqarah 142
    3: {'surah': 2, 'ayah': 253}, // Baqarah 253
    4: {'surah': 3, 'ayah': 93}, // Ali Imran 93
    5: {'surah': 4, 'ayah': 24}, // Nisa 24
    6: {'surah': 4, 'ayah': 148}, // Nisa 148
    7: {'surah': 5, 'ayah': 82}, // Ma'idah 82
    8: {'surah': 6, 'ayah': 111}, // An'am 111
    9: {'surah': 7, 'ayah': 88}, // A'raf 88
    10: {'surah': 8, 'ayah': 41}, // Anfal 41
    11: {'surah': 9, 'ayah': 93}, // Tawbah 93
    12: {'surah': 11, 'ayah': 6}, // Hud 6
    13: {'surah': 12, 'ayah': 53}, // Yusuf 53
    14: {
      'surah': 15,
      'ayah': 1
    }, // Hijr 1 (Start of Juz 14 is often marked at Hijr 1)
    15: {'surah': 17, 'ayah': 1}, // Isra 1
    16: {'surah': 18, 'ayah': 75}, // Kahf 75
    17: {'surah': 21, 'ayah': 1}, // Anbiya 1
    18: {'surah': 23, 'ayah': 1}, // Mu'minun 1
    19: {'surah': 25, 'ayah': 21}, // Furqan 21
    20: {'surah': 27, 'ayah': 56}, // Naml 56
    21: {'surah': 29, 'ayah': 46}, // Ankabut 46
    22: {'surah': 33, 'ayah': 31}, // Ahzab 31
    23: {'surah': 36, 'ayah': 28}, // Yasin 28
    24: {'surah': 39, 'ayah': 32}, // Zumar 32
    25: {'surah': 41, 'ayah': 47}, // Fussilat 47
    26: {'surah': 46, 'ayah': 1}, // Ahqaf 1
    27: {'surah': 51, 'ayah': 31}, // Dhariyat 31
    28: {'surah': 58, 'ayah': 1}, // Mujadila 1
    29: {'surah': 67, 'ayah': 1}, // Mulk 1
    30: {'surah': 78, 'ayah': 1}, // Naba 1
  };

  /// Returns the start location for a given Juz.
  /// Throws ArgumentError if juzNumber is not 1-30.
  static Map<String, int> getJuzStart(int juzNumber) {
    if (juzNumber < 1 || juzNumber > 30) {
      throw ArgumentError('Juz number must be between 1 and 30');
    }
    return _juzStartMap[juzNumber]!;
  }
}
