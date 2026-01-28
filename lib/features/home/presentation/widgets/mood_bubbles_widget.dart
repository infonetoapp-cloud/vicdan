import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'mood_sanctuary_sheet.dart';

/// 2026 Design: Mood Orbs (Glass & Light)
class MoodBubblesWidget extends StatefulWidget {
  const MoodBubblesWidget({super.key});

  @override
  State<MoodBubblesWidget> createState() => _MoodBubblesWidgetState();
}

class _MoodBubblesWidgetState extends State<MoodBubblesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Continuous organic floating animation for all bubbles
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Slower, more calming
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSanctuary(BuildContext context, MoodType mood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodSanctuarySheet(
        mood: mood,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // "Daraldım" (Mavi/Turkuaz Nur)
        _buildGlassOrb(
          label: "Daraldım",
          icon: "😔",
          alignment: const Alignment(-0.85, -0.65),
          baseColor: const Color(0xFF4DD0E1), // Cyan
          mood: MoodType.daraldim,
          phaseShift: 0.0,
        ),

        // "Huzur" (Altın Nur)
        _buildGlassOrb(
          label: "Huzur",
          icon: "🕊️",
          alignment: const Alignment(0.85, -0.55),
          baseColor: const Color(0xFFFFD54F), // Amber
          mood: MoodType.huzur,
          phaseShift: 0.25,
        ),

        // "Şükür" (Zümrüt Yeşili)
        _buildGlassOrb(
          label: "Şükür",
          icon: "🙏",
          alignment: const Alignment(-0.8, 0.45),
          baseColor: const Color(0xFF66BB6A), // Green
          mood: MoodType.sukur,
          phaseShift: 0.5,
        ),

        // "Karışık" (İnci Beyazı)
        _buildGlassOrb(
          label: "Karışık",
          icon: "🤔",
          alignment: const Alignment(0.8, 0.55),
          baseColor: const Color(0xFFB39DDB), // Light Purple
          mood: MoodType.karisik,
          phaseShift: 0.75,
        ),
      ],
    );
  }

  Widget _buildGlassOrb({
    required String label,
    required String icon,
    required Alignment alignment,
    required Color baseColor,
    required MoodType mood,
    required double phaseShift,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Organic Float Math
        final t = _controller.value;
        final floatY = math.sin((t + phaseShift) * math.pi * 2) * 12.0;
        final floatX = math.cos((t + phaseShift) * math.pi) * 8.0;

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(floatX, floatY),
            child: GestureDetector(
              onTap: () => _openSanctuary(context, mood),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.15), // Glass tint
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: -2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Inner Glow Dot
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: baseColor.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "$icon $label",
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
