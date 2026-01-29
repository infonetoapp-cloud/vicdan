import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'mood_sanctuary_sheet.dart';

/// 2026 Design: Organized "Glass Capsules" Row
/// "Sabit ama Canlı" - Anchored but breathing logic.
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
    // Subtle breathing animation for the entire row to make it feel "alive"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
    return SizedBox(
      height: 60, // Compact height
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCapsule(
                label: "Huzur",
                icon: "🕊️",
                baseColor: const Color(0xFFFFD54F), // Amber
                mood: MoodType.huzur,
                delay: 0.0,
              ),
              const SizedBox(width: 8), // Tighter spacing
              _buildCapsule(
                label: "Daraldım",
                icon: "😔",
                baseColor: const Color(0xFF4DD0E1), // Cyan
                mood: MoodType.daraldim,
                delay: 0.2,
              ),
              const SizedBox(width: 8),
              _buildCapsule(
                label: "Şükür",
                icon: "🙏",
                baseColor: const Color(0xFF66BB6A), // Green
                mood: MoodType.sukur,
                delay: 0.4,
              ),
              const SizedBox(width: 8),
              _buildCapsule(
                label: "Karışık",
                icon: "🤔",
                baseColor: const Color(0xFFB39DDB), // Light Purple
                mood: MoodType.karisik,
                delay: 0.6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsule({
    required String label,
    required String icon,
    required Color baseColor,
    required MoodType mood,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle Breathing Calculation
        final t = (_controller.value + delay) % 1.0;
        final scale =
            0.98 + (math.sin(t * math.pi * 2) * 0.02); // Just 2% breath
        final glowOpacity = 0.1 + (math.sin(t * math.pi * 2) * 0.05);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _openSanctuary(context, mood),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10), // Compact padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), // Ultra sheer glass
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: baseColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(glowOpacity),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 16), // Smaller icon
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 13, // Smaller text
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
