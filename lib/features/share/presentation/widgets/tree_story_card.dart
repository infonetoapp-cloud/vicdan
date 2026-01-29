import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Tree Story Card - Shows user's tree with streak count
class TreeStoryCard extends ShareCard {

  const TreeStoryCard({
    super.key,
    required this.streakDays,
    required this.healthScore,
    this.motivationalQuote = 'Adım adım, yaprak yaprak 🌿',
  });
  final int streakDays;
  final double healthScore;
  final String motivationalQuote;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ShareCard.aspectRatio,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: CardGradients.twilight,
          ),
        ),
        child: Stack(
          children: [
            // Stars background
            ..._buildStars(),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                children: [
                  // Header with clouds
                  const Text(
                    '☁️  VİCDAN  ☁️',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Tree visualization
                  _buildTree(),

                  const Spacer(),

                  // Streak text
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$streakDays gündür bu yoldayım',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Motivational quote
                  Text(
                    '"$motivationalQuote"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Watermark
                  Text(
                    'vicdan.app',
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

  Widget _buildTree() {
    // Tree size based on health score
    final treeSize = 180 + (healthScore * 1.5);
    final leafCount = (healthScore / 10).round();
    final glowIntensity = healthScore / 100;

    return Container(
      width: treeSize,
      height: treeSize * 1.3,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(glowIntensity * 0.5),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trunk
          Positioned(
            bottom: 0,
            child: Container(
              width: 30,
              height: treeSize * 0.4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Canopy (leaves)
          Positioned(
            top: 0,
            child: Container(
              width: treeSize,
              height: treeSize * 0.8,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade700,
                    Colors.green.shade900,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🌳',
                  style: TextStyle(fontSize: treeSize * 0.5),
                ),
              ),
            ),
          ),

          // Decorative leaves
          ...List.generate(leafCount.clamp(0, 8), (i) {
            return Positioned(
              left: treeSize / 2 + (treeSize * 0.24) * (i.isEven ? 1 : -1) - 15,
              top: treeSize * 0.3 + (i * 15),
              child: Text(
                '🌿',
                style: TextStyle(fontSize: 30 + (i * 2).toDouble()),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    return List.generate(20, (i) {
      return Positioned(
        left: (i * 53) % 350 + 20.0,
        top: (i * 97) % 600 + 50.0,
        child: Text(
          i.isEven ? '✨' : '⭐',
          style: TextStyle(
            fontSize: 12 + (i % 3) * 6.0,
            color: Colors.white.withOpacity(0.3 + (i % 5) * 0.1),
          ),
        ),
      );
    });
  }
}
