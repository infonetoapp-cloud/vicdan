import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/journey_item.dart';

enum JourneyCardStatus { locked, unlocked, completed }

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.item,
    required this.status,
    required this.onTap,
  });
  final JourneyItem item;
  final JourneyCardStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: status == JourneyCardStatus.unlocked ? 2 : 1,
          ),
          boxShadow: status == JourneyCardStatus.unlocked
              ? [
                  BoxShadow(
                    color: AppColors.goldenHour.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glass effect for all
              Container(color: Colors.white.withOpacity(0.05)),

              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == JourneyCardStatus.locked)
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.grey, // Visible grey on light bg
                      size: 20,
                    )
                  else if (status == JourneyCardStatus.completed)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white, // White on Green
                      size: 24,
                    )
                  else
                    Text(
                      '${item.day}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                ],
              ),

              // Locked overlay
              if (status == JourneyCardStatus.locked)
                Container(color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case JourneyCardStatus.locked:
        return Colors.black.withOpacity(0.05); // Light grey
      case JourneyCardStatus.unlocked:
        return Colors.white;
      case JourneyCardStatus.completed:
        return AppColors.primaryGreen; // Solid Green
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case JourneyCardStatus.locked:
        return Colors.white10;
      case JourneyCardStatus.unlocked:
        return AppColors.goldenHour;
      case JourneyCardStatus.completed:
        return AppColors.sage;
    }
  }
}
