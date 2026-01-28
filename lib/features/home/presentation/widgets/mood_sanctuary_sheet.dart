import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'breathing_animation.dart';
import 'silent_dhikr_view.dart';
import 'gratitude_jar_view.dart';
import 'random_verse_view.dart';

enum MoodType { daraldim, huzur, sukur, karisik }

class MoodSanctuarySheet extends StatefulWidget {
  final MoodType mood;
  final VoidCallback onClose;

  const MoodSanctuarySheet({
    super.key,
    required this.mood,
    required this.onClose,
  });

  @override
  State<MoodSanctuarySheet> createState() => _MoodSanctuarySheetState();
}

class _MoodSanctuarySheetState extends State<MoodSanctuarySheet> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: _getBackgroundColor().withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.mood) {
      case MoodType.daraldim:
        return const Color(0xFFE0F7FA); // Soft Cyan
      case MoodType.huzur:
        return const Color(0xFFFFF8E1); // Soft Amber
      case MoodType.sukur:
        return const Color(0xFFE8F5E9); // Soft Green
      case MoodType.karisik:
        return const Color(0xFFF3E5F5); // Soft Purple
    }
  }

  Widget _buildContent() {
    switch (widget.mood) {
      case MoodType.daraldim:
        return _buildInshirahTherapy();
      case MoodType.huzur:
        return SilentDhikrView(onComplete: widget.onClose);
      case MoodType.sukur:
        return GratitudeJarView(onComplete: widget.onClose);
      case MoodType.karisik:
        return RandomVerseView(onComplete: widget.onClose);
    }
  }

  Widget _buildInshirahTherapy() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "İnşirah Terapisi",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Derin bir nefes al, bırak kalbin hafiflesin.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          const BreathingAnimation(),
          const Spacer(),
          // Close/Finish Button
          TextButton(
            onPressed: widget.onClose,
            child: Text(
              "Daha İyiyim",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
