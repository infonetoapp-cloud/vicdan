import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sky_gradient_background.dart';
import '../../../../shared/widgets/glass_card.dart';
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
      body: SkyGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        _getCategoryName(task.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
                        child: Text(
                          _getCategoryIcon(task.category),
                          style: const TextStyle(fontSize: 80),
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
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      GlassCard(
                        opacity: 0.1,
                        child: Text(
                          task.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
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
                          color: AppColors.goldenHour.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.goldenHour.withOpacity(0.5)),
                        ),
                        child: Text(
                          "+${task.xpValue} Vicdan Puanı",
                          style: const TextStyle(
                            color: AppColors.goldenHour,
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
                                    backgroundColor: AppColors.goldenHour,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sage,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.sage.withOpacity(0.5),
                          ),
                          child: const Text(
                            "Tamamla",
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
                          "Bugünü Pas Geç",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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
                          color: AppColors.sage.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.sage.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.check_circle,
                                size: 48, color: AppColors.sage),
                            SizedBox(height: 8),
                            Text(
                              "Tamamlandı",
                              style: TextStyle(
                                color: Colors.white,
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
                          "Geri Al",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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
      ),
    );
  }

  String _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return '🕌';
      case TaskCategory.iyilik:
        return '💖';
      case TaskCategory.zihin:
        return '🧠';
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
