import 'package:flutter/material.dart';

/// SEHER VAKTİ (Ferah & Modern) - 2026 Design System
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // NEW PALETTE (FERAH)
  // ═══════════════════════════════════════════════════════════════

  // Ana Arka Plan Gradient (Sabit)
  static const Color backgroundTop = Color(0xFFF9FAF8); // Kırık Beyaz (Soft)
  static const Color backgroundBottom = Color(0xFFE8F5E9); // Çok Açık Yeşil

  // Ana Renkler
  static const Color primaryGreen =
      Color(0xFF5D8C72); // Pastel Zümrüt (Ana Metin, İkon)
  static const Color softGreen =
      Color(0xFFA5D6A7); // Yumuşak Yeşil (Ağaç, Dekor)
  static const Color accentGold =
      Color(0xFFD4AF37); // Altın (Vurgular, Vakitler)

  // Metin Renkleri
  static const Color textDark = Color(0xFF2C3E36); // Koyu Yeşil/Gri (Başlıklar)
  static const Color textLight =
      Color(0xFF6B7C75); // Grimsi Yeşil (Alt metinler)
  static const Color textInverse = Colors.white;

  // New Category Colors (2026)
  static const Color deepRose = Color(0xFFE57373); // Soft Red/Rose
  static const Color calmBlue = Color(0xFF64B5F6); // Soft Blue

  // Glassmorphism System
  static const Color glassSurface = Color(0xD9FFFFFF); // %85 Beyaz (Kartlar)
  static const Color glassBorder = Color(0x80FFFFFF); // %50 Beyaz (Kenarlıklar)
  static const Color glassShadow = Color(0x0D2C3E36); // Hafif Yeşil Gölge
  static const Color glassBackground = Color(0x1FFFFFFF); // 12% white

  // ═══════════════════════════════════════════════════════════════
  // LEGACY MAPPINGS (Backward Compatibility)
  // ═══════════════════════════════════════════════════════════════

  // Core Mapping
  static const Color sage = primaryGreen;
  static const Color eucalyptus =
      Color(0xFF81C784); // Mapped to fresh green (was blueish)
  static const Color seafoam = Color(0xFF4DB6AC); // Teal accent (was cyan)
  static const Color lavenderNight =
      primaryGreen; // Replaced with primary green
  static const Color deepIndigo = textDark;
  static const Color cosmicDust = textDark;
  static const Color nightSky =
      textDark; // Replaced with textDark (no more black)

  // Sunrise Spectrum -> Ferah Accents
  static const Color goldenHour = accentGold;
  static const Color warmCoral =
      Color(0xFFFF8A80); // Slightly softer coral for errors/alerts
  static const Color peachGlow = Color(0xFFFFCCBC);

  // Tree Mappings
  static const Color leafLight = softGreen;
  static const Color leafMedium = Color(0xFF81C784);
  static const Color leafDark = primaryGreen;
  static const Color leafDeep = Color(0xFF388E3C);
  static const Color trunk = Color(0xFF8D6E63); // Softer brown
  static const Color trunkLight = Color(0xFFA1887F);
  static const Color cherryBlossom = Color(0xFFE1BEE7); // Soft pink

  // Semantic Mappings
  static const Color surfaceCard = glassSurface;
  static const Color surfaceDark =
      backgroundTop; // Main background is now light
  static const Color surfaceCardHover = Color(0x2EFFFFFF);

  // Text Mappings
  static const Color textPrimary = textDark;
  static const Color textSecondary =
      Color(0xB32C3E36); // 70% opacity of textDark
  static const Color textTertiary =
      textLight; // 50% opacity of textDark mapped to Light
  static const Color textDisabled = Color(0x4D2C3E36); // 30% opacity

  // Functional Colors
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = accentGold;
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);
  static const Color mintPop = softGreen;

  // ═══════════════════════════════════════════════════════════════
  // SKY GRADIENTS (Forced to New Ferah Theme)
  // ═══════════════════════════════════════════════════════════════

  // We override ALL sky gradients to return the new "Seher Vakti" palette.
  // This instantly transforms the entire app background to the new look.

  static const List<Color> _ferahGradient = [
    backgroundTop,
    backgroundBottom,
  ];

  static const List<Color> skyDawn = _ferahGradient;
  static const List<Color> skyMorning = _ferahGradient;
  static const List<Color> skyNoon = _ferahGradient;
  static const List<Color> skyAfternoon = _ferahGradient;
  static const List<Color> skyEvening = [
    Color(0xFFF3E5F5), // Slight lavender tint for evening but still light
    Color(0xFFE8F5E9),
  ];
  static const List<Color> skyNight = [
    Color(0xFFE0F7FA), // Very light cool blue for night
    Color(0xFFE8F5E9),
  ];

  /// Get sky gradient based on hour (0-23)
  static List<Color> getSkyGradient(int hour) {
    // Return mostly the fresh gradient, maybe subtle shift for night
    if (hour >= 20 || hour < 5) return skyNight;
    if (hour >= 17 && hour < 20) return skyEvening;
    return _ferahGradient;
  }

  /// Get interpolated sky gradient with smooth transitions
  static LinearGradient getSkyGradientAnimated(double timeProgress) {
    int hour = (timeProgress * 24).floor() % 24;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: getSkyGradient(hour),
    );
  }
}
