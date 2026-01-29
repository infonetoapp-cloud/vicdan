import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/surah.dart';

/// Glassmorphic card displaying a single surah in the list
///
/// Design principles:
/// - Glassmorphism aesthetic
/// - Clear hierarchy: Number → Name → Metadata
/// - Tappable with subtle feedback
/// - Accessible (semantic labels, contrast)
class SurahCard extends StatelessWidget {
  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Surah number badge
                _buildNumberBadge(context),

                const SizedBox(width: 16),

                // Surah names and metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Turkish name (primary)
                      Text(
                        surah.nameTurkish,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.2,
                                ),
                      ),

                      const SizedBox(height: 4),

                      // Arabic name (secondary)
                      Text(
                        surah.nameArabic,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),

                // Metadata (revelation place + ayah count)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Revelation badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: surah.isMakki
                            ? AppColors.accentGold.withOpacity(0.1)
                            : AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: surah.isMakki
                              ? AppColors.accentGold.withOpacity(0.3)
                              : AppColors.primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        surah.isMakki ? 'Mekki' : 'Medeni',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: surah.isMakki
                                  ? AppColors.accentGold
                                  : AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Ayah count
                    Text(
                      '${surah.totalAyahs} Ayet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the circular number badge
  Widget _buildNumberBadge(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryGreen.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${surah.number}',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
