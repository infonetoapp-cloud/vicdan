import 'dart:convert';
import 'dart:io';

/// Parser script to convert alquran.cloud API format to VİCDAN app format
///
/// Input files:
/// - quran_arabic.json (Uthmani script from Quran.com API)
/// - quran_diyanet_full.json (Diyanet İşleri Meali from alquran.cloud)
///
/// Output file:
/// - quran_data.json (Unified format for app)
///
/// Run: dart scripts/quran_parser.dart

void main() async {
  print('🌙 VİCDAN Quran Parser v2.0 (KALICI ÇÖZÜM)');
  print('Converting API formats to app format...\n');

  // Paths
  const arabicPath = 'assets/quran/quran_arabic.json';
  const diyanetPath = 'assets/quran/quran_diyanet_full.json';
  const outputPath = 'assets/quran/quran_data.json';

  try {
    // Read Arabic Quran
    print('📖 Reading Arabic verses (Uthmani)...');
    final arabicFile = File(arabicPath);
    if (!arabicFile.existsSync()) {
      throw Exception('File not found: $arabicPath');
    }
    final arabicJson = jsonDecode(await arabicFile.readAsString());

    // Read Diyanet Turkish translation
    print('📖 Reading Diyanet Turkish translation...');
    final diyanetFile = File(diyanetPath);
    if (!diyanetFile.existsSync()) {
      throw Exception('File not found: $diyanetPath');
    }
    final diyanetJson = jsonDecode(await diyanetFile.readAsString());

    // Extract data
    final arabicVerses = arabicJson['verses'] as List;
    final diyanetData = diyanetJson['data'] as Map<String, dynamic>;
    final diyanetSurahs = diyanetData['surahs'] as List;

    print('✅ Found ${arabicVerses.length} Arabic verses');
    print('✅ Found ${diyanetSurahs.length} surahs in Diyanet translation');

    // Build unified structure
    print('\n📚 Building unified structure...');
    final surahsList = <Map<String, dynamic>>[];

    for (int i = 0; i < diyanetSurahs.length; i++) {
      final diyanetSurah = diyanetSurahs[i] as Map<String, dynamic>;
      final surahNumber = diyanetSurah['number'] as int;
      final ayahs = diyanetSurah['ayahs'] as List;

      // Get metadata
      final meta = _getSurahMetadata(surahNumber);

      // Build ay ahs list
      final ayahsList = <Map<String, dynamic>>[];
      for (final ayahData in ayahs) {
        final ayahMap = ayahData as Map<String, dynamic>;
        final ayahNumber = ayahMap['numberInSurah'] as int;
        final turkishText = ayahMap['text'] as String;

        // Find corresponding Arabic verse
        final arabicVerse =
            _findArabicVerse(arabicVerses, surahNumber, ayahNumber);
        final arabicText = arabicVerse?['text_uthmani'] ?? '';

        ayahsList.add({
          'number': ayahNumber,
          'arabic': arabicText,
          'translation': turkishText,
        });
      }

      // Add surah
      surahsList.add({
        'number': surahNumber,
        'name_arabic': meta['arabic'],
        'name_turkish': meta['turkish'],
        'revelation_place': meta['revelation'],
        'total_ayahs': ayahsList.length,
        'ayahs': ayahsList,
      });

      print(
          '  ✓ Surah $surahNumber: ${meta['turkish']} (${ayahsList.length} ayahs)');
    }

    // Build final JSON
    final finalJson = {
      'meta': {
        'version': '2.0',
        'source': 'Quran.com (Uthmani) + alquran.cloud (Diyanet İşleri)',
        'total_surahs': surahsList.length,
        'generated_at': DateTime.now().toIso8601String(),
      },
      'surahs': surahsList,
    };

    // Write output
    print('\n💾 Writing unified Quran data...');
    final outputFile = File(outputPath);
    final encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(finalJson));

    // Stats
    final outputSize =
        (await outputFile.length() / 1024 / 1024).toStringAsFixed(2);
    print('✅ SUCCESS! Generated quran_data.json (${outputSize}MB)');
    print('📊 Total surahs: ${surahsList.length}');
    print('📊 Total ayahs: ${arabicVerses.length}');
    print('\n🎉 Türkçe Diyanet İşleri Meali yüklendi!');
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Finds Arabic verse by surah and ayah number
Map<String, dynamic>? _findArabicVerse(
    List arabicVerses, int surahNum, int ayahNum) {
  for (final verse in arabicVerses) {
    final verseMap = verse as Map<String, dynamic>;
    final verseKey = verseMap['verse_key'] as String; // e.g., "1:1"
    final parts = verseKey.split(':');
    final vSurah = int.parse(parts[0]);
    final vAyah = int.parse(parts[1]);

    if (vSurah == surahNum && vAyah == ayahNum) {
      return verseMap;
    }
  }
  return null;
}

/// Gets surah metadata (names, revelation place)
Map<String, String> _getSurahMetadata(int number) {
  final data = {
    1: {'arabic': 'Al-Fatihah', 'turkish': 'Fatiha', 'revelation': 'Makkah'},
    2: {'arabic': 'Al-Baqarah', 'turkish': 'Bakara', 'revelation': 'Madinah'},
    3: {
      'arabic': 'Ali \'Imran',
      'turkish': 'Âl-i İmrân',
      'revelation': 'Madinah'
    },
    4: {'arabic': 'An-Nisa', 'turkish': 'Nisâ', 'revelation': 'Madinah'},
    5: {'arabic': 'Al-Ma\'idah', 'turkish': 'Mâide', 'revelation': 'Madinah'},
    6: {'arabic': 'Al-An\'am', 'turkish': 'En\'âm', 'revelation': 'Makkah'},
    7: {'arabic': 'Al-A\'raf', 'turkish': 'A\'râf', 'revelation': 'Makkah'},
    8: {'arabic': 'Al-Anfal', 'turkish': 'Enfâl', 'revelation': 'Madinah'},
    9: {'arabic': 'At-Tawbah', 'turkish': 'Tevbe', 'revelation': 'Madinah'},
    10: {'arabic': 'Yunus', 'turkish': 'Yûnus', 'revelation': 'Makkah'},
    11: {'arabic': 'Hud', 'turkish': 'Hûd', 'revelation': 'Makkah'},
    12: {'arabic': 'Yusuf', 'turkish': 'Yûsuf', 'revelation': 'Makkah'},
    13: {'arabic': 'Ar-Ra\'d', 'turkish': 'Ra\'d', 'revelation': 'Madinah'},
    14: {'arabic': 'Ibrahim', 'turkish': 'İbrâhim', 'revelation': 'Makkah'},
    15: {'arabic': 'Al-Hijr', 'turkish': 'Hicr', 'revelation': 'Makkah'},
    16: {'arabic': 'An-Nahl', 'turkish': 'Nahl', 'revelation': 'Makkah'},
    17: {'arabic': 'Al-Isra', 'turkish': 'İsrâ', 'revelation': 'Makkah'},
    18: {'arabic': 'Al-Kahf', 'turkish': 'Kehf', 'revelation': 'Makkah'},
    19: {'arabic': 'Maryam', 'turkish': 'Meryem', 'revelation': 'Makkah'},
    20: {'arabic': 'Taha', 'turkish': 'Tâhâ', 'revelation': 'Makkah'},
    21: {'arabic': 'Al-Anbya', 'turkish': 'Enbiyâ', 'revelation': 'Makkah'},
    22: {'arabic': 'Al-Hajj', 'turkish': 'Hac', 'revelation': 'Madinah'},
    23: {
      'arabic': 'Al-Mu\'minun',
      'turkish': 'Mü\'minûn',
      'revelation': 'Makkah'
    },
    24: {'arabic': 'An-Nur', 'turkish': 'Nûr', 'revelation': 'Madinah'},
    25: {'arabic': 'Al-Furqan', 'turkish': 'Furkān', 'revelation': 'Makkah'},
    26: {'arabic': 'Ash-Shu\'ara', 'turkish': 'Şuarâ', 'revelation': 'Makkah'},
    27: {'arabic': 'An-Naml', 'turkish': 'Neml', 'revelation': 'Makkah'},
    28: {'arabic': 'Al-Qas as', 'turkish': 'Kasas', 'revelation': 'Makkah'},
    29: {
      'arabic': 'Al-\'Ankabut',
      'turkish': 'Ankebût',
      'revelation': 'Makkah'
    },
    30: {'arabic': 'Ar-Rum', 'turkish': 'Rûm', 'revelation': 'Makkah'},
    31: {'arabic': 'Luqman', 'turkish': 'Lokmân', 'revelation': 'Makkah'},
    32: {'arabic': 'As-Sajdah', 'turkish': 'Secde', 'revelation': 'Makkah'},
    33: {'arabic': 'Al-Ahzab', 'turkish': 'Ahzâb', 'revelation': 'Madinah'},
    34: {'arabic': 'Saba', 'turkish': 'Sebe\'', 'revelation': 'Makkah'},
    35: {'arabic': 'Fatir', 'turkish': 'Fâtır', 'revelation': 'Makkah'},
    36: {'arabic': 'Ya-Sin', 'turkish': 'Yâsîn', 'revelation': 'Makkah'},
    37: {'arabic': 'As-Saffat', 'turkish': 'Sâffât', 'revelation': 'Makkah'},
    38: {'arabic': 'Sad', 'turkish': 'Sâd', 'revelation': 'Makkah'},
    39: {'arabic': 'Az-Zumar', 'turkish': 'Zümer', 'revelation': 'Makkah'},
    40: {'arabic': 'Ghafir', 'turkish': 'Mü\'min', 'revelation': 'Makkah'},
    41: {'arabic': 'Fussilat', 'turkish': 'Fussilet', 'revelation': 'Makkah'},
    42: {'arabic': 'Ash-Shuraa', 'turkish': 'Şûrâ', 'revelation': 'Makkah'},
    43: {'arabic': 'Az-Zukhruf', 'turkish': 'Zuhruf', 'revelation': 'Makkah'},
    44: {'arabic': 'Ad-Dukhan', 'turkish': 'Duhân', 'revelation': 'Makkah'},
    45: {'arabic': 'Al-Jathiyah', 'turkish': 'Câsiye', 'revelation': 'Makkah'},
    46: {'arabic': 'Al-Ahqaf', 'turkish': 'Ahkāf', 'revelation': 'Makkah'},
    47: {'arabic': 'Muhammad', 'turkish': 'Muhammed', 'revelation': 'Madinah'},
    48: {'arabic': 'Al-Fath', 'turkish': 'Fetih', 'revelation': 'Madinah'},
    49: {'arabic': 'Al-Hujurat', 'turkish': 'Hucurât', 'revelation': 'Madinah'},
    50: {'arabic': 'Qaf', 'turkish': 'Kāf', 'revelation': 'Makkah'},
    51: {
      'arabic': 'Adh-Dhariyat',
      'turkish': 'Zâriyât',
      'revelation': 'Makkah'
    },
    52: {'arabic': 'At-Tur', 'turkish': 'Tûr', 'revelation': 'Makkah'},
    53: {'arabic': 'An-Najm', 'turkish': 'Necm', 'revelation': 'Makkah'},
    54: {'arabic': 'Al-Qamar', 'turkish': 'Kamer', 'revelation': 'Makkah'},
    55: {'arabic': 'Ar-Rahman', 'turkish': 'Rahmân', 'revelation': 'Madinah'},
    56: {'arabic': 'Al-Waqi\'ah', 'turkish': 'Vâkıa', 'revelation': 'Makkah'},
    57: {'arabic': 'Al-Hadid', 'turkish': 'Hadîd', 'revelation': 'Madinah'},
    58: {
      'arabic': 'Al-Mujadila',
      'turkish': 'Mücâdele',
      'revelation': 'Madinah'
    },
    59: {'arabic': 'Al-Hashr', 'turkish': 'Haşr', 'revelation': 'Madinah'},
    60: {
      'arabic': 'Al-Mumtahanah',
      'turkish': 'Mümtehine',
      'revelation': 'Madinah'
    },
    61: {'arabic': 'As-Saf', 'turkish': 'Saff', 'revelation': 'Madinah'},
    62: {'arabic': 'Al-Jumu\'ah', 'turkish': 'Cum\'a', 'revelation': 'Madinah'},
    63: {
      'arabic': 'Al-Munafiqun',
      'turkish': 'Münâfikūn',
      'revelation': 'Madinah'
    },
    64: {
      'arabic': 'At-Taghabun',
      'turkish': 'Teğâbün',
      'revelation': 'Madinah'
    },
    65: {'arabic': 'At-Talaq', 'turkish': 'Talâk', 'revelation': 'Madinah'},
    66: {'arabic': 'At-Tahrim', 'turkish': 'Tahrîm', 'revelation': 'Madinah'},
    67: {'arabic': 'Al-Mulk', 'turkish': 'Mülk', 'revelation': 'Makkah'},
    68: {'arabic': 'Al-Qalam', 'turkish': 'Kalem', 'revelation': 'Makkah'},
    69: {'arabic': 'Al-Haqqah', 'turkish': 'Hâkka', 'revelation': 'Makkah'},
    70: {'arabic': 'Al-Ma\'arij', 'turkish': 'Meâric', 'revelation': 'Makkah'},
    71: {'arabic': 'Nuh', 'turkish': 'Nûh', 'revelation': 'Makkah'},
    72: {'arabic': 'Al-Jinn', 'turkish': 'Cin', 'revelation': 'Makkah'},
    73: {
      'arabic': 'Al-Muzzammil',
      'turkish': 'Müzzemmil',
      'revelation': 'Makkah'
    },
    74: {
      'arabic': 'Al-Muddaththir',
      'turkish': 'Müddessir',
      'revelation': 'Makkah'
    },
    75: {'arabic': 'Al-Qiyamah', 'turkish': 'Kıyâme', 'revelation': 'Makkah'},
    76: {'arabic': 'Al-Insan', 'turkish': 'İnsan', 'revelation': 'Madinah'},
    77: {
      'arabic': 'Al-Mursalat',
      'turkish': 'Mürselât',
      'revelation': 'Makkah'
    },
    78: {'arabic': 'An-Naba', 'turkish': 'Nebe\'', 'revelation': 'Makkah'},
    79: {'arabic': 'An-Nazi\'at', 'turkish': 'Nâziât', 'revelation': 'Makkah'},
    80: {'arabic': '\'Abasa', 'turkish': 'Abese', 'revelation': 'Makkah'},
    81: {'arabic': 'At-Takwir', 'turkish': 'Tekvîr', 'revelation': 'Makkah'},
    82: {'arabic': 'Al-Infitar', 'turkish': 'İnfitār', 'revelation': 'Makkah'},
    83: {
      'arabic': 'Al-Mutaffifin',
      'turkish': 'Mutaffifîn',
      'revelation': 'Makkah'
    },
    84: {'arabic': 'Al-Inshiqaq', 'turkish': 'İnşikāk', 'revelation': 'Makkah'},
    85: {'arabic': 'Al-Buruj', 'turkish': 'Burûc', 'revelation': 'Makkah'},
    86: {'arabic': 'At-Tariq', 'turkish': 'Târık', 'revelation': 'Makkah'},
    87: {'arabic': 'Al-A\'la', 'turkish': 'A\'lâ', 'revelation': 'Makkah'},
    88: {'arabic': 'Al-Ghashiyah', 'turkish': 'Ğāşiye', 'revelation': 'Makkah'},
    89: {'arabic': 'Al-Fajr', 'turkish': 'Fecr', 'revelation': 'Makkah'},
    90: {'arabic': 'Al-Balad', 'turkish': 'Beled', 'revelation': 'Makkah'},
    91: {'arabic': 'Ash-Shams', 'turkish': 'Şems', 'revelation': 'Makkah'},
    92: {'arabic': 'Al-Layl', 'turkish': 'Leyl', 'revelation': 'Makkah'},
    93: {'arabic': 'Ad-Duhaa', 'turkish': 'Duhâ', 'revelation': 'Makkah'},
    94: {'arabic': 'Ash-Sharh', 'turkish': 'İnşirâh', 'revelation': 'Makkah'},
    95: {'arabic': 'At-Tin', 'turkish': 'Tîn', 'revelation': 'Makkah'},
    96: {'arabic': 'Al-\'Alaq', 'turkish': 'Alak', 'revelation': 'Makkah'},
    97: {'arabic': 'Al-Qadr', 'turkish': 'Kadir', 'revelation': 'Makkah'},
    98: {
      'arabic': 'Al-Bayyinah',
      'turkish': 'Beyyine',
      'revelation': 'Madinah'
    },
    99: {'arabic': 'Az-Zalzalah', 'turkish': 'Zilzâl', 'revelation': 'Madinah'},
    100: {'arabic': 'Al-\'Adiyat', 'turkish': 'Âdiyât', 'revelation': 'Makkah'},
    101: {'arabic': 'Al-Qari\'ah', 'turkish': 'Kāria', 'revelation': 'Makkah'},
    102: {
      'arabic': 'At-Takathur',
      'turkish': 'Tekâsür',
      'revelation': 'Makkah'
    },
    103: {'arabic': 'Al-\'Asr', 'turkish': 'Asr', 'revelation': 'Makkah'},
    104: {'arabic': 'Al-Humazah', 'turkish': 'Hümeze', 'revelation': 'Makkah'},
    105: {'arabic': 'Al-Fil', 'turkish': 'Fîl', 'revelation': 'Makkah'},
    106: {'arabic': 'Quraysh', 'turkish': 'Kureyş', 'revelation': 'Makkah'},
    107: {'arabic': 'Al-Ma\'un', 'turkish': 'Mâûn', 'revelation': 'Makkah'},
    108: {'arabic': 'Al-Kawthar', 'turkish': 'Kevser', 'revelation': 'Makkah'},
    109: {'arabic': 'Al-Kafirun', 'turkish': 'Kâfirûn', 'revelation': 'Makkah'},
    110: {'arabic': 'An-Nasr', 'turkish': 'Nasr', 'revelation': 'Madinah'},
    111: {'arabic': 'Al-Masad', 'turkish': 'Tebbet', 'revelation': 'Makkah'},
    112: {'arabic': 'Al-Ikhlas', 'turkish': 'İhlâs', 'revelation': 'Makkah'},
    113: {'arabic': 'Al-Falaq', 'turkish': 'Felak', 'revelation': 'Makkah'},
    114: {'arabic': 'An-Nas', 'turkish': 'Nâs', 'revelation': 'Makkah'},
  };

  return data[number] ??
      {'arabic': 'Unknown', 'turkish': 'Bilinmeyen', 'revelation': 'Makkah'};
}
