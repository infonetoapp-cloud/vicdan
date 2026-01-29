import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';

/// Implementation of ProfileRepository.
/// Fetches data from TaskRepository and SharedPreferences.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._taskRepo);
  final TaskRepositoryImpl _taskRepo;
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> _init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();

      // Save account start date if not exists
      if (!_prefs.containsKey('account_start_date')) {
        await _prefs.setString(
            'account_start_date', DateTime.now().toIso8601String());
      }

      _initialized = true;
    }
  }

  @override
  Future<UserStats> getUserStats() async {
    await _init();

    final streak = await getCurrentStreak();
    final longestStreak = await getLongestStreak();
    final totalTasks = await _taskRepo.getTotalCompletedTasksCount();
    final todayScore = await _taskRepo.calculateDailyScore();
    final userName = _prefs.getString('user_name') ?? 'Yolcu';

    // Calculate days using app
    final startStr = _prefs.getString('account_start_date');
    int daysUsingApp = 1;
    if (startStr != null) {
      final startDate = DateTime.parse(startStr);
      daysUsingApp = DateTime.now().difference(startDate).inDays + 1;
    }

    // Calculate Quran reading minutes from stored seconds for better precision
    final totalSeconds = _prefs.getInt('quran_reading_seconds') ??
        ((_prefs.getInt('quran_reading_minutes') ?? 0) * 60);
    final quranReadingMinutes = totalSeconds ~/ 60;

    final avatarUrl = _prefs.getString('user_avatar');

    return UserStats(
      currentStreak: streak,
      longestStreak: longestStreak,
      totalCompletedTasks: totalTasks,
      todayScore: todayScore,
      userName: userName,
      daysUsingApp: daysUsingApp,
      quranReadingMinutes: quranReadingMinutes,
      avatarUrl: avatarUrl,
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
    final history = await _taskRepo.getHistory(days);

    // Map TaskHistoryEntity to expected Map format
    return history.map((e) {
      return {
        'date': DateTime.parse(e.date),
        'score': e.totalScore,
      };
    }).toList();
  }

  /// Saves user name to preferences.
  Future<void> saveUserName(String name) async {
    await _init();
    await _prefs.setString('user_name', name);
  }
}
