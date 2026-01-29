import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ayah.dart';

/// Widget for displaying a single ayah (verse) with Arabic text and translation
///
/// Design principles:
/// - Arabic text prominently displayed (larger, right-aligned)
/// - Turkish translation below (smaller, left-aligned)
/// - Ayah number badge
/// - Glassmorphism aesthetic replaced with Clean Readability (Paper Style)
/// - Tappable for interactions (bookmark, copy, etc.)
class AyahWidget extends StatelessWidget {
  const AyahWidget({
    super.key,
    required this.ayah,
    this.onTap,
    this.isBookmarked = false,
    this.isActive = false,
  });
  final Ayah ayah;
  final VoidCallback? onTap;
  final bool isBookmarked;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withOpacity(0.1)
            : Colors.transparent, // Clean look
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(
                color: AppColors.primaryGreen.withOpacity(0.5), width: 1.5)
            : Border.all(color: AppColors.textDark.withOpacity(0.05), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20), // Increased padding
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
                        color: AppColors.accentGold,
                        size: 24,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Arabic text (right-aligned, larger)
                Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    color: AppColors.textDark, // #1A202C
                    fontWeight: FontWeight.w500,
                    height: 2.2, // Very generous line height
                    fontSize: 26, // Significantly larger
                  ),
                ),

                const SizedBox(height: 16),

                // Divider (Subtle)
                Container(
                  height: 1,
                  color: AppColors.textDark.withOpacity(0.1),
                ),

                const SizedBox(height: 16),

                // Turkish translation (left-aligned, smaller)
                Text(
                  ayah.translation,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDark.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        letterSpacing: 0.3,
                        fontSize: 17, // Readable size
                        fontFamily: 'Inter', // Ensure Inter is used here
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
            ? AppColors.primaryGreen.withOpacity(0.2)
            : AppColors.textDark.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${ayah.number}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
      ),
    );
  }
}
