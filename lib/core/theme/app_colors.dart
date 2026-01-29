import 'package:flutter/material.dart';

/// SEHER VAKTİ (Ferah & Modern) - 2026 Design System
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // NEW PALETTE (FERAH & UYUMLU - 2026)
  // ═══════════════════════════════════════════════════════════════

  // Ana Arka Plan Gradient (Sabit)
  static const Color backgroundTop = Color(0xFFF7F9F9); // Ferah Gri-Beyaz
  static const Color backgroundBottom = Color(0xFFE8F5E9); // Çok Açık Yeşil

  // Cream Background for Text-Heavy Pages (Quran)
  static const Color creamBackground = Color(0xFFFFFAF0);

  // Ana Renkler
  static const Color primaryGreen = Color(0xFF2D7A67); // Koyu Yeşil (İslami)
  static const Color softGreen = Color(0xFF48BB78); // Success / Soft Green
  static const Color accentGold = Color(0xFFE8B85D); // Altın Sarısı (Mübarek)

  // Metin Renkleri
  static const Color textDark =
      Color(0xFF1A202C); // Neredeyse Siyah (Okunabilirlik)
  static const Color textLight = Color(0xFF4A5568); // Koyu Gri (İkincil)
  static const Color textInverse = Colors.white;

  // New Category Colors (2026)
  static const Color deepRose = Color(0xFFF56565); // Error / Rose
  static const Color calmBlue = Color(0xFF4299E1); // Info / Blue

  // Glassmorphism System
  static const Color glassSurface =
      Color(0xFFFFFFFF); // Kartlar Bembeyaz olsun (Clean)
  static const Color glassBorder = Color(0xFFE2E8F0); // İnce Gri Kenarlık
  static const Color glassShadow = Color(0x1A000000); // %10 Siyah Gölge
  static const Color glassBackground = Color(0xFFF7FAFC);

  // ═══════════════════════════════════════════════════════════════
  // LEGACY MAPPINGS (Backward Compatibility)
  // ═══════════════════════════════════════════════════════════════

  // Core Mapping
  static const Color sage = primaryGreen;
  static const Color eucalyptus = softGreen;
  static const Color seafoam = calmBlue;
  static const Color lavenderNight = primaryGreen; // Replaced
  static const Color deepIndigo = textDark;
  static const Color cosmicDust = textDark;
  static const Color nightSky = textDark;

  // Sunrise Spectrum -> Ferah Accents
  static const Color goldenHour = accentGold;
  static const Color warmCoral = deepRose;
  static const Color peachGlow = accentGold;

  // Tree Mappings
  static const Color leafLight = Color(0xFF9AE6B4);
  static const Color leafMedium = softGreen;
  static const Color leafDark = primaryGreen;
  static const Color leafDeep = Color(0xFF22543D);
  static const Color trunk = Color(0xFF8D6E63);
  static const Color trunkLight = Color(0xFFA1887F);
  static const Color cherryBlossom = Color(0xFFE1BEE7);

  // Semantic Mappings
  static const Color surfaceCard = Colors.white;
  static const Color surfaceDark = backgroundTop;
  static const Color surfaceCardHover = Color(0xFFEDF2F7);

  // Text Mappings
  static const Color textPrimary = textDark;
  static const Color textSecondary = textLight;
  static const Color textTertiary = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // Functional Colors
  static const Color success = softGreen;
  static const Color warning = accentGold;
  static const Color error = deepRose;
  static const Color info = calmBlue;
  static const Color mintPop = softGreen;

  // ═══════════════════════════════════════════════════════════════
  // SKY GRADIENTS (Forced to New Ferah Theme)
  // ═══════════════════════════════════════════════════════════════

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
