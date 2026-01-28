import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class MoodBubblesWidget extends StatefulWidget {
  final VoidCallback? onMoodSelected;

  const MoodBubblesWidget({
    super.key,
    this.onMoodSelected,
  });

  @override
  State<MoodBubblesWidget> createState() => _MoodBubblesWidgetState();
}

class _MoodBubblesWidgetState extends State<MoodBubblesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Continuous floating animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slow organic movement
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left Top - "Daraldım"
        _buildBubble(
          label: "Daraldım",
          icon: "😔",
          alignment: const Alignment(-0.8, -0.6),
          delay: 0,
          color: AppColors.primaryGreen.withOpacity(0.1),
        ),

        // Right Top - "Huzur"
        _buildBubble(
          label: "Huzur",
          icon: "🕊️",
          alignment: const Alignment(0.8, -0.5),
          delay: 1.5,
          color: AppColors.accentGold.withOpacity(0.1),
        ),

        // Left Bottom - "Şükür"
        _buildBubble(
          label: "Şükür",
          icon: "🙏",
          alignment: const Alignment(-0.7, 0.4),
          delay: 0.8,
          color: AppColors.softGreen.withOpacity(0.1),
        ),

        // Right Bottom - "Karışık"
        _buildBubble(
          label: "Karışık",
          icon: "🤔",
          alignment: const Alignment(0.75, 0.5),
          delay: 2.2,
          color: AppColors.textLight.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildBubble({
    required String label,
    required String icon,
    required Alignment alignment,
    required double delay,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate organic float offset
        final t = _controller.value;
        final offset =
            math.sin((t + delay) * math.pi * 2) * 15.0; // +/- 15px move

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: GestureDetector(
              onTap: () {
                // Trigger Prescription Flow
                _showPrescriptionSheet(context, label);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glassShadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPrescriptionSheet(BuildContext context, String mood) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PrescriptionSheet(mood: mood),
    );
  }
}

class _PrescriptionSheet extends StatelessWidget {
  final String mood;
  const _PrescriptionSheet({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundTop,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Text(
                  "Hissiyatın: $mood",
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Senin Reçeten",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Prescription Content Card (Ayet/Hadis)
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppColors.accentGold, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          _getPrescriptionText(mood),
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            color: AppColors.textDark,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Playfair Display',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "İnşirah Suresi, 5-6",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildActionCard(
                        icon: Icons.mosque_rounded,
                        label: "Zikret",
                        color: AppColors.primaryGreen,
                        onTap: () {}),
                    _buildActionCard(
                        icon: Icons.menu_book_rounded,
                        label: "Oku",
                        color: AppColors.accentGold,
                        onTap: () {}),
                    _buildActionCard(
                        icon: Icons.headphones_rounded,
                        label: "Dinle",
                        color: AppColors.softGreen,
                        onTap: () {}),
                    _buildActionCard(
                        icon: Icons.share_rounded,
                        label: "Paylaş",
                        color: AppColors.textLight,
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPrescriptionText(String mood) {
    if (mood == "Daraldım")
      return "Muhakkak ki, zorlukla beraber bir kolaylık vardır.";
    if (mood == "Huzur") return "Kalpler ancak Allah'ı anmakla huzur bulur.";
    if (mood == "Şükür")
      return "Eğer şükrederseniz, size olan nimetimi mutlaka artırırım.";
    return "Allah sabredenlerle beraberdir.";
  }

  Widget _buildActionCard(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
