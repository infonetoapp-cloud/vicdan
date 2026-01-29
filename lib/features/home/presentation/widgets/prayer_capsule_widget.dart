import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrayerCapsuleWidget extends StatelessWidget {

  const PrayerCapsuleWidget({
    super.key,
    required this.nextPrayerName,
    required this.timeRemaining,
  });
  final String nextPrayerName;
  final String timeRemaining;

  @override
  Widget build(BuildContext context) {
    if (nextPrayerName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          const Icon(Icons.access_time_rounded,
              color: AppColors.accentGold, size: 18),

          const SizedBox(width: 8),

          // Text
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$nextPrayerName ',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: timeRemaining,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFeatures: [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
