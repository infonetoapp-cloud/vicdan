import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class RandomVerseView extends StatefulWidget {
  final VoidCallback onComplete;
  const RandomVerseView({super.key, required this.onComplete});

  @override
  State<RandomVerseView> createState() => _RandomVerseViewState();
}

class _RandomVerseViewState extends State<RandomVerseView>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Temporary list of verses (Tevafuk)
  final List<Map<String, String>> _verses = [
    {
      "text": "Rabbin, seni terk etmedi ve sana darılmadı.",
      "source": "Duha Suresi, 3"
    },
    {
      "text": "Şüphesiz güçlükle beraber bir kolaylık vardır.",
      "source": "İnşirah Suresi, 5"
    },
    {"text": "Allah sabredenlerle beraberdir.", "source": "Bakara Suresi, 153"},
    {
      "text": "Sabret! Senin sabrın ancak Allah'ın yardımı iledir.",
      "source": "Nahl Suresi, 127"
    },
    {
      "text": "Bilsin ki insan için kendi çalışmasından başka bir şey yoktur.",
      "source": "Necm Suresi, 39"
    },
  ];

  late Map<String, String> _selectedVerse;

  @override
  void initState() {
    super.initState();
    _selectedVerse = _verses[Random().nextInt(_verses.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openEnvelope() {
    setState(() {
      _isOpened = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isOpened) ...[
            const Text(
              "Tevafuk",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Senin için bir mesaj var.\nKalbinle niyet et ve aç.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _openEnvelope,
              child: Container(
                width: 200,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6CA), // Envelope color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border:
                      Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                ),
                child: Center(
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 48,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("(Dokun)",
                style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ] else ...[
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppColors.accentGold, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          _selectedVerse['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.6,
                            fontFamily: 'Playfair Display',
                            fontStyle: FontStyle.italic,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _selectedVerse['source']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: widget.onComplete,
              child: const Text("Aldım, Kabul Ettim",
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600)),
            )
          ]
        ],
      ),
    );
  }
}
