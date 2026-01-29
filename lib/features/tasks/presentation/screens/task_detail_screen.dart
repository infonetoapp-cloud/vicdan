import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_category.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onToggle,
  });

  final TaskEntity task;
  final Future<bool> Function(bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.textDark),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Text(
                      _getCategoryName(task.category),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Large Icon
                    Hero(
                      tag: 'task_icon_${task.id}',
                      child: Icon(
                        _getCategoryIcon(task.category),
                        size: 80,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Hero(
                      tag: 'task_title_${task.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          task.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        task.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // XP Value
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accentGold.withOpacity(0.5)),
                      ),
                      child: Text(
                        '+${task.xpValue} Vicdan Puanı',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (!task.isCompleted) ...[
                    // Complete Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await onToggle(true);
                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(context); // Success, close
                            } else {
                              // Encouragement
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hadi, başarabilirsin! 💪'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: AppColors.accentGold,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Tamamla',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Skip Button
                    TextButton(
                      onPressed: () {
                        // For now just close, assume skip
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Bugünü Pas Geç',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Completed State
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 48, color: AppColors.success),
                          SizedBox(height: 8),
                          Text(
                            'Tamamlandı',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        onToggle(false); // Undo
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Geri Al',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return Icons.nights_stay_rounded; // Moon/Mosque vibe
      case TaskCategory.iyilik:
        return Icons.volunteer_activism_rounded; // Heart hand
      case TaskCategory.zihin:
        return Icons.psychology_rounded; // Mind/Flower
    }
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return 'İbadet';
      case TaskCategory.iyilik:
        return 'İyilik';
      case TaskCategory.zihin:
        return 'Zihin';
    }
  }
}
