class TaskHistoryEntity {
  final String date;
  final int totalScore;
  final int completedCount;
  final int totalCount;

  const TaskHistoryEntity({
    required this.date,
    required this.totalScore,
    required this.completedCount,
    required this.totalCount,
  });
}
