import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_task_datasource.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_history_entity.dart';

import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<TaskEntity>> getDailyTasks() async {
    return await _dataSource.getTasks();
  }

  @override
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _dataSource.updateTaskStatus(taskId, isCompleted);
  }

  @override
  Future<void> checkAndResetDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString('last_reset_date');
    final today = DateTime.now();
    // Use ISO8601 Date only (YYYY-MM-DD) which ensures padding
    final todayStr = today.toIso8601String().split('T')[0];

    if (lastResetStr != todayStr) {
      if (lastResetStr != null) {
        // Archive the data for the previous day (which is currently in the DB)
        await _dataSource.archiveDailyProgress(lastResetStr);
      }

      // Calculate Day Index based on Install Date
      String? installDateStr = prefs.getString('install_date');
      if (installDateStr == null) {
        // First time run or update: set install date to today
        installDateStr = todayStr;
        await prefs.setString('install_date', todayStr);
      }

      // Parse safely
      DateTime installDate;
      try {
        installDate = DateTime.parse(installDateStr);
      } catch (e) {
        // Fallback if parsing fails (e.g. legacy data)
        installDate = today;
        await prefs.setString('install_date', todayStr);
      }

      final dayIndex = today.difference(installDate).inDays;

      // It's a new day! Reset tasks with new content for the specific day
      await _dataSource.resetDailyTasks(dayIndex);
      await prefs.setString('last_reset_date', todayStr);
    }
  }

  @override
  Future<int> calculateDailyScore() async {
    final tasks = await _dataSource.getTasks();
    int totalScore = 0;

    // Base score (can be adjusted)
    // Here we just sum XP of completed tasks
    // Max score is 100, so we might need normalization if total XP > 100
    // But for now, let's just sum specific completed tasks

    var currentXp = 0;
    var totalPossibleXp = 0;

    for (var task in tasks) {
      totalPossibleXp += task.xpValue;
      if (task.isCompleted) {
        currentXp += task.xpValue;
      }
    }

    if (totalPossibleXp == 0) return 0;

    // Normalize to 0-100 scale
    // e.g., if total XP is 110, and user has 55, score is 50.
    totalScore = ((currentXp / totalPossibleXp) * 100).round();

    return totalScore.clamp(0, 100);
  }

  @override
  Future<List<TaskHistoryEntity>> getHistory(int days) async {
    final historyData = await _dataSource.getHistory(days);
    return historyData.map((data) {
      return TaskHistoryEntity(
        date: data['date'] as String,
        totalScore: data['totalScore'] as int,
        completedCount: data['completedCount'] as int,
        totalCount: data['totalCount'] as int,
      );
    }).toList();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      xpValue: task.xpValue,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
    );
    await _dataSource.addTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _dataSource.deleteTask(id);
  }

  @override
  Future<void> restoreDefaults() async {
    await _dataSource.restoreDefaults();
  }
}
