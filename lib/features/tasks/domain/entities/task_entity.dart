import 'package:equatable/equatable.dart';
import 'task_category.dart';

/// Core Task Entity for the Domain Layer
class TaskEntity extends Equatable {

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpValue,
    this.startHour = 0,
    this.isCompleted = false,
    this.completedAt,
  });
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final int xpValue;
  final int startHour; // 0-23, hour when task unlocks (default 0)
  final bool isCompleted;
  final DateTime? completedAt;

  /// Create a copy of the task with updated fields
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    int? xpValue,
    int? startHour,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      xpValue: xpValue ?? this.xpValue,
      startHour: startHour ?? this.startHour,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, category, xpValue, isCompleted, completedAt];
}
