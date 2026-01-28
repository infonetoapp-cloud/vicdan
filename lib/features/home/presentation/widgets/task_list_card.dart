import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import 'task_item_widget.dart'; // Import the new widget

/// Task list card with Glassmorphism styling
class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.tasks,
    required this.completedCount,
    required this.onTaskToggle,
    required this.onHistoryTap,
  });

  final List<TaskEntity> tasks;
  final int completedCount;
  final Future<bool> Function(String taskId, bool completed) onTaskToggle;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24), // More rounded
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Stronger blur
        child: Container(
          padding: const EdgeInsets.all(20), // More spacing
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bugünün Görevleri',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // History Button (Small)
                      GestureDetector(
                        onTap: onHistoryTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // Subtle bg
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(LucideIcons.calendar,
                              size: 16,
                              color: AppColors.textTertiary.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completedCount/${tasks.length}',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 0), // handled by margin
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskItemWidget(
                      task: task,
                      onToggle: (completed) => onTaskToggle(task.id, completed),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              task: task,
                              onToggle: (completed) =>
                                  onTaskToggle(task.id, completed),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
