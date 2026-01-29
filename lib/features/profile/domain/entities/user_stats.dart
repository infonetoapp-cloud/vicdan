import 'package:equatable/equatable.dart';

/// Domain entity representing user statistics.
class UserStats extends Equatable {
  const UserStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedTasks,
    required this.todayScore,
    required this.userName,
    required this.daysUsingApp,
    required this.quranReadingMinutes,
    this.avatarUrl,
  });
  final int currentStreak;
  final int longestStreak;
  final int totalCompletedTasks;
  final int todayScore;
  final String userName;
  final int daysUsingApp;
  final int quranReadingMinutes;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalCompletedTasks,
        todayScore,
        userName,
        daysUsingApp,
        quranReadingMinutes,
        avatarUrl,
      ];
}
