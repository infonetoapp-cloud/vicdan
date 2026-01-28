import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';

/// Implementation of ProfileRepository.
/// Fetches data from TaskRepository and SharedPreferences.
class ProfileRepositoryImpl implements ProfileRepository {
  final TaskRepositoryImpl _taskRepo;
  late SharedPreferences _prefs;
  bool _initialized = false;

  ProfileRepositoryImpl(this._taskRepo);

  Future<void> _init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  @override
  Future<UserStats> getUserStats() async {
    await _init();

    final streak = await getCurrentStreak();
    final longestStreak = await getLongestStreak();
    final totalTasks = await getTotalCompletedTasks();
    final todayScore = await _taskRepo.calculateDailyScore();
    final userName = _prefs.getString('user_name') ?? 'Yolcu';

    return UserStats(
      currentStreak: streak,
      longestStreak: longestStreak,
      totalCompletedTasks: totalTasks,
      todayScore: todayScore,
      userName: userName,
    );
  }

  @override
  Future<int> getCurrentStreak() async {
    await _init();
    return _prefs.getInt('current_streak') ?? 1;
  }

  @override
  Future<int> getLongestStreak() async {
    await _init();
    return _prefs.getInt('longest_streak') ?? 1;
  }

  @override
  Future<int> getTotalCompletedTasks() async {
    await _init();
    return _prefs.getInt('total_completed_tasks') ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getHealthScoreHistory(int days) async {
    // Placeholder: Generate mock data for now
    final List<Map<String, dynamic>> history = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final score = 50 + (date.day % 50);
      history.add({
        'date': date,
        'score': score,
      });
    }

    return history;
  }

  /// Saves user name to preferences.
  Future<void> saveUserName(String name) async {
    await _init();
    await _prefs.setString('user_name', name);
  }
}
