import 'package:flutter/material.dart';

/// Base class for shareable story cards
abstract class ShareCard extends StatelessWidget {
  const ShareCard({super.key});

  /// All cards use Instagram Story size: 1080x1920
  static const double cardWidth = 1080;
  static const double cardHeight = 1920;
  static const double aspectRatio = cardWidth / cardHeight;
}

/// Gradient colors for different card types
class CardGradients {
  // Tree Story Card: Twilight gradient
  static const twilight = [
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
    Color(0xFF533483),
  ];

  // Cuma Card: Mosque green/gold
  static const mosque = [
    Color(0xFF0d4f2f),
    Color(0xFF1a6942),
    Color(0xFF228b22),
    Color(0xFFd4af37),
  ];

  // Kandil Card: Night sky
  static const kandil = [
    Color(0xFF0c0c1e),
    Color(0xFF1a1a3e),
    Color(0xFF2d2d5a),
    Color(0xFF4a4a8a),
  ];

  // Bayram Card: Festive
  static const bayram = [
    Color(0xFF1a237e),
    Color(0xFF3f51b5),
    Color(0xFFe91e63),
    Color(0xFFffc107),
  ];
}
