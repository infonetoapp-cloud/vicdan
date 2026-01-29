import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicdan_app/core/services/vicdan_ai_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'breathing_animation.dart';
import 'silent_dhikr_view.dart';
import 'gratitude_jar_view.dart';
import 'random_verse_view.dart';
import '../../../../features/social/data/services/social_roots_service.dart';

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
  String? _prescription;
  bool _isLoading = true;
  bool _prayerRequested = false;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    // 1. Convert Enum to String for Prompt
    final String moodText = _getMoodString();

    // 2. Call Service
    // Note: In a real app we would use Riverpod properly, but for this rapid iteration:
    try {
      final prefs = await SharedPreferences.getInstance(); // Quick dirty ref
      final service = VicdanAIService(prefs);
      final result = await service.getPrescription(moodText);

      if (mounted) {
        setState(() {
          _prescription = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prescription =
              "Ayet: 'Rabbin seni terk etmedi.' (Duha, 3)\nTavsiye: Kalbini ferah tut.";
          _isLoading = false;
        });
      }
    }
  }

  String _getMoodString() {
    switch (widget.mood) {
      case MoodType.daraldim:
        return "Daralıyorum, içim sıkılıyor";
      case MoodType.huzur:
        return "Huzurluyum ama derinleşmek istiyorum";
      case MoodType.sukur:
        return "Çok şükür, teşekkür etmek istiyorum";
      case MoodType.karisik:
        return "Kafam karışık, bir yol göster";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90, // Taller sheet
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
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 1. TOP SECTION: AI Prescription (Vicdan'ın Sesi)
            // Displays loading state or the AI advice.
            _buildAIHeader(),

            // Divider
            Divider(color: AppColors.textLight.withOpacity(0.1), height: 1),

            // 2. BOTTOM SECTION: Interactive Feature (Eylem Alanı)
            // Restoring original features (Gratitude Jar, Dhikr, etc.)
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(0)),
                child: _buildInteractiveFeature(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top AI section. Minimalist and non-intrusive.
  Widget _buildAIHeader() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_getMoodIcon(), size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  "Vicdanın Sesi",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              Text(
                "Senin için kalbine dokunacak bir ayet aranıyor...",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              )
            else
              Text(
                _prescription ?? "",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  height: 1.5,
                  fontFamily: 'Playfair Display',
                ),
                maxLines: 6, // Limit height so it doesn't take over
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Restores the original interactive features
  Widget _buildInteractiveFeature() {
    switch (widget.mood) {
      case MoodType.daraldim:
        // Hybrid: Breathing + Prayer Request
        return _buildInshirahTherapyHybrid();
      case MoodType.huzur:
        return SilentDhikrView(onComplete: widget.onClose);
      case MoodType.sukur:
        return GratitudeJarView(onComplete: widget.onClose);
      case MoodType.karisik:
        return RandomVerseView(onComplete: widget.onClose);
    }
  }

  Widget _buildInshirahTherapyHybrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const BreathingAnimation(),
        const Spacer(),
        // Prayer Request Button inside the therapy view
        if (!_prayerRequested)
          TextButton.icon(
            onPressed: () async {
              setState(() => _prayerRequested = true);
              await SocialRootsService().emitSignal();
            },
            icon:
                const Icon(Icons.favorite_border, color: AppColors.accentGold),
            label: Text(
              "Bana Dua Edin",
              style: TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.accentGold.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Dua İsteği Gönderildi",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        // Close Button
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
    );
  }

  IconData _getMoodIcon() {
    switch (widget.mood) {
      case MoodType.daraldim:
        return Icons.cloud_outlined;
      case MoodType.huzur:
        return Icons.wb_sunny_outlined;
      case MoodType.sukur:
        return Icons.volunteer_activism_outlined;
      case MoodType.karisik:
        return Icons.gesture;
    }
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
}
