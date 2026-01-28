import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/journey_item.dart';

enum JourneyCardStatus { locked, unlocked, completed }

class JourneyCard extends StatelessWidget {
  final JourneyItem item;
  final JourneyCardStatus status;
  final VoidCallback onTap;

  const JourneyCard({
    super.key,
    required this.item,
    required this.status,
    required this.onTap,
  });

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
                      color: Colors.white30,
                      size: 20,
                    )
                  else if (status == JourneyCardStatus.completed)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.sage,
                      size: 24,
                    )
                  else
                    Text(
                      "${item.day}",
                      style: const TextStyle(
                        color: AppColors.goldenHour,
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
        return Colors.white.withOpacity(0.05);
      case JourneyCardStatus.unlocked:
        return AppColors.surfaceCard;
      case JourneyCardStatus.completed:
        return AppColors.sage.withOpacity(0.2);
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
