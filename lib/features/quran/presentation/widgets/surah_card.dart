import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/surah.dart';

/// Glassmorphic card displaying a single surah in the list
///
/// Design principles:
/// - Glassmorphism aesthetic
/// - Clear hierarchy: Number → Name → Metadata
/// - Tappable with subtle feedback
/// - Accessible (semantic labels, contrast)
class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Surah number badge
              _buildNumberBadge(),

              const SizedBox(width: 16),

              // Surah names and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Turkish name (primary)
                    Text(
                      surah.nameTurkish,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                    ),

                    const SizedBox(height: 4),

                    // Arabic name (secondary)
                    Text(
                      surah.nameArabic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
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
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: surah.isMakki
                            ? Colors.amber.withOpacity(0.5)
                            : Colors.green.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      surah.isMakki ? 'Mekki' : 'Medeni',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: surah.isMakki ? Colors.amber : Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Ayah count
                  Text(
                    '${surah.totalAyahs} Ayet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the circular number badge
  Widget _buildNumberBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '${surah.number}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
