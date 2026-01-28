import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Bayram (Eid) sharing card
class BayramCard extends ShareCard {
  final String bayramName;
  final String message;

  const BayramCard({
    super.key,
    required this.bayramName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ShareCard.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: CardGradients.bayram,
          ),
        ),
        child: Stack(
          children: [
            // Festive decorations
            ..._buildFestiveElements(),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("🎉", style: TextStyle(fontSize: 28)),
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
                      Text("🎊", style: TextStyle(fontSize: 28)),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Festive icons row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🌙", style: TextStyle(fontSize: 50)),
                      SizedBox(width: 30),
                      Text("🕌", style: TextStyle(fontSize: 70)),
                      SizedBox(width: 30),
                      Text("🌙", style: TextStyle(fontSize: 50)),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Fireworks
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🎆", style: TextStyle(fontSize: 40)),
                      SizedBox(width: 20),
                      Text("🎇", style: TextStyle(fontSize: 50)),
                      SizedBox(width: 20),
                      Text("🎆", style: TextStyle(fontSize: 40)),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Bayram message box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber.shade400,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          bayramName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "MÜBAREK OLSUN!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Message
                  Text(
                    "\"$message\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
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

  List<Widget> _buildFestiveElements() {
    return [
      // Confetti simulation
      ...List.generate(15, (i) {
        final emojis = ["🎉", "🎊", "✨", "🌟"];
        return Positioned(
          left: (i * 67) % 380 + 10.0,
          top: (i * 89) % 800 + 20.0,
          child: Transform.rotate(
            angle: i * 0.5,
            child: Text(
              emojis[i % emojis.length],
              style: TextStyle(
                fontSize: 20 + (i % 3) * 8.0,
                color: Colors.white.withOpacity(0.2 + (i % 4) * 0.05),
              ),
            ),
          ),
        );
      }),
    ];
  }
}
