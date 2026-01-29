import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Cuma (Friday) sharing card
class CumaCard extends ShareCard {

  const CumaCard({
    super.key,
    this.customMessage = 'Cuma günü dua kabul edilir,\ndualarınız kabul olsun',
  });
  final String customMessage;

  static const List<String> cumaMessages = [
    'Cuma günü dua kabul edilir,\ndualarınız kabul olsun',
    'Hayırlı Cumalar,\ndualarınız kabul olsun',
    'Bu mübarek günde\nkalplerimiz huzur bulsun',
    "Cuma'nızı tebrik eder,\nhayırlara vesile olmasını dileriz",
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ShareCard.aspectRatio,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: CardGradients.mosque,
          ),
        ),
        child: Stack(
          children: [
            // Decorative pattern
            ..._buildMosquePattern(),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                children: [
                  // Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🕌', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 16),
                      Text(
                        'VİCDAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('🕌', style: TextStyle(fontSize: 32)),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Crescent and star
                  const Text(
                    '☪️',
                    style: TextStyle(fontSize: 100),
                  ),

                  const SizedBox(height: 60),

                  // Main message box
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hayırlı Cumalar',
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Secondary message
                  Text(
                    customMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 3),

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

  List<Widget> _buildMosquePattern() {
    return [
      // Top decorative elements
      Positioned(
        top: 100,
        left: 20,
        child: Text('🌿',
            style:
                TextStyle(fontSize: 40, color: Colors.white.withOpacity(0.2))),
      ),
      Positioned(
        top: 100,
        right: 20,
        child: Text('🌿',
            style:
                TextStyle(fontSize: 40, color: Colors.white.withOpacity(0.2))),
      ),
      // Bottom mosque silhouette simulation
      Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => Text('🕌',
                style: TextStyle(
                    fontSize: 30, color: Colors.white.withOpacity(0.15))),
          ),
        ),
      ),
    ];
  }
}
