import 'package:equatable/equatable.dart';

/// Domain entity representing user statistics.
class UserStats extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalCompletedTasks;
  final int todayScore;
  final String userName;

  const UserStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedTasks,
    required this.todayScore,
    required this.userName,
  });

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalCompletedTasks,
        todayScore,
        userName,
      ];
}
