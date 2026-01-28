import '../entities/task_entity.dart';
import '../entities/task_history_entity.dart';

abstract class TaskRepository {
  /// Get current list of tasks
  Future<List<TaskEntity>> getDailyTasks();

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted);

  /// Reset tasks if a new day has started
  Future<void> checkAndResetDailyTasks();

  /// Calculate current Vicdan Score based on completed tasks
  Future<int> calculateDailyScore();

  Future<List<TaskHistoryEntity>> getHistory(int days);

  Future<void> addTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> restoreDefaults();
}
