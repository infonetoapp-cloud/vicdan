import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_category.dart';
import '../../../../shared/widgets/animated_checkbox.dart';

/// Modern, Spacious Task Item for 2026 UI
class TaskItemWidget extends StatefulWidget {
  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final TaskEntity task;
  final Future<bool> Function(bool) onToggle;
  final VoidCallback onTap;

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Modern Icon Mapping using Lucide
  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return LucideIcons.moon_star;
      case TaskCategory.iyilik:
        return LucideIcons.heart;
      case TaskCategory.zihin:
        return LucideIcons.brain_circuit;
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.ibadet:
        return AppColors.accentGold;
      case TaskCategory.iyilik:
        return AppColors.deepRose;
      case TaskCategory.zihin:
        return AppColors.calmBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;
    final isLocked = currentHour < widget.task.startHour;
    final categoryColor = _getCategoryColor(widget.task.category);

    return GestureDetector(
      onTapDown: (_) {
        if (!isLocked) _controller.forward();
      },
      onTapUp: (_) {
        if (!isLocked) _controller.reverse();
      },
      onTapCancel: () {
        if (!isLocked) _controller.reverse();
      },
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.lock, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                      'Bu görev saat ${widget.task.startHour}:00\'da açılacak.'),
                ],
              ),
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          widget.onTap();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12), // Spacious margin
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16), // Spacious padding
              decoration: BoxDecoration(
                color: widget.task.isCompleted
                    ? AppColors.primaryGreen.withOpacity(0.08)
                    : (isLocked
                        ? Colors.white.withOpacity(0.03)
                        : Colors.white
                            .withOpacity(0.6)), // Higher opacity for fresh look
                borderRadius:
                    BorderRadius.circular(24), // Super rounded 2026 style
                border: Border.all(
                  color: widget.task.isCompleted
                      ? AppColors.primaryGreen.withOpacity(0.2)
                      : Colors.white.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: widget.task.isCompleted
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.glassShadow.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.withOpacity(0.1)
                          : categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        isLocked
                            ? LucideIcons.lock
                            : _getCategoryIcon(widget.task.category),
                        color: isLocked ? Colors.grey : categoryColor,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: widget.task.isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            fontSize: 16, // Larger font
                            fontWeight: FontWeight.w600,
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          child: Text(widget.task.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocked
                              ? 'Bugün ${widget.task.startHour}:00\'da aktif'
                              : widget.task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary, // Clearer secondary
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Action (Checkbox or Lock)
                  if (!isLocked)
                    Transform.scale(
                      scale: 1.1,
                      child: AnimatedCheckbox(
                        value: widget.task.isCompleted,
                        onChanged: (val) => widget.onToggle(val),
                        size: 26,
                        activeColor: AppColors.primaryGreen,
                        // checkColor removed as it is not supported
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
