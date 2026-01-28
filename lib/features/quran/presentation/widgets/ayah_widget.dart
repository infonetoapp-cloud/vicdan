import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/ayah.dart';

/// Widget for displaying a single ayah (verse) with Arabic text and translation
///
/// Design principles:
/// - Arabic text prominently displayed (larger, right-aligned)
/// - Turkish translation below (smaller, left-aligned)
/// - Ayah number badge
/// - Glassmorphism aesthetic
/// - Tappable for interactions (bookmark, copy, etc.)
class AyahWidget extends StatelessWidget {
  final Ayah ayah;
  final VoidCallback? onTap;
  final bool isBookmarked;
  final bool isActive;

  const AyahWidget({
    super.key,
    required this.ayah,
    this.onTap,
    this.isBookmarked = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.goldenHour.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(
                color: AppColors.goldenHour.withOpacity(0.5), width: 1.5)
            : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.goldenHour.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah number and bookmark row
                Row(
                  children: [
                    // Number badge
                    _buildNumberBadge(context),

                    const Spacer(),

                    // Bookmark icon (if bookmarked)
                    if (isBookmarked)
                      const Icon(
                        Icons.bookmark,
                        color: AppColors.goldenHour,
                        size: 20,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Arabic text (right-aligned, larger)
                Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 2.0, // Generous line height for readability
                        letterSpacing: 0.5,
                        fontSize: 22,
                      ),
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Turkish translation (left-aligned, smaller)
                Text(
                  ayah.translation,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        letterSpacing: 0.3,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the ayah number badge
  Widget _buildNumberBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.goldenHour.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${ayah.number}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
      ),
    );
  }
}
