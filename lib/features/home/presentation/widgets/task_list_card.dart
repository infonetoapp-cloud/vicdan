import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_category.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bugünün Görevleri',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Her gece yenilenir',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onHistoryTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.calendar,
                          size: 16, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  '$completedCount/${tasks.length}',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Horizontal List
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tasks.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildHorizontalTaskCard(context, task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalTaskCard(BuildContext context, TaskEntity task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(
              task: task,
              onToggle: (completed) => onTaskToggle(task.id, completed),
            ),
          ),
        );
      },
      child: Container(
        width: 130, // Compact width
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppColors.primaryGreen.withOpacity(0.1) // Light Green
              : Colors.white, // Solid White
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.isCompleted
                ? AppColors.primaryGreen.withOpacity(0.3)
                : AppColors.glassBorder, // Subtle border
            width: 1,
          ),
          boxShadow: [
            if (!task.isCompleted)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon and Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTaskIcon(task.category),
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
                // Checkbox
                GestureDetector(
                  onTap: () => onTaskToggle(task.id, !task.isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primaryGreen
                            : AppColors.textDisabled,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),

            // Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: task.isCompleted
                        ? AppColors.textLight.withOpacity(0.7) // Visible grey
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.primaryGreen, // Green line
                  ),
                ),
              ),
            ),

            // XP Footnote
            if (task.xpValue > 0 && !task.isCompleted)
              Text(
                '+${task.xpValue} Puan',
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTaskIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return LucideIcons.moon;
      case TaskCategory.iyilik:
        return LucideIcons.heart_handshake;
      case TaskCategory.zihin:
        return LucideIcons.flower;
    }
  }
}
