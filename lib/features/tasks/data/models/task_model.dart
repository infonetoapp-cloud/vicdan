import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';

/// Data Model for Task, handling JSON and DB conversions
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.xpValue,
    super.startHour = 0,
    required super.isCompleted,
    super.completedAt,
  });

  /// Create from Map (SQFLite)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: TaskCategory.values[map['category'] as int],
      xpValue: map['xpValue'] as int,
      startHour: (map['startHour'] as int?) ?? 0,
      isCompleted: (map['isCompleted'] as int) == 1,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  /// Factory to create generic tasks (initial seed)
  factory TaskModel.create({
    required String id,
    required String title,
    required String description,
    required TaskCategory category,
    required int xpValue,
    int startHour = 0,
  }) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      category: category,
      xpValue: xpValue,
      startHour: startHour,
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Convert to Map for SQFLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index, // Store as integer index for simplicity
      'xpValue': xpValue,
      'startHour': startHour,
      'isCompleted': isCompleted ? 1 : 0, // SQFLite lacks boolean
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
