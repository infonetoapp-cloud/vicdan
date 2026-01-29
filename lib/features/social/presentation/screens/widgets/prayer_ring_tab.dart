import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vicdan_app/core/theme/app_colors.dart';
import 'package:vicdan_app/features/social/data/models/prayer_model.dart';
import 'package:vicdan_app/features/social/data/repositories/social_prayer_repository.dart';
import 'prayer_card.dart';

class PrayerRingTab extends StatelessWidget {
  const PrayerRingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prayer>>(
      stream: SocialPrayerRepository().getApprovedPrayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_outlined,
                    size: 60, color: AppColors.textLight.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  "Henüz halkada dua yok.\nİlk duayı sen bırakabilirsin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          );
        }

        final prayers = snapshot.data!;

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prayers.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: PrayerCard(prayer: prayers[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
