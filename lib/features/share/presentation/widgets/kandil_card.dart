import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Kandil (Holy Night) sharing card
class KandilCard extends ShareCard {
  final String kandilName;
  final String message;

  const KandilCard({
    super.key,
    required this.kandilName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ShareCard.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: CardGradients.kandil,
          ),
        ),
        child: Stack(
          children: [
            // Stars and moon background
            ..._buildNightSky(),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("🌙", style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Text("✨", style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        "VİCDAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text("✨", style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text("🌙", style: TextStyle(fontSize: 28)),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Moon and stars
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      const Text("🌙", style: TextStyle(fontSize: 120)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stars row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("⭐", style: TextStyle(fontSize: 32)),
                      SizedBox(width: 20),
                      Text("✨", style: TextStyle(fontSize: 40)),
                      SizedBox(width: 20),
                      Text("⭐", style: TextStyle(fontSize: 32)),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Kandil name box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Column(
                      children: [
                        Text(
                          kandilName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "MÜBAREK OLSUN",
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "\"$message\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Watermark
                  Text(
                    "vicdan.app",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 18,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNightSky() {
    return List.generate(30, (i) {
      final isLargeStar = i % 5 == 0;
      return Positioned(
        left: (i * 47) % 380 + 10.0,
        top: (i * 73) % 700 + 30.0,
        child: Text(
          isLargeStar ? "⭐" : "✨",
          style: TextStyle(
            fontSize: isLargeStar ? 16.0 : 10.0,
            color: Colors.white.withOpacity(0.3 + (i % 4) * 0.1),
          ),
        ),
      );
    });
  }
}
