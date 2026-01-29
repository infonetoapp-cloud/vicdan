/// 2026 VİCDAN Tevafuk Engine Database
/// Contains categorized verses and hadiths for intelligent guidance.

enum TevafukCategory {
  umut, // Hope
  sabir, // Patience
  sukur, // Gratitude
  huzur, // Peace
  uyari, // Warning/Reflection
  rizik, // Sustenance
}

class TevafukItem {
  final String text;
  final String source;
  final List<TevafukCategory> categories;

  const TevafukItem({
    required this.text,
    required this.source,
    required this.categories,
  });
}

class TevafukDatabase {
  static const List<TevafukItem> allItems = [
    // --- UMUT (Hope) ---
    TevafukItem(
      text: "Rabbin, seni terk etmedi ve sana darılmadı.",
      source: "Duha Suresi, 3",
      categories: [TevafukCategory.umut, TevafukCategory.huzur],
    ),
    TevafukItem(
      text: "Şüphesiz güçlükle beraber bir kolaylık vardır.",
      source: "İnşirah Suresi, 5",
      categories: [TevafukCategory.umut, TevafukCategory.sabir],
    ),
    TevafukItem(
      text: "Allah'ın rahmetinden ümit kesmeyin.",
      source: "Zümer Suresi, 53",
      categories: [TevafukCategory.umut],
    ),
    TevafukItem(
      text:
          "Olur ki siz bir şeyden hoşlanmazsınız, halbuki o sizin için bir hayırdır.",
      source: "Bakara Suresi, 216",
      categories: [TevafukCategory.umut, TevafukCategory.sabir],
    ),

    // --- SABIR (Patience) ---
    TevafukItem(
      text: "Allah sabredenlerle beraberdir.",
      source: "Bakara Suresi, 153",
      categories: [TevafukCategory.sabir],
    ),
    TevafukItem(
      text: "Sabret! Senin sabrın ancak Allah'ın yardımı iledir.",
      source: "Nahl Suresi, 127",
      categories: [TevafukCategory.sabir],
    ),
    TevafukItem(
      text: "Güzel sabır (sabr-ı cemil) dile.",
      source: "Mearic Suresi, 5",
      categories: [TevafukCategory.sabir, TevafukCategory.huzur],
    ),

    // --- ŞÜKÜR (Gratitude) ---
    TevafukItem(
      text: "Eğer şükrederseniz, elbette size (nimetimi) artırırım.",
      source: "İbrahim Suresi, 7",
      categories: [TevafukCategory.sukur, TevafukCategory.rizik],
    ),
    TevafukItem(
      text: "O (Allah), size verdiği şeylerle sizi denemek ister.",
      source: "Maide Suresi, 48",
      categories: [TevafukCategory.sukur, TevafukCategory.uyari],
    ),

    // --- RIZIK (Sustenance) ---
    TevafukItem(
      text: "Yeryüzünde yürüyen her canlının rızkı, yalnızca Allah'a aittir.",
      source: "Hud Suresi, 6",
      categories: [TevafukCategory.rizik, TevafukCategory.huzur],
    ),
    TevafukItem(
      text: "Bilsin ki insan için kendi çalışmasından başka bir şey yoktur.",
      source: "Necm Suresi, 39",
      categories: [TevafukCategory.rizik, TevafukCategory.uyari],
    ),

    // --- HUZUR (Peace) ---
    TevafukItem(
      text: "Kalpler ancak Allah'ı anmakla huzur bulur.",
      source: "Rad Suresi, 28",
      categories: [TevafukCategory.huzur],
    ),
    TevafukItem(
      text: "O, kullarının tövbesini kabul eden, kötülükleri bağışlayandır.",
      source: "Şura Suresi, 25",
      categories: [TevafukCategory.huzur, TevafukCategory.umut],
    ),

    // --- UYARI (Warning/Reflection) ---
    TevafukItem(
      text: "Bu dünya hayatı ancak bir eğlence ve oyundan ibarettir.",
      source: "Ankebut Suresi, 64",
      categories: [TevafukCategory.uyari],
    ),
    TevafukItem(
      text: "Nereye giderseniz gidin, O sizinle beraberdir.",
      source: "Hadid Suresi, 4",
      categories: [TevafukCategory.uyari, TevafukCategory.huzur],
    ),
  ];

  /// Returns a random item, optionally filtered by category priority
  static TevafukItem getRandomItem({TevafukCategory? priorityCategory}) {
    List<TevafukItem> pool = List.from(allItems); // Create mutable copy

    // Simple logic: If priority category exists, give it 3x weight by adding it to pool again
    if (priorityCategory != null) {
      final priorityItems = allItems
          .where((i) => i.categories.contains(priorityCategory))
          .toList();
      if (priorityItems.isNotEmpty) {
        pool.addAll(priorityItems);
        pool.addAll(priorityItems); // Add twice more for weight
      }
    }

    // Shuffle and pick
    pool.shuffle();
    return pool.first;
  }
}
