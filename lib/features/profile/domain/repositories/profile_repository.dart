import '../entities/user_stats.dart';

/// Repository interface for profile data.
/// Defines the contract for accessing user statistics and profile info.
abstract class ProfileRepository {
  /// Returns the user's current statistics.
  Future<UserStats> getUserStats();

  /// Returns the user's streak (consecutive days with completed tasks).
  Future<int> getCurrentStreak();

  /// Returns the user's longest streak ever.
  Future<int> getLongestStreak();

  /// Returns the total number of tasks completed.
  Future<int> getTotalCompletedTasks();

  /// Returns health scores for the last N days.
  Future<List<Map<String, dynamic>>> getHealthScoreHistory(int days);
}
